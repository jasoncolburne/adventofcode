#!env ruby

data = <<EOT
FBFBBFFRLR
EOT

data = File.read(ARGV[0])

lines = data.chomp.split("\n")

seat_ids = (lines.map do |line|
  row = line[0..6].split('').map { |c| c == 'F' ? '0' : '1' }.join('').to_i(2)
  seat = line[7..].split('').map { |c| c == 'L' ? '0' : '1' }.join('').to_i(2)
  row * 8 + seat
end)

puts seat_ids.max

last_id = nil
seat_ids.sort.each do |id|
  if last_id
    if id - 1 != last_id
      puts id - 1
      exit
    else
      last_id = id
    end
  else
    last_id = id
  end
end