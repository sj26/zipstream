require 'fileutils'

module SpecHelper
  
  ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  
  def mkdir(*dir)
    FileUtils.mkdir_p(File.join(ROOT, *dir))
  end
  
  def rmdir(*dir)
    FileUtils.rm_rf(File.join(ROOT, *dir))
  end
  
  def full_path(*path)
    File.join(ROOT, *path)
  end
  
  def check_unzip
    fail 'Unzip not found. Please install unzip' unless `unzip` =~ /^UnZip \d/i
  end
end

RSpec.configure do |c|
  c.include SpecHelper
end