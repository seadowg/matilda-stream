# matilda-stream

[![Build Status](https://travis-ci.org/seadowg/matilda-stream.png?branch=master)](https://travis-ci.org/seadowg/matilda-stream)
[![Coverage
Status](https://coveralls.io/repos/seadowg/matilda-stream/badge.png)](https://coveralls.io/r/seadowg/matilda-stream)

Lazy stream implementation for Ruby because Enumerators are kinda silly.

## Description

Streams are infinite, lazily evaluated, awesome lists. Here's an example
of a Stream that represents the set of positive integers:

    def int_stream(i)
      Stream.new(i) do
        int_stream(i + 1)
      end
    end

    integers = int_stream(1)

You can access streams like any other data structure:

    integers[0] # => 1
    integers[12] # => 13
    integers[999999] # => 999998

Each value will be lazily calculated by materializing the Streams values
until the requested value. Streams are stateless so a Stream will
recalculate for every access.

You can also create finite Streams from infinite ones:

    integers.take(5)

Finite streams have some extra functionality due to their ability to
end:

    integers.take(5).each do |i|
       puts i
    end

    integers.length # => 5

Infinite Streams also support interation and length calculations but you
will need to be prepared to wait, forever. No seriously, I mean for all
time. Its infinite.

Streams become most powerful when used with high order functions. At the
moment ruby-stream supports `map`, `filter`, `each`, `take` and `scan` operations that operate
as they would on normal collections (these operations will only actually be
applied to Stream elements on access or iteration however).
