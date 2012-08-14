require 'spec_helper'

describe Zipstream do
  around do |example|
    Dir.mktmpdir do |dir|
      @dir = dir
      example.call
    end
  end

  let(:path) { "#{@dir}/test.zip" }

  it "should create an extractable zip" do
    File.open(path, 'w') do |f|
      zip = Zipstream.new(f)
      zip.write "README", "This is a README!"
      zip.write "LICENSE", "Copyright (c) 2012 Me"
      zip.close
    end

    Zip::ZipFile.open(path, "r") do |zip|
      zip.size.should == 2

      readme = zip.find_entry("README")
      readme.should_not be_nil
      readme.get_input_stream.read.should == "This is a README!"

      license = zip.find_entry("LICENSE")
      license.should_not be_nil
      license.get_input_stream.read.should == "Copyright (c) 2012 Me"
    end
  end
  
  it "should support setting compression method" do
    File.open(path, 'w') do |f|
      zip = Zipstream.new(f)
      zip.write "deflated.txt", "deflated file", :method => :deflate
      zip.write "stored.txt", "stored file", :method => :store
      zip.write "default.txt", "default method"
      zip.close
    end

    Zip::ZipFile.open(path, "r") do |zip|
      zip.size.should == 3

      deflated = zip.find_entry("deflated.txt")
      deflated.get_input_stream.read.should == "deflated file"
      deflated.compression_method.should == Zip::ZipEntry::DEFLATED

      stored = zip.find_entry("stored.txt")
      stored.get_input_stream.read.should == "stored file"
      stored.compression_method.should == Zip::ZipEntry::STORED

      default = zip.find_entry("default.txt")
      default.get_input_stream.read.should == "default method"
      default.compression_method.should == Zip::ZipEntry::DEFLATED
    end
  end
end
