require 'ms_rest_azure'
require 'azure_key_vault'
require 'net/http'
require 'pry'

class KeyVaultService
  private

  IMDS_TOKEN_ACQUIRE_URL = 'http://169.254.169.254/metadata/identity/oauth2/token'

  # @return [String] the name of the key vault.
  attr_reader :key_vault_name

  # @return [MsRestAzure::AzureEnvironment] the current azure environment.
  attr_reader :azure_environment

  # @return [MsRest::TokenProvider] the token provider for the appropriate resource
  attr_reader :token_provider

  public

  #
  # Creates and initialize new instance of the KeyVaultService class.
  # @param azure_environment [MsRestAzure::AzureEnvironment] the desired azure environment.
  def initialize(key_vault_name, azure_environment = MsRestAzure::AzureEnvironments::AzureCloud)
    @key_vault_name = key_vault_name
    @azure_environment = azure_environment
  end

  def get_secret(secret_name, version = '')
    secret = key_vault_client.get_secret(key_vault_url, secret_name, version)
    secret.value
  end

  private

  def key_vault_client    
    @key_vault_client ||= begin
      credentials = MsRest::TokenCredentials.new token_provider
      Azure::KeyVault::V7_0::KeyVaultClient.new credentials
    end
  end

  def token_provider
    @token_provider ||= begin
      msi_available? ? msi_token_provider : cli_token_provider
    end

    @token_provider
  end

  def msi_token_provider
    MsRestAzure::MSITokenProvider.new
  end

  def msi_available?
      result = Net::HTTP.start(IMDS_TOKEN_ACQUIRE_URL, 80, :read_timeout => 100) {|http| http.request(request)} rescue nil
      result && result.code == 200
  end

  def cli_token_provider
    cli_settings = MsRestAzure::ActiveDirectoryServiceSettings.get_settings(azure_environment)
    cli_settings.token_audience = "https://#{azure_environment.key_vault_dns_suffix[1..]}"

    MsRestAzure::AzureCliTokenProvider.new(cli_settings)
  end

  def key_vault_url
    "https://#{key_vault_name}#{azure_environment.key_vault_dns_suffix}"
  end
end
