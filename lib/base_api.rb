require "httparty"

module Rubiclifier
  class BaseApi
    include HTTParty

    def self.api_token
      base_uri(base_api_url)
      @api_token ||= DB.get_setting(api_token_db_key) ||
        begin
          t = login_and_get_api_token
          if t.nil?
            invalid_credentials_error
          else
            DB.save_setting(api_token_db_key, t, is_secret: true)
            t
          end
        end
    end

    def self.invalid_credentials_error
      raise "Invalid credentials!"
    end

    def self.login_and_get_api_token
      raise NotImplementedError
    end

    def self.api_token_db_key
      raise NotImplementedError
    end

    def self.base_api_url_db_key
      raise NotImplementedError
    end

    def self.wrap_with_authentication(&block)
      res = block.call
      if res.code == 401 || res.code == 403
        @api_token = nil
        DB.save_setting(api_token_db_key, nil, is_secret: false)
        block.call
      else
        res
      end
    end

    def self.base_api_url
      @base_api_url ||= DB.get_setting(base_api_url_db_key)&.chomp("/")
    end
  end
end
