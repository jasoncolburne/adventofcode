#!env ruby

require 'pp'

TEST_VECTORS = [
    [
        %w(R8 U5 L5 D3),  # 6
        %w(U7 R6 D4 L4)
    ],
    [
        %w(R75 D30 R83 U83 L12 D49 R71 U7 L72),  # 159
        %w(U62 R66 U55 R34 D71 R55 D58 R83)
    ],
    [
        %w(R98 U47 R26 D63 R33 U87 L62 D20 R33 U53 R51), # 135
        %w(U98 R91 D20 R16 D67 R40 U7 R15 U6 R7)
    ]
]

def create_line_segments(path)
    x = 0
    y = 0

    segments = []

    current_point = [x, y]
    path.each do |instruction|
        distance = instruction[1..].to_i

        case instruction[0].upcase
        when 'R'
            x += distance
        when 'U'
            y += distance
        when 'L'
            x -= distance
        when 'D'
            y -= distance
        else
            raise "unexpected instruction!"
        end

        next_point = [x, y]

        segments << [current_point, next_point]
        current_point = next_point
    end 
    
    segments
end

def compute_intersection(segment_a, segment_b)
    xa0 = segment_a[0][0]
    ya0 = segment_a[0][1]
    xa1 = segment_a[1][0]
    ya1 = segment_a[1][1]
    xb0 = segment_b[0][0]
    yb0 = segment_b[0][1]
    xb1 = segment_b[1][0]
    yb1 = segment_b[1][1]

    a_vertical = xa0 == xa1
    a_horizontal = !a_vertical
    b_vertical = xb0 == xb1
    b_horizontal = !b_vertical

    both_vertical = a_vertical && b_vertical
    both_horizontal = a_horizontal && b_horizontal

    return nil if both_vertical || both_horizontal

    if a_vertical && b_horizontal
        ya_range = ya0 < ya1 ? ya0..ya1 : ya1..ya0
        xb_range = xb0 < xb1 ? xb0..xb1 : xb1..xb0
        if ya_range.include?(yb0) && xb_range.include?(xa0)
            return [xa0, yb0]
        else
            return nil
        end
    elsif b_vertical && a_horizontal
        yb_range = yb0 < yb1 ? yb0..yb1 : yb1..yb0
        xa_range = xa0 < xa1 ? xa0..xa1 : xa1..xa0
        if yb_range.include?(ya0) && xa_range.include?(xb0)
            return [xb0, ya0]
        else
            return nil
        end
    else
        raise "unreachable(?) code!"
    end
end

def intersections(path_a, path_b)
    segments_a = create_line_segments(path_a)
    segments_b = create_line_segments(path_b)

    segments_a.map do |segment_a|
        segments_b.map do |segment_b|
            intersection = compute_intersection(segment_a, segment_b)
            [[0,0], nil].include?(intersection) ? nil : intersection
        end.compact
    end.flatten(1)
end

def distance_to_intersection(intersection, path)
    x = 0
    y = 0
    count = 0

    path.each do |instruction|
        distance = instruction[1..].to_i

        distance.times do
            case instruction[0].upcase
            when 'R'
                x += 1
            when 'U'
                y += 1
            when 'L'
                x -= 1
            when 'D'
                y -= 1
            else
                raise "unexpected instruction!"
            end
            count += 1

            return count if [x, y] == intersection 
        end
    end
    
    raise "point not on path!"
end

def manhattan_distance_from_closest_cross_to_origin(path_a, path_b)
    intersections = intersections(path_a, path_b)
    distances = intersections.map { |intersection| intersection[0].abs + intersection[1].abs }
    distances.min
end

def shortest_path_distance_to_intersection(path_a, path_b)
    intersections = intersections(path_a, path_b)
    distances = intersections.map do |intersection|
        distance_to_intersection(intersection, path_a) + distance_to_intersection(intersection, path_b)
    end
    distances.min
end

# pp compute_intersection([[8, 5], [3, 5]],[[6, 7], [6, 3]])
# pp TEST_VECTORS.map { |vectors| manhattan_distance_from_closest_cross_to_origin(vectors[0], vectors[1]) }
# pp TEST_VECTORS.map { |vectors| shortest_path_distance_to_intersection(vectors[0], vectors[1]) }

data = IO.readlines(ARGV.first).map(&:chomp).map { |line| line.gsub(',', ' ') }.map { |line| eval("%w(" + line + ")")}
# puts manhattan_distance_from_closest_cross_to_origin(data[0], data[1])
puts shortest_path_distance_to_intersection(data[0], data[1])