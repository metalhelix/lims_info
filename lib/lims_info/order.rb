
require 'open-uri'
require 'nokogiri'

require 'user_data'
require 'lims_utils'


module LimsInfo
  class Order
    def self.start args
      order = Order.new
      order.run(args)
    end

    def initialize
    end

    def run args
      raw_order = args[0]
      order_number = clean_order(raw_order)
      if order_number == 0
        puts "ERROR: #{raw_order} is not a valid order number"
        puts "Valid order number examples: MOLNG-123, 123"
        exit(1)
      end

      data = get_order_data order_number
      print_data(data)
    end

    def clean_order order
      num = order.split(/[-_]/)[-1].to_i
      num
    end

    def get_order_data order_number
      user_data = UserData.fetch()
      agent = LimsUtils::login(user_data["username"], user_data["password"])
      flowcells = parse_flowcells(agent, order_number)
      order_data = {"order_id" => "MOLNG-#{order_number}"}
      order_data["flowcells"] = flowcells
      order_data
    end

    def parse_flowcells agent, order_number
      url = "http://limskc01/zanmodules/molbio/ajax/ngs_order_results.php?o=#{order_number}"
      doc = agent.get(url).parser
      flowcell_ids = doc.xpath("//table[@class='infotable'][1]/tbody/tr[1]/td/a")
      flowcells = []
      flowcell_ids.each_with_index do |fcid, fcid_index|
        name = fcid.content
        # awful way to do this - but what can you do
        # the xpath returns all href's inside td's
        # for my example, this returns the flowcell id's and the paths
        # there are 3 paths for each flowcell
        # so we skip the flowcell id's and get the second path listed
        count = flowcell_ids.size
        path = doc.xpath("//table[@class='infotable'][1]/tbody/tr/td/a")[(count - 1) + (fcid_index * 3) + 2].content
        flowcells << {"fcid" => name, "path" => path}
      end
      flowcells
    end

    def print_data data
      data["flowcells"].each do |flowcell|
        puts "#{flowcell["fcid"]}\t#{flowcell["path"]}"
      end
    end
  end
end
