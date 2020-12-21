#!/usr/bin/env ruby

require 'set'

data = <<EOT
mxmxvkd kfcds sqjhc nhms (contains dairy, fish)
trh fvjkl sbzzf mxmxvkd (contains dairy)
sqjhc fvjkl (contains soy)
sqjhc mxmxvkd sbzzf (contains fish)
EOT

data = File.read(ARGV[0])

lines = data.chomp.split("\n")

safe_ingredients = Set[]
ingredients_by_allergen = {}

lines.each do |line|
  ingredients_text, allergens_text = line.split(' (contains ')

  ingredients = ingredients_text.split(' ').to_set
  allergens = allergens_text.chomp(')').split(', ')

  safe_ingredients |= ingredients

  allergens.each do |allergen|
    if ingredients_by_allergen.include?(allergen)
      ingredients_by_allergen[allergen] &= ingredients
    else
      ingredients_by_allergen[allergen] = ingredients
    end
  end
end

safe_ingredients -= ingredients_by_allergen.values.inject(&:union)

puts (lines.map do |line|
  ingredients = line.split(' (contains ')[0].split(' ')
  (ingredients.map do |ingredient|
    safe_ingredients.include?(ingredient) ? 1 : 0
  end).sum
end).sum

allergens_identified = Set[]
allergens = ingredients_by_allergen.keys.sort { |allergen| ingredients_by_allergen[allergen].count }
until ingredients_by_allergen.values.all? { |ingredients| ingredients.count == 1 }
  ingredients_by_allergen.select { |allergen, ingredients| ingredients.count == 1 }.each do |allergen, ingredients|
    allergens_identified << allergen
    ingredients_by_allergen.keys.reject { |allergen| allergens_identified.include?(allergen) }.each do |allergen|
      ingredients_by_allergen[allergen] -= ingredients
    end
  end
end

puts ingredients_by_allergen.keys.sort.map { |allergen| ingredients_by_allergen[allergen].to_a.first }.join(',')
