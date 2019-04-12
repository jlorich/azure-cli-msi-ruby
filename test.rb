require './key_vault_service'
require 'pry'

service = KeyVaultService.new
puts service.get_secret 'arm-client-id' 

binding.pry

print ""