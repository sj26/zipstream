require 'spec_helper'
require 'zipstream'

describe Zipstream do
  
  before(:each) do
    check_unzip
    mkdir 'spec', 'tmp'
  end
  
  example 'basic' do
    path = full_path 'spec', 'tmp', 'sample.zip'
    
    File.open(path, 'w') do |f|
      zip = Zipstream.new(f)
      zip.write 'files/README.md', File.read(full_path('README.md'))
      zip.write 'files/LICENSE', File.read(full_path('LICENSE'))
      zip.close
    end
    
    system("cd #{full_path 'spec', 'tmp'} && unzip sample.zip > /dev/null")
    
    File.read(full_path('spec', 'tmp', 'files', 'README.md')).should == File.read(full_path('README.md'))
    File.read(full_path('spec', 'tmp', 'files', 'LICENSE')).should == File.read(full_path('LICENSE'))
  end
  
  after(:each) do
    rmdir 'spec', 'tmp'
  end
end
