
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
      user_data = get_user_data(agent, username)
      lims_out = search_lims(agent, user_data)
      print_order_info(lims_out)
    end

    def print_order_info(lims_data)
      headers = ["Order", "Status", "Date Requested", "Date Completed"]
      header_ids = [:name, :status, :date_request, :date_complete]

      puts headers.join("\t")
      lims_data.each do |order|
        out = header_ids.collect {|h| order[h] }
        puts out.join("\t")
      end
    end

    def search_lims(agent, user_data)
      search_string = "{\"elemType\":\"GROUPER\",\"children\":[{\"elemType\":\"ITEM\",\"fieldID\":\"requesterID\",\"opID\":\"is\",\"value\":\"#{user_data[:id]}\"}],\"indentLevel\":0}"
      url = "http://limskc01/zanmodules/molbio/searches/ngs_orders_html.php?q="
      full_search = url + URI.encode(search_string)+ "&searchType=ADVANCED"
      page = agent.get(full_search)
      table_rows = page.parser.css("table.infotable tbody tr")
      data = []

      table_rows.each do |row|
        tds = row.css("td")
        order = {:name => tds[0].content, :date_request => tds[3].content, :library_num => tds[5].content, :date_library => tds[6].content, :date_complete => tds[10].content, :status => tds[11].content, :order_type => tds[13].content, :read_type => tds[14].content, :read_length => tds[15].content}
        data << order
      end

      data.sort {|a,b| b[:name].split("-")[-1].to_i <=> a[:name].split("-")[-1].to_i}
    end

    def get_user_data agent, username
      users = LimsUtils::user_list(agent)
      user_data = find_user(username, users)
      if !user_data
        puts "ERROR: cannot find ID for #{username}"
        exit(1)
      end
      user_data
    end

    def find_user(username, users)
      users.select {|u| u[:login] == username}.shift
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
