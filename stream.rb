class Stream
  def self.continually(&block)
    Stream.new(yield) do
      Stream.continually(&block)
    end
  end

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
    elsif n < 0
      nil
    else
      last_stream = self
      n.times {
        last_stream = last_stream.tail
      }

      last_stream.head
    end
  end

  def take(n)
    FiniteStream.new(n, self.head, &@tail_block)
  end

  def take_while(&block)
    filter_proc = Proc.new(&block)
    MaybeFiniteStream.new(filter_proc, self.head, &@tail_block)
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

  def map(&block)
    Stream.new(yield head) do
      tail.map(&block)
    end
  end

  def filter(&block)
    if block.call(head)
      Stream.new(head) do
        tail.filter(&block)
      end
    else
      tail.filter(&block)
    end
  end

  private

  class MaybeFiniteStream < Stream
    def initialize(filter_func, head, &tail_block)
      @head = head
      @tail_block = tail_block
      @filter_func = filter_func
    end

    def length
      counter = 0
      self.each { |i| counter += 1 }
      counter
    end

    def each
      last_stream = self

      while @filter_func.call(last_stream.head) do
        yield last_stream.head
        last_stream = last_stream.tail
      end

      nil
    end
  end

  class FiniteStream < Stream
    def initialize(limit, head, &tail_block)
      @length = limit
      @head = head
      @tail_block = tail_block
    end

    def [](n)
      if n >= @length
        nil
      else
        super(n)
      end
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

    def take(n)
      if n > @length
        self
      else
        super
      end
    end

    def map(&block)
      super.take(@length)
    end

    def filter(&block)
      super.take(@length)
    end
  end
end
