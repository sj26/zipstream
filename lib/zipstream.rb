require 'date'
require 'zlib'

# Simple, streamable zip file creation
class Zipstream
  def initialize stream, options={}
    @stream = stream
    @length = 0
    @directory = ""
    @directory_count = 0
    @directory_length = 0
    @options = options
  end

  def write name, data, options={}
    if options[:method] == :store
      zdata = data
      method = 0x00
    else
      # Fails without specifying the window bits (odd!)
      deflater = Zlib::Deflate.new Zlib::BEST_COMPRESSION, -Zlib::MAX_WBITS
      zdata = deflater.deflate data, Zlib::FINISH
      deflater.close
      method = 0x08
    end

    timestamp = dostime options[:datetime] || DateTime.now
    crc = Zlib.crc32 data
    zdata_length = zdata.length
    data_length = data.length
    name = name.to_s
    name_length = name.length
    comment = options[:comment].to_s || ""
    comment_length = comment.length

    @directory << [
      # central file header signature
      0x02014b50,
      # version made by - "DOS" & http://www.pkware.com/documents/casestudies/APPNOTE.TXT Version: 6.3.2
      (0 << 8) & 63,
      # version needed to extract - "DOS" & "2.0 - File is compressed using Deflate compression"
      (0 << 8) & 20,
      # general purpose bit flag
      0x00,
      # compresion method (deflate or store)
      method,
      # dos timestamp
      timestamp,
      # crc32 of data
      crc,
      # compressed data length
      zdata_length,
      # uncompressed data length
      data_length,
      # filename length
      name_length,
      # extra data len
      0,
      # file comment length
      comment_length,
      # disk number start
      0,
      # internal file attributes
      0,
      # external file attributes
      32,
      # relative offset of local header
      @length,
    ].pack('Vv4V4v5V2') << name << comment
    @directory_length += 46 + name_length + comment_length
    @directory_count += 1

    @stream << [
      # local file header signature
      0x04034b50,
      # version needed to extract - "DOS" & "2.0 - File is compressed using Deflate compression"
      (0 << 8) & 20,
      # general purpose bit flag
      0x00,
      # compresion method (deflate or store)
      method,
      # dos timestamp
      timestamp,
      # checksum of data
      crc,
      # compressed data length
      zdata_length,
      # uncompressed data length
      data_length,
      # filename length
      name_length,
      # extra data len
      0,
    ].pack('Vv3V4v2') << name << zdata
    @length += 30 + name_length + zdata_length
  end

  # TODO: #write_file

  # TODO: use storage large files

  def close
    comment = @options[:comment].to_s || ""
    comment_length = comment.length

    @stream << @directory << [
      # end of central file header signature
      0x06054b50,
      # this disk number
      0x00,
      # number of disk with cdr
      0x00,
      # number of entries in the cdr on this disk
      @directory_count,
      # number of entries in the cdr
      @directory_count,
      # cdr size
      @directory_length,
      # cdr ofs
      @length,
      # zip file comment length
      comment_length,
    ].pack('Vv4V2v') << comment
  end

protected

  def dostime datetime
    (datetime.year - 1980) << 25 | datetime.month << 21 | datetime.day << 16 | datetime.hour << 11 | datetime.min << 5 | datetime.sec >> 1
  end
end

require 'zipstream/version'
require 'zipstream/fiber'
require 'zipstream/fiber_yielding_stream'
require 'zipstream/body'
require 'zipstream/railtie' if defined? Rails
