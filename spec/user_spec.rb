
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'lims_info/user'
 
 
describe LimsInfo::User do
  before :each do
  end
 
  after :each do
    # FileUtils.rm_r @output_dir if File.exists?(@output_dir)
  end
 
  it "should work" do
    content = capture(:stdout) do
      # lambda { Hastie::Info.start @input }.should_not raise_error SystemExit
    end
    @input = [""]
    LimsInfo::Order.start @input
  end
end
