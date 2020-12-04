#!env ruby

require 'pp'
require './screen'

data = <<EOT
ecl:gry pid:860033327 eyr:2020 hcl:#fffffd
byr:1937 iyr:2017 cid:147 hgt:183cm

iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884
hcl:#cfa07d byr:1929

hcl:#ae17e1 iyr:2013
eyr:2024
ecl:brn pid:760753108 byr:1931
hgt:179cm

hcl:#cfa07d eyr:2025 pid:166559648
iyr:2011 ecl:brn hgt:59in
EOT

data = <<EOT
pid:087499704 hgt:74in ecl:grn iyr:2012 eyr:2030 byr:1980
hcl:#623a2f

eyr:2029 ecl:blu cid:129 byr:1989
iyr:2014 pid:896056539 hcl:#a97842 hgt:165cm

hcl:#888785
hgt:164cm byr:2001 iyr:2015 cid:88
pid:545766238 ecl:hzl
eyr:2022

iyr:2010 hgt:158cm hcl:#b6652a ecl:blu byr:1944 eyr:2021 pid:093154719
EOT

data = <<EOT
eyr:1972 cid:100
hcl:#18171d ecl:amb hgt:170 pid:186cm iyr:2018 byr:1926

iyr:2019
hcl:#602927 eyr:1967 hgt:170cm
ecl:grn pid:012533040 byr:1946

hcl:dab227 iyr:2012
ecl:brn hgt:182cm pid:021572410 eyr:2020 byr:1992 cid:277

hgt:59cm ecl:zzz
eyr:2038 hcl:74454a iyr:2023
pid:3556412378 byr:2007
EOT

data = File.read(ARGV[0])

lines = data.chomp.split("\n")

required_fields = %w(byr iyr eyr hgt hcl ecl pid)

passports = []
current_passport = {}
lines.each do |line|
  if line.empty?
    passports << current_passport
    current_passport = {}
  else
    line.split(' ').each do |pair|
      key, value = pair.split(':')
      current_passport[key] = value
    end
  end
end
passports << current_passport
puts passports.select { |passport| required_fields.all? {|field| passport.include?(field) }}.count

def validate(passport) 
  return false unless %w(byr iyr eyr hgt hcl ecl pid).all? { |field| passport.include?(field) }

  return false unless passport['byr'].to_i >= 1920 && passport['byr'].to_i <= 2002
  return false unless passport['iyr'].to_i >= 2010 && passport['iyr'].to_i <= 2020
  return false unless passport['eyr'].to_i >= 2020 && passport['eyr'].to_i <= 2030
  
  return false unless passport['hgt'] =~ /^(\d+)(cm|in)$/
  if $2 == 'cm'
    return false unless $1.to_i >= 150 && $1.to_i <= 193 
  else
    return false unless $1.to_i >= 59 && $1.to_i <= 76 
  end

  return false unless passport['hcl'] =~ /^#[0-9a-f]{6}$/
  return false unless %w(amb blu brn gry grn hzl oth).include?(passport['ecl'])
  
  return false unless passport['pid'] =~ /^\d{9}$/
  
  true
end

puts passports.select { |passport| validate(passport) }.count