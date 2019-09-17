#encoding: utf-8

require_relative "sink"

# A streaming sink does not batch data and stream data down stream.
class StreamingSink < Sink
end