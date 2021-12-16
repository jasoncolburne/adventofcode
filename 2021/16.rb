#!/usr/bin/env ruby

require 'set'
require 'rubygems'
require 'bundler/setup'
require 'jason/math'

require './screen'

data = "D2FE28"
data = "38006F45291200"
data = "8A004A801A8002F478"
data = "620080001611562C8802118E34"
data = "C0015000016115A2E0802F182340"
data = "A0016C880162017C3686B18A3D4780"

data = "C200B40A82"
data = "04005AC33890"

data = File.read(ARGV[0]).chomp

@bits = data.to_i(16).to_s(2)
while @bits.length % 4 != 0
  @bits = '0' + @bits
end

@i = 0
@version_sum = 0

def decode_packet
  bits = @bits

  version = bits[@i..(@i + 2)].to_i(2)
  @i += 3
  type_id = bits[@i..(@i + 2)].to_i(2)
  @i += 3

  @version_sum += version

  if type_id == 4
    literal_value = ""
    while true
      literal_value += bits[(@i + 1)..(@i + 4)]
      break if bits[@i] == '0'
      @i += 5
    end
    @i += 5
    
    literal_value.to_i(2)
  else
    sub_packets = []
    if bits[@i] == '0'
      sub_packet_bit_length = bits[(@i + 1)..(@i + 15)].to_i(2)
      @i += 16
      bit_limit = @i + sub_packet_bit_length

      while @i < bit_limit
        sub_packets << decode_packet
      end
    else
      subpacket_count = bits[(@i + 1)..(@i + 11)].to_i(2)
      @i += 12

      subpacket_count.times do
        sub_packets << decode_packet
      end
    end

    case type_id
    when 0
      sub_packets.sum
    when 1
      sub_packets.product
    when 2
      sub_packets.min
    when 3
      sub_packets.max
    when 5
      (sub_packets.first > sub_packets.last) ? 1 : 0
    when 6
      (sub_packets.first < sub_packets.last) ? 1 : 0
    when 7
      (sub_packets.first == sub_packets.last) ? 1 : 0
    end
  end
end

output = decode_packet
puts @version_sum
puts output 
