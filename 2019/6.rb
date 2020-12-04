#!env ruby

require 'pp'

input = IO.readlines(ARGV[0]).map(&:chomp).map do |line|
    components = line.split(')')
    { orbitee: components[0], orbiter: components[1] }
end

module Orbit
    class Node
        attr_reader   :name
        attr_reader   :children
        attr_accessor :parent

        def initialize(name, parent)
            @parent = parent
            @name = name
            @children = []
        end

        def depth
            @parent.nil? ? 0 : parent.depth + 1
        end

        def has_child(name)
            children.any? { |child| child.name == name || child.has_child(name) }
        end
    end

    class Tree
        attr_reader :all_nodes

        def initialize(array)
            @all_nodes = []

            array.each do |orbit|
                orbitee = find(orbit[:orbitee])
                if orbitee.nil?
                    orbitee = Node.new(orbit[:orbitee], nil)
                    @all_nodes << orbitee
                end

                orbiter = find(orbit[:orbiter])
                if orbiter.nil?
                    orbiter = Node.new(orbit[:orbiter], orbitee)
                    @all_nodes << orbiter
                else
                    orbiter.parent = orbitee
                end

                orbitee.children << orbiter
            end
        end

        def find(name)
            @all_nodes.find { |node| node.name == name }
        end

        def depth(name)
            find(name).depth
        end

        def count_orbits
            @all_nodes.map { |node| node.depth }.inject(&:+)
        end

        def transfers_between(a, b)
            
        end

        def minimum_transfers(name_a, name_b)
            a = find(name_a)
            b = find(name_b)

            raise "unexpected initial state" unless a.children.empty? && b.children.empty?
            
            distance = -2

            location = a
            while(!location.has_child(name_b)) do
                distance += 1
                location = location.parent
            end

            location = b
            while(!location.has_child(name_a)) do
                distance += 1
                location = location.parent
            end

            distance
        end
    end
end

tree = Orbit::Tree.new(input)
puts tree.count_orbits
puts tree.minimum_transfers('YOU', 'SAN')
