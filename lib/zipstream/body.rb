# Stream a zipfile as a rack response body
#
# We use Fibers to deep-yield data being written to the zip stream
# directly to Rack
class Zipstream::Body
  def initialize &block
    @stream = Zipstream::FiberYieldingStream.new
    @fiber = Zipstream::Fiber.new do
      Zipstream.new(@stream).tap(&block).close
      # Make sure this returns nil as a sentinel
      nil
    end
  end

  def each
    # Yield fiber yielded data until we hit our nil sentinel
    until (yielded = @fiber.resume).nil?
      yield yielded.first
    end
  end
end
