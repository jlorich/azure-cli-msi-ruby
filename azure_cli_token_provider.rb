require 'json'

class AzureCliTokenProvider
    @access_token = nil
    @token_type = nil

    def get_authentication_header
        token = @access_token || acquire_token

        "#{@token_type} #{token}"
    end

    private 

    def acquire_token()
        result = JSON.parse(`az account get-access-token -o json --resource https://vault.azure.net`)

        @token_type = result['tokenType']
        @access_token = result['accessToken']
    end
end