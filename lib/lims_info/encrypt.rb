
require 'openssl'
require 'base64'
require 'uri'

module LimsInfo
  class Encrypt
    KEY = '01234567890123456789012345678901'
    def self.encrypt password
      cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
      cipher.encrypt
      cipher.key = KEY
      iv = cipher.iv = cipher.random_iv

      encrypted = cipher.update(password) + cipher.final
      encrypted = iv + encrypted
      encrypted = Base64.encode64(encrypted)
      encrypted = URI.escape(encrypted)
      encrypted
    end

    def self.decrypt encrypted
      cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
      cipher.decrypt
      cipher.key = KEY
      encrypted = URI.unescape(encrypted)
      encrypted = Base64.decode64(encrypted)
      cipher.iv = encrypted.slice!(0,16)
      decrypted = cipher.update(encrypted) + cipher.final
      decrypted
    end

    # helper method to run encrypt on a password and provide
    # recommended output.
    # should be changed if user_data's 'key:' parameter changes
    def self.obfuscate(password)
      if !password or password.empty?
        puts "ERROR: please provide lims_info with your LIMS password"
        puts "       this will not be stored anywhere in lims_info but"
        puts "       will be used to create an encrypted key of your password"
        exit(1)
      end
      password = password.strip

      encrypted = self.encrypt(password)
      puts "# add to your .lims_info file:"
      puts "key: #{encrypted}"
      puts ""
    end
  end
end
