require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'lims_info/order'


describe LimsInfo::Order do

  before :each do
    # @config_file = File.expand_path(File.join(File.dirname(__FILE__), "fixtures", "hastie_config"))
    # @server_dir = File.expand_path(File.join(File.dirname(__FILE__), "fixtures", "server"))
    # @output_dir = File.expand_path(File.join(File.dirname(__FILE__), "sandbox"))
    # @date = "2011-11-31"
  end

  after :each do
    # FileUtils.rm_r @output_dir if File.exists?(@output_dir)
  end

  it "should work" do
    @input = ["MOLNG-266"]
    content = capture(:stdout) do
      lambda { LimsInfo::Order.start @input }.should_not raise_error SystemExit
    end
    content.split("\n").size.should >= 3
  end

end
