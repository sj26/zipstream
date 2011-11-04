# Credit: http://www.khjk.org/log/2010/jun/fibr.html

class Fiber
  @@fibers = []   # a stack of fibers corresponding to calls of 'resume'

  def initialize &block
    @body = lambda &block         # lambda makes 'return' work as expected
  end

  def resume *args
    @@fibers.push self
    jump *args                    # jumping into fiber
  end

  def self.current
    @@fibers.last
  end

  def self.yield *args
    if fiber = @@fibers.pop
      fiber.send :jump, args      # jumping out of fiber
    end
  end

private

  def jump *args
    callcc do |continuation|
      destination, @body = @body, continuation
      destination.call *args
      @@fibers.pop
      @body.call                   # return from the last 'resume'
    end
  end
end if RUBY_VERSION < '1.9'
