require 'spec_helper'

describe Zipstream::Body do
  it "should stream as a body" do
    @stage = 1
    body = Zipstream::Body.new do |zip|
      @stage = 2
      zip.write "README", "This is a README!"
      @stage = 3
      zip.write "LICENSE", "Copyright (c) 2012 Me"
      @stage = 4
    end.to_enum

    buffer = ""
    @stage.should == 1
    buffer += body.next until @stage > 1
    @stage.should == 2
    buffer += body.next until @stage > 2
    @stage.should == 3
    buffer += body.next until @stage > 3
    @stage.should == 4
  end
end
