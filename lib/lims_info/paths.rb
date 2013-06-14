
require 'lims_info/lims'


module LimsInfo
  class Paths
    def self.start args
      order = self.new
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
      lims = LIMS.new
      data = lims.flowcells(order_number, {:add_samples => false})
      data = squash_data(data)
      print_data(data)
    end

    def squash_data data
      new_data = []
      data.each do |flowcell|
        dd = {}
        dd['flowcell'] = flowcell['FCID']
        dd['status'] = flowcell['status']
        dd['path'] = flowcell['results'][0]['unixPath']
        new_data << dd
      end
      new_data
    end

    def print_data data
      data.each do |d|
        puts d.values.join("\t")
      end
      # puts data.to_yaml
    end
    def clean_order order
      num = order.split(/[-_]/)[-1].to_i
      num
    end
  end
end
