#!/usr/bin/env ruby

require 'ms_rest_azure'
#require 'azure_mgmt_resources'
#require 'azure_mgmt_key_vault'
require 'azure_key_vault'
require 'dotenv'


#Dotenv.load!(File.join(__dir__, './.env'))

# This script expects that the following environment vars are set:
#
# AZURE_TENANT_ID: with your Azure Active Directory tenant id or domain
# AZURE_SUBSCRIPTION_ID: with your Azure Subscription Id

def run_example
  #
  # Create the Resource Manager Client with an Managed Service Identity token provider
  #
  MsRest.use_ssl_cert
  subscription_id = ENV['AZURE_SUBSCRIPTION_ID'] || '11111111-1111-1111-1111-111111111111' # your Azure Subscription Id
  tenant_id = ENV['AZURE_TENANT_ID']
  settings = MsRestAzure::ActiveDirectoryServiceSettings.get_azure_settings

  # Create System Assigned MSI token provider
  provider = MsRestAzure::MSITokenProvider.new


  # The below code shows options to create MSI token provider for User Assigned identity.
  # Please uncomment the desired line to run this sample and obtain the appropriate token provider.
  #
  # # Create User Assigned MSI token provider using client_id
  # provider = MsRestAzure::MSITokenProvider.new(port, settings,  {:client_id => '00000000-0000-0000-0000-000000000000' })
  #
  # # Create User Assigned MSI token provider using object_id
  # provider = MsRestAzure::MSITokenProvider.new(port, settings,  {:object_id => '00000000-0000-0000-0000-000000000000' })
  #
  # # Create User Assigned MSI token provider using msi_res_id
  # provider = MsRestAzure::MSITokenProvider.new(port, settings,  {:msi_res_id => '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/msiname'})

  puts 'before getting credentials'
  credentials = MsRest::TokenCredentials.new(provider)
  puts credentials.inspect
  puts provider.get_authentication_header
  puts 'after getting credentials'


  # Create a keyvault client
  #client = Azure::Resources::Mgmt::V2017_05_10::ResourceManagementClient.new(credentials)
  #client.subscription_id = subscription_id

  options = {
    tenant_id: tenant_id,
    subscription_id: subscription_id,
    credentials: credentials
  }
  #keyvault_client = Azure::KeyVault::V2015_06_01::KeyVaultClient.new(credentials, options)
  #keyvault_client = Azure::KeyVault::V2016_10_01::KeyVaultClient.new(credentials, options)
  keyvault_client = Azure::KeyVault::V7_0::KeyVaultClient.new(credentials, options)
  #keyvault_client = Azure::KeyVault::Mgmt::V2015_06_01::KeyVaultManagementClient.new(credentials)
  
  #keyvault_client = Azure::KeyVault::Mgmt::V2018_02_14::KeyVaultManagementClient.new(credentials)
  #-->keyvault_client = Azure::KeyVault::Profiles::Latest::Mgmt::Client.new(options)
  #keyvault_client.subscription_id = subscription_id

  puts keyvault_client.get_secret(ENV['KEY_VAULT_URI'], 'secret', '' )

end

if $0 == __FILE__
  run_example
end
