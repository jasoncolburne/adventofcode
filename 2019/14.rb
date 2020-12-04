#!env ruby

require 'pp'

def parse_chemical(chemical)
  quantity, name = chemical.split(' ')
  {
    name: name,
    quantity: quantity.to_i
  }
end

def parse_reactions(data)
  data.chomp.split("\n").map do |line|
    inputs, output = line.split(" => ")
    {
      inputs: inputs.split(", ").map { |input| parse_chemical(input) },
      output: parse_chemical(output)
    }
  end
end

def find_reaction_by_output_name(name, reactions)
  reactions.find { |reaction| reaction[:output][:name] == name }
end

def init_leftovers(reactions)
  reactions.map { |reaction| [reaction[:output][:name], 0] }.to_h
end

def determine_ore_required(name, quantity, reactions, leftovers = {})
  leftovers = init_leftovers(reactions) if leftovers.empty?

  reaction = find_reaction_by_output_name(name, reactions)

  quantity_required = (quantity - leftovers[name]) < 0 ? 0 : quantity - leftovers[name]
  leftovers[name] -= quantity - quantity_required

  multiplier = (quantity_required.to_f / reaction[:output][:quantity].to_f).ceil
  total_produced = multiplier * reaction[:output][:quantity]
  leftover = total_produced - quantity_required

  inputs = reaction[:inputs]
  ore = if inputs.size == 1 && inputs.first[:name] == 'ORE'
    inputs.first[:quantity] * multiplier
  else
    inputs.map do |output|
      determine_ore_required(output[:name], output[:quantity] * multiplier, reactions, leftovers)
    end.inject(&:+)
  end

  leftovers[name] += leftover
  ore
end

def binary_search(reactions, ore_quantity, lower_bound, upper_bound)
  return lower_bound if upper_bound - lower_bound < 2

  guess = (upper_bound + lower_bound) / 2
  ore = determine_ore_required('FUEL', guess, reactions)
  return guess if ore == ore_quantity
  
  if ore < ore_quantity
    binary_search(reactions, ore_quantity, guess, upper_bound)
  else
    binary_search(reactions, ore_quantity, lower_bound, guess)
  end
end

def maximum_fuel_produced(reactions, ore_quantity)
  guess = 100
  guess *= 10 while determine_ore_required('FUEL', guess, reactions) < ore_quantity
  
  upper_bound = guess
  lower_bound = guess / 10

  # binary search
  binary_search(reactions, ore_quantity, lower_bound, upper_bound)
end

# data = <<EOT
# 10 ORE => 10 A
# 1 ORE => 1 B
# 7 A, 1 B => 1 C
# 7 A, 1 C => 1 D
# 7 A, 1 D => 1 E
# 7 A, 1 E => 1 FUEL
# EOT

# data = <<EOT
# 9 ORE => 2 A
# 8 ORE => 3 B
# 7 ORE => 5 C
# 3 A, 4 B => 1 AB
# 5 B, 7 C => 1 BC
# 4 C, 1 A => 1 CA
# 2 AB, 3 BC, 4 CA => 1 FUEL
# EOT

# data = <<EOT
# 157 ORE => 5 NZVS
# 165 ORE => 6 DCFZ
# 44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL
# 12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ
# 179 ORE => 7 PSHF
# 177 ORE => 5 HKGWZ
# 7 DCFZ, 7 PSHF => 2 XJWVT
# 165 ORE => 2 GPVTF
# 3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT
# EOT

# data = <<EOT
# 2 VPVL, 7 FWMGM, 2 CXFTF, 11 MNCFX => 1 STKFG
# 17 NVRVD, 3 JNWZP => 8 VPVL
# 53 STKFG, 6 MNCFX, 46 VJHF, 81 HVMC, 68 CXFTF, 25 GNMV => 1 FUEL
# 22 VJHF, 37 MNCFX => 5 FWMGM
# 139 ORE => 4 NVRVD
# 144 ORE => 7 JNWZP
# 5 MNCFX, 7 RFSQX, 2 FWMGM, 2 VPVL, 19 CXFTF => 3 HVMC
# 5 VJHF, 7 MNCFX, 9 VPVL, 37 CXFTF => 6 GNMV
# 145 ORE => 6 MNCFX
# 1 NVRVD => 8 CXFTF
# 1 VJHF, 6 MNCFX => 4 RFSQX
# 176 ORE => 6 VJHF
# EOT

# data = <<EOT
# 171 ORE => 8 CNZTR
# 7 ZLQW, 3 BMBT, 9 XCVML, 26 XMNCP, 1 WPTQ, 2 MZWV, 1 RJRHP => 4 PLWSL
# 114 ORE => 4 BHXH
# 14 VRPVC => 6 BMBT
# 6 BHXH, 18 KTJDG, 12 WPTQ, 7 PLWSL, 31 FHTLT, 37 ZDVW => 1 FUEL
# 6 WPTQ, 2 BMBT, 8 ZLQW, 18 KTJDG, 1 XMNCP, 6 MZWV, 1 RJRHP => 6 FHTLT
# 15 XDBXC, 2 LTCX, 1 VRPVC => 6 ZLQW
# 13 WPTQ, 10 LTCX, 3 RJRHP, 14 XMNCP, 2 MZWV, 1 ZLQW => 1 ZDVW
# 5 BMBT => 4 WPTQ
# 189 ORE => 9 KTJDG
# 1 MZWV, 17 XDBXC, 3 XCVML => 2 XMNCP
# 12 VRPVC, 27 CNZTR => 2 XDBXC
# 15 KTJDG, 12 BHXH => 5 XCVML
# 3 BHXH, 2 VRPVC => 7 MZWV
# 121 ORE => 7 VRPVC
# 7 XCVML => 6 RJRHP
# 5 BHXH, 4 VRPVC => 5 LTCX
# EOT

data = File.read(ARGV[0])

reactions = parse_reactions(data)
puts determine_ore_required('FUEL', 1, reactions)
puts maximum_fuel_produced(reactions, 1000000000000)
