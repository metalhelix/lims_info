require 'yaml'

module LimsInfo
  class UserData
    USERDATA_FILENAME = File.expand_path("~/.lims_info")
    def self.fetch()
      if !File.exists?(USERDATA_FILENAME)
        puts "ERROR: cannot find User Data file: #{USERDATA_FILENAME}"
        exit(1)
      end
      data = YAML.load_file(USERDATA_FILENAME)
      if !data["username"]
        puts "ERROR: #{USERDATA_FILENAME} does not contain username"
        puts "please add"
        exit(1)
      end
      if !data["password"]
        puts "ERROR: #{USERDATA_FILENAME} does not contain password"
        puts "please add"
        exit(1)
      end
      data
    end
  end
end

