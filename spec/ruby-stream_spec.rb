require 'minitest/autorun'
require 'ruby-stream'

describe Stream do
  before do
    int_helper = -> (i) {
      Stream.new(i) {
        int_helper.call(i + 1)
      }
    }

    @stream = int_helper.call(1)
  end

  describe "#head" do
    it "returns the first element of the Stream" do
      @stream.head.must_equal 1
    end
  end

  describe "#tail" do
    it "returns another Stream" do
      @stream.tail.kind_of?(Stream).must_equal true
    end

    it "returns a Stream with the next element as its head" do
      @stream.tail.head.must_equal 2
      @stream.tail.tail.head.must_equal 3
    end
  end

  describe "#[](n)" do
    it "calculates the nth element of the stream" do
      @stream[999].must_equal 1000
    end

    it "returns nil for negative n" do
      @stream[-1].must_equal nil
    end

    describe "for a finite Stream" do
      it "returns nil for n greater than the limit of the Stream" do
        @stream.take(10)[10].must_equal nil
      end
    end
  end

  describe "#take(n)" do
    it "returns another Stream" do
      @stream.take(10).kind_of?(Stream).must_equal true
    end

    it "returns a Stream with the correct #length" do
      @stream.take(10).length.must_equal 10
    end

    it "returns a Stream with the correct values" do
      stream = @stream.take(10)
      stream[0].must_equal 1
      stream[5].must_equal 6
      stream[7].must_equal 8
      stream[9].must_equal 10
    end

    it "returns a Stream that can be iterated through finitely" do
      @stream.take(10).each do |element|
        true.must_equal true
      end
    end

    describe "when operating on the result Stream" do
      it "returns a finite Stream for #map" do
        stream = @stream.take(10).map { |i| i.to_s }
        stream.length.must_equal 10
      end

      it "returns a finite Stream for #filter" do
        stream = @stream.take(10).filter { |i| true }
        stream.length.must_equal 10
      end
    end

    describe "for a finite Stream" do
      it "returns a Stream with length limit if n > limit" do
        original = @stream.take(10)
        original.take(100).length.must_equal 10
      end
    end
  end

  describe "#each(func)" do
    describe "for a finite Stream" do
      it "should return nil" do
        @stream.take(5).each do
          1
        end.must_equal nil
      end

      it "should execute the passed block for every element of the stream" do
        i = 0
        @stream.take(5).each do
          i += 1
        end

        i.must_equal 5
      end
    end
  end

  describe "#length" do
    it "returns the lenght for a finite array" do
      @stream.take(5).length.must_equal 5
    end
  end

  describe "#map(func)" do
    it "returns a new Stream" do
      @stream.map(&:to_s).kind_of?(Stream).must_equal true
    end

    it "returns a new Stream with mapped values" do
      mapped = @stream.map { |i| i + 1 }
      mapped[0].must_equal(2)
      mapped[3].must_equal(5)
      mapped[1000].must_equal(1002)
    end
  end

  describe "#filter(func)" do
    it "returns a new Stream" do
      @stream.filter { |i| i % 2 == 0 }.kind_of?(Stream).must_equal true
    end

    it "returns a new Stream with only elements matching the predicate" do
      filtered = @stream.filter { |i| i % 2 == 0 }
      filtered[0].must_equal 2
      filtered[1].must_equal 4
      filtered[3].must_equal 8
    end
  end

  describe "#take_while(func)" do
    it "returns a new Stream" do
      @stream.take_while { |i| i < 10 }.kind_of?(Stream).must_equal true
    end

    describe "when the return Stream is finite" do
      it "returns a Stream with the correct length" do
        @stream.take_while { |i| i < 10 }.length.must_equal 9
      end

      it "returns a Stream that iterates through finitely" do
        stream = @stream.take_while { |i| i < 10 }
        counter = 0
        stream.each { |i| counter += 1 }
        counter.must_equal 9
      end

      it "returns a finite Stream for #map" do
        stream = @stream.take_while { |i|
          i < 10
        }.map { |i| i.to_s }

        stream.length.must_equal 9
      end

      it "returns a finite Stream for #filter" do
        stream = @stream.take_while { |i|
          i < 10
        }.filter { |i| true }

        stream.length.must_equal 9
      end
    end
  end

  describe ".continually(func)" do
    it "returns a new Stream" do
      Stream.continually {
        true
      }.kind_of?(Stream).must_equal true
    end

    it "returns a Stream with the calculated block as each element" do
      stream_block = Proc.new do
        counter = 0
        Stream.continually {
          counter += 1
        }
      end

      stream_block.call.head.must_equal 1
      stream_block.call.tail.head.must_equal 2
      stream_block.call.tail.tail.head.must_equal 3
    end
  end

  describe "EmptyStream" do
    it "ends the Stream" do
      stream = -> (i) {
        Stream.new(i) do
          if i < 1
            Stream::EmptyStream.new
          else
            stream.call(i - 1)
          end
        end
      }

      stream.call(10).length.must_equal(11)
    end
  end
end
