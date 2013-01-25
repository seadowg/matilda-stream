class Stream
  attr_reader :head
  
  def initialize(head, &block)
    @head = head
    @tail_block = block
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
    stream = FiniteStream.new(n, self.head) { @tail_block.call }
    stream
  end
  
  def length
    while true do end
  end
  
  def each
    last_stream = self

    while true do
      yield last_stream.head
      last_stream = last_stream.tail
    end
    
    nil
  end
  
  private 
  
  class FiniteStream < Stream
    def initialize(limit, head, &tail_block)
      @length = limit
      @head = head
      @tail_block = tail_block
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
  end
end