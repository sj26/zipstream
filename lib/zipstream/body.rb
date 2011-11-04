require 'zipstream'
require 'zipstream-fiber-compat' unless defined? Fiber

# We use Fibers to deep-yield data being written to the zip stream
# to use as a rack response body (responds to #each)
class ZipStream::Body
  def initialize &block
    @stream = FiberYieldingStream.new
    @fiber = Fiber.new do
      zip = ZipStream.new @stream
      block.call zip
      zip.close
      # Make sure this returns nil as a sentinel
      nil
    end
  end

  def each
    while !(data = @fiber.resume).nil?
      yield data
    end
  end

  # A stream that yields each write to the current fiber
  class FiberYieldingStream
    def write data
      tap { Fiber.yield data }
    end

    alias << write
  end
end
