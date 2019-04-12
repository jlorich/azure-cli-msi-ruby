require 'ms_rest_azure'
require './azure_cli_token_provider'
require 'azure_key_vault'
require 'net/http'
require 'pry'

class KeyVaultService
    IMDS_TOKEN_ACQUIRE_URL = 'http://169.254.169.254/metadata/identity/oauth2/token'

    def initialize(vault_url)
        if msi_available?
            @token_provider = MsRestAzure::MSITokenProvider.new
        else
            @token_provider = AzureCliTokenProvider.new
        end

        credentials = MsRest::TokenCredentials.new @token_provider
        @key_vault_client = Azure::KeyVault::V7_0::KeyVaultClient.new credentials
        @vault_url = vault_url
    end

    def msi_available?
        result = Net::HTTP.start(IMDS_TOKEN_ACQUIRE_URL, 80, :read_timeout => 100) {|http| http.request(request)} rescue nil
        result && result.code == 200
    end

    def get_secret(secret_name)
        secret = @key_vault_client.get_secret(@vault_url, secret_name, "")
        secret.value
    end
end