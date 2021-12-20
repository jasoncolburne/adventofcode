#!/usr/bin/env ruby

require 'set'
require 'matrix'
require 'rubygems'
require 'bundler/setup'
require 'jason/math'

data = <<EOT
--- scanner 0 ---
404,-588,-901
528,-643,409
-838,591,734
390,-675,-793
-537,-823,-458
-485,-357,347
-345,-311,381
-661,-816,-575
-876,649,763
-618,-824,-621
553,345,-567
474,580,667
-447,-329,318
-584,868,-557
544,-627,-890
564,392,-477
455,729,728
-892,524,684
-689,845,-530
423,-701,434
7,-33,-71
630,319,-379
443,580,662
-789,900,-551
459,-707,401

--- scanner 1 ---
686,422,578
605,423,415
515,917,-361
-336,658,858
95,138,22
-476,619,847
-340,-569,-846
567,-361,727
-460,603,-452
669,-402,600
729,430,532
-500,-761,534
-322,571,750
-466,-666,-811
-429,-592,574
-355,545,-477
703,-491,-529
-328,-685,520
413,935,-424
-391,539,-444
586,-435,557
-364,-763,-893
807,-499,-711
755,-354,-619
553,889,-390

--- scanner 2 ---
649,640,665
682,-795,504
-784,533,-524
-644,584,-595
-588,-843,648
-30,6,44
-674,560,763
500,723,-460
609,671,-379
-555,-800,653
-675,-892,-343
697,-426,-610
578,704,681
493,664,-388
-671,-858,530
-667,343,800
571,-461,-707
-138,-166,112
-889,563,-600
646,-828,498
640,759,510
-630,509,768
-681,-892,-333
673,-379,-804
-742,-814,-386
577,-820,562

--- scanner 3 ---
-589,542,597
605,-692,669
-500,565,-823
-660,373,557
-458,-679,-417
-488,449,543
-626,468,-788
338,-750,-386
528,-832,-391
562,-778,733
-938,-730,414
543,643,-506
-524,371,-870
407,773,750
-104,29,83
378,-903,-323
-778,-728,485
426,699,580
-438,-605,-362
-469,-447,-387
509,732,623
647,635,-688
-868,-804,481
614,-800,639
595,780,-596

--- scanner 4 ---
727,592,562
-293,-554,779
441,611,-461
-714,465,-776
-743,427,-804
-660,-479,-426
832,-632,460
927,-485,-438
408,393,-506
466,436,-512
110,16,151
-258,-428,682
-393,719,612
-211,-452,876
808,-476,-593
-575,615,604
-485,667,467
-680,325,-822
-627,-443,-432
872,-547,-609
833,512,582
807,604,487
839,-516,451
891,-625,532
-652,-548,-490
30,-46,-14
EOT

def cross_product(a, b)
  ax, ay, az = a
  bx, by, bz = b
  [ay * bz - az * by, az * bx - ax * bz, ax * by - ay * bx]
end

def cob(a_beacons, b_beacons)
  a_beacon_set = a_beacons.to_set
  @facings.each do |facing|
    ups = (@facings.map do |possibly_up|
      possibly_up if possibly_up.zip(facing).none? { |a, b| a.abs == b.abs && !a.zero? && !b.zero? }
    end).compact

    ups.each do |up|
      right = cross_product(facing, up)
      change_of_basis_matrix = Matrix.columns([facing, up, right])
      rotated_beacons = b_beacons.map { |beacon| (change_of_basis_matrix * Matrix.column_vector(beacon)).to_a.flatten }

      a_beacon_set.each do |a|
        rotated_beacons.each do |b|
          deltas = a.zip(b).map { |x, y| x - y }
          b_beacon_set = rotated_beacons.map { |beacon| beacon.zip(deltas).map { |x, y| x + y } }.to_set

          # pp a_beacon_set, b_beacon_set if (a_beacon_set & b_beacon_set).count >= 12

          return [change_of_basis_matrix, deltas] if (a_beacon_set & b_beacon_set).count >= 12
        end
      end
    end
  end
  nil
end

def transform(i, cob_mapping, scanners, results)
  puts "transform: #{i}"
  sequences = [[i]]

  next_sequences = Set[]
  loop do
    last_sum = sequences.map(&:count).sum
    # pp last_sum
    last_values = sequences.map(&:last).uniq
    last_values.each do |current|
      # pp "current: #{current}"
      next if current.zero?

      cob_mapping[current].each_key do |j|
        # pp "j: #{j}"
        sequences.select { |sequence| sequence.last == current }.each do |sequence|
          next_sequences << sequence + (sequence[-1].zero? || sequence.include?(j) ? [] : [j])
        end
        # pp "next_sequences: #{next_sequences}"
      end
    end
    sequences = next_sequences.to_a
    # next_sequences = Set[]
    # pp sequences
    break if sequences.map(&:count).sum == last_sum || sequences.map(&:last).include?(0)
    # pp "validation"
  end

  sequence = sequences.select { |s| s[-1].zero? && s[0] == i }.min_by(&:count)

  position = [0, 0, 0]
  current = i
  sequence.each do |j|
    next if j == current

    data = cob_mapping[current][j]
    # pp data
    position = (data[:cob_matrix] * Matrix.column_vector(position)).to_a.flatten
    position = position.zip(data[:deltas]).map { |x, y| x + y }

    results[i].map! { |beacon| (data[:cob_matrix] * Matrix.column_vector(beacon)).to_a.flatten }
    results[i].map! { |beacon| beacon.zip(data[:deltas]).map { |x, y| x + y } }

    current = j
  end

  position
end

@facings = [[-1, 0, 0], [0, -1, 0], [0, 0, -1], [1, 0, 0], [0, 1, 0], [0, 0, 1]]

data = File.read(ARGV[0])
lines = data.chomp.split("\n")

scanners = Hash.new { |scanners, number| scanners[number] = [] }
number = nil
lines.each do |line|
  next if line.empty?

  if line =~ /scanner (\d+)/
    number = Regexp.last_match(1).to_i
    puts "parsing scanner \##{number}"
    next
  end

  scanners[number] << line.split(',').map(&:to_i)
end

cob_mapping = Hash.new { |mapping, index| mapping[index] = {} }

destinations = [0]
origins = scanners.keys - [0]
new_destinations = destinations.dup
new_origins = origins.dup

loop do
  puts "origins: #{origins}"
  puts "destinations: #{destinations}"
  puts "(#{origins.count * destinations.count} loops)"
  destinations.each do |i|
    origins.each do |j|
      print '.'

      result = cob(scanners[i], scanners[j])

      next if result.nil?

      new_origins.delete(j)
      new_destinations << j

      data = {
        cob_matrix: result[0],
        deltas: result[1]
      }.freeze

      cob_mapping[j][i] = data
    end
    new_destinations.delete(i)
  end
  destinations = new_destinations.dup.uniq
  origins = new_origins.dup.uniq

  puts
  break if origins.empty?
end
puts "found #{cob_mapping.count} valid change of basis matricies"

results = {}
scanners.each_key do |i|
  results[i] = scanners[i].to_set
end

positions = [nil] * scanners.count
positions[0] = [0, 0, 0]
puts "total transforms: #{scanners.count - 1}"
scanners.each_key do |i|
  positions[i] = transform(i, cob_mapping, scanners, results) unless i.zero?
end

pp results.values.inject(&:|).count
pp (positions.combination(2).map do |a, b|
  (a[0] - b[0]).abs + (a[1] - b[1]).abs + (a[2] - b[2]).abs
end).max
