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
end
