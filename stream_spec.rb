require 'minitest/autorun'
require_relative 'stream'

def int_helper(i)
  Stream.new(i) do
    int_helper(i + 1)
  end
end

describe Stream do
  before do
    @stream = int_helper(1)
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

    describe "for a finite Stream" do
      it "returns a Stream with length limit if n > limit" do
        original = @stream.take(10)
        original.length.must_equal 10
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
end
