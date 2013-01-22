class Stream
  attr_reader :head
  
  def initialize(head, &block)
    @head = head
    @tail_block = block
    @length = -1
  end
  
  def tail
    @tail_block.call
  end
  
  def [](n)
    if n == 0
      self.head
    else
      last_stream = self
      n.times {
        last_stream = last_stream.tail
      }
      
      last_stream.head
    end
  end
  
  def take(n)
    stream = Stream.new(self.head) { @tail_block.call }
    stream.set_limit(n)
    stream
  end
  
  def length
    @length
  end
  
  def each
    last_stream = self
    @length.times {
      yield last_stream.head
      last_stream = last_stream.tail
    }
    
    nil
  end
  
  protected
  
  def set_limit(n)
    @length = n
  end
end