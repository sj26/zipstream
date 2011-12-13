if defined? Fiber
  # Use native Fibers if available
  Zipstream::Fiber = Fiber
else
  # Minimal compatibility layer for Fibers
  # Doesn't seem very comprehensive nor resilient, but it does the job
  # Credit: http://www.khjk.org/log/2010/jun/fibr.html
  class Zipstream::Fiber
    @@fibers = []   # a stack of fibers corresponding to calls of 'resume'

    def initialize &block
      # lambda makes 'return' work as expected
      @body = lambda &block
    end

    def resume arg
      @@fibers.push self
      # jumping into fiber
      jump arg
    end

    def self.current
      @@fibers.last
    end

    def self.yield arg
      if fiber = @@fibers.pop
        # jumping out of fiber
        fiber.send :jump, arg
      end
    end

  private

    def jump arg
      callcc do |continuation|
        destination, @body = @body, continuation
        destination.call arg
        @@fibers.pop
        # return from the last 'resume'
        @body.call
      end
    end
  end
end
