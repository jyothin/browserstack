'''
https://gist.github.com/AnkurGel/d4eb058e1f4fd5c76255671327db70a4
'''
require_relative "Plateau"

if ARGV.length == 0
  puts "Usage: ruby explore.rb \"filename.dat\""
  exit
end

fname = ARGV[0]
if fname == nil || fname == ""
  puts "Invalid filename"
  exit
end
  
file = File.new(fname, "r")  
size = file.gets.chomp
size = size.split(" ")
w, h = size[0].to_i, size[1].to_i

plateau = Plateau.new(w, h)

while line = file.gets
  line = line.chomp
  start = line
  start = start.split(" ")
  x, y, d = start[0].to_i, start[1].to_i, start[2]
  plateau.start(x, y, d)
  path = file.gets.chomp
  path = path.chars.each { |x| x.upcase }
  path.each { |m| plateau.move(m) }
  (f_x, f_y, f_d) = plateau.get_rover_position
  puts "#{f_x} #{f_y} #{f_d}"
end
file.close
