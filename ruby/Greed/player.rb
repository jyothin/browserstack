class Player
  attr_accessor :number
  attr_accessor :is_playing
  attr_accessor :score
  attr_reader :total_score
  
  def initialize(number)
    @number = number
    @is_playing = false
    @score = Hash.new(0)
    @total_score = 0
  end
  
  def add_score(turn, score)
    @score[turn] = score
    @total_score += score
  end  
end
