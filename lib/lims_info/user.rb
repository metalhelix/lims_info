
require 'open-uri'
require 'nokogiri'

require 'lims_info/user_data'
require 'lims_info/lims_utils'


module LimsInfo
  class User
    def self.start args
      user = User.new
      user.run(args)
    end

    def initialize
    end

    def run args
      username = args[0]
      if !username or username.empty?
        puts "ERROR: please provide user's initials as input parameter"
        exit(1)
      end
      username = clean_name(username)

      agent = login()
      get_user_data(agent, username)
    end

    def get_user_data agent, username
    end

    def login
      user_data = UserData.fetch()
      agent = LimsUtils::login(user_data["username"], user_data["password"])
      agent
    end

    def clean_name raw_username
      raw_username.strip.downcase
    end
  end
end
