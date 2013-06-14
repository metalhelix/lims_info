
require 'lims_info/lims'


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

      lims = LIMS.new
      data = lims.order(order_number)

      filter_failed(data)
      data = squash_data(data)
      print_data(data)
    end

    def filter_failed data
      data['flowcells'].select! {|f| f['status'] == 'DATA_DISTRIBUTED'}
      data
    end

    def get_sample_on_lane order, flowcell, lane, library
      sample = {}
      sample['id'] = [flowcell['FCID'], lane['laneId'], library['sampleId']].join("_")
      sample['name'] = library['sampleName']
      sample['sample_id'] = library['sampleId']
      sample['library_id'] = library['libId']
      sample['flowcell'] = flowcell['FCID']
      sample['lane'] = lane['laneId']
      sample['index'] = library['indexSequences'] ? library['indexSequences'].join("-") : 'none'
      sample['index_type'] = library['indexType']
      sample['read_type'] = order['readType']
      sample['species'] = library['speciesName']
      sample['sample_type'] = library['sampleType']
      sample['files'] = ["s_#{sample['lane']}_1_#{sample['index']}.fastq.gz"]
      if order['readType'].downcase =~ /paired/
        sample['files'] << "s_#{sample['lane']}_2_#{sample['index']}.fastq.gz"
      end
      sample['path'] = library['resultsLocations'].select {|l| l['FCID'] == flowcell['FCID']}[0]['path']
      # sample['lane_comments'] = lane['comments']
      sample['factors'] = library['factors']


      sample
    end

    def squash_data data
      new_data = {}
      samples = []
      data['flowcells'].each do |flowcell|
        flowcell['lanes'].each do |lane|
          lane['samples'].each do |library|
            sample = get_sample_on_lane data, flowcell, lane, library
            samples << sample
          end
        end
      end
      {'order' => 'prnOrderNo', 'status' => 'orderStatus', 'goals' => 'analysisGoals', 'type' => 'orderType', 'read_type' => 'readType', 'read_length' => 'readLength'}.each do |new_name, old_name|
        new_data[new_name] = data[old_name]
      end
      new_data['data'] = samples
      new_data
    end

    def clean_order order
      num = order.split(/[-_]/)[-1].to_i
      num
    end

    def print_data data
      puts data.to_yaml
    end
  end
end
