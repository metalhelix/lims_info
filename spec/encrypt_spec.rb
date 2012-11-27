require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'lims_info/encrypt'
 
 
describe LimsInfo::Encrypt do
  before :each do
  end
 
  after :each do
    # FileUtils.rm_r @output_dir if File.exists?(@output_dir)
  end
 
  it "should work" do
    content = capture(:stdout) do
      # lambda { Hastie::Info.start @input }.should_not raise_error SystemExit
    end
    passwords = ["123dummy456", "***specail!!!", "21345532asfda", "HdAn!1Dd"]
    passwords.each do |password|
      encrypt = LimsInfo::Encrypt.encrypt password

      decrypted = LimsInfo::Encrypt.decrypt encrypt
      decrypted.should == password
    end
  end
end
