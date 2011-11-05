# A super-simple stream that yields each write to the current fiber
class Zipstream::FiberYieldingStream
  def write data
    tap { Zipstream::Fiber.yield data }
  end

  alias << write
end
