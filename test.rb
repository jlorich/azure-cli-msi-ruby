require './key_vault_service'

puts KeyVaultService.new("mtcden-sbx-tf-vault").get_secret("storage-account-name")

print ""
