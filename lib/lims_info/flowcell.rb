require 'optparse'
require 'json'

module LimsInfo
  class Flowcell
    FLOWCELL_SCRIPT_PATH = File.expand_path(File.join(File.dirname(__FILE__), "..", "ext", "lims_data.pl"))
    STANDARD_FILTER = ["laneID", "sampleName"]
    DEFAULT_FILTER = ["genomeVersion", "resultsPath"]

    def self.start args
      flowcell = self.new
      flowcell.run(args)
    end

    def initialize
    end

    def parse_options args
      options = {}
      options[:filter] = DEFAULT_FILTER
      opts = OptionParser.new do |o|
        o.banner = "Usage: lims_info [Flowcell Id] [options]"
        o.on('-f', "--filter laneID,resultsPath" , Array, 'Specify which fields to display') {|b| options[:filter] = b.collect {|filter| filter} }
        o.on('-h', '--help', 'Displays help screen, then exits') {puts o; exit}
      end

      opts.parse!(args)

      options[:filter] = options[:filter].unshift(STANDARD_FILTER).flatten.uniq

      options
    end

    def run args
      flowcell_id = args[0]
      options = parse_options(args)
      if !flowcell_id
        puts "Usage: lims_info -f [flowcell id] [options]"
        puts "       lims_info -h for more info"
        exit(1)
      end
      json_data = json_data_for(flowcell_id)["samples"]
      json_data = filter_results json_data, options[:filter]

      print json_data, options[:filter]
    end

    def json_data_for flowcell_id
      script = "perl #{FLOWCELL_SCRIPT_PATH}"
      lims_results = %x[#{script} #{flowcell_id}]
      lims_results.force_encoding("iso-8859-1")
      data = {"samples" => []}
      unless lims_results =~ /^[F|f]lowcell not found/
        data = JSON.parse(lims_results)
      end
      data
    end

    def filter_results json_data, filter
      results = json_data.collect do |data|
        filtered_data = data
        if filter and filter.respond_to?("include?") and !filter.empty?
          filtered_data = data.reject {|k,v| !filter.include?(k)}
        end

        if data["isControl"] == 1
          filtered_data = {}
        end
        filtered_data
      end

      results.reject {|data| data.empty?}
    end

    def print data, filter
      # puts filter
      data.sort! {|x,y| x["laneID"] <=> y["laneID"]}
      data.each do |sample|
        output_array = []
        filter.each do |name|
          output_array << sample.delete(name)
        end
        puts output_array.join("\t")
      end
    end
  end
end
