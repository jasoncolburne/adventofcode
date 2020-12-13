#!/usr/bin/env ruby

def test_adjacent_digits_v1(value)
    last = nil
    while value > 0
        return true if last == value % 10
        last = value % 10
        value /= 10
    end
    false
end

def test_adjacent_digits(value)
    last = nil
    counter = 1
    while value > 0
        future = value % 10
        
        if last == future
            counter += 1
        else
            return true if counter == 2
            counter = 1
        end

        last = future
        value /= 10
    end
    counter == 2
end

def test_increasing(value)
    last = nil
    while value > 0
        future = value % 10
        return false unless last.nil? || future <= last
        last = future
        value /= 10
    end
    true
end

def test_value(value)
    test_adjacent_digits(value) && test_increasing(value)
end

range = 206938..679128
range.each do |value|
    puts value if test_value(value)
end

