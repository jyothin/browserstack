# https://gist.github.com/AnkurGel/e6bdda184fdcce6d22cc0ba36040fc45
=begin
The player may continue to roll as long as each roll scores points. If
a roll has zero points, then the player loses not only their turn, but
also accumulated score for that turn. If a player decides to stop
rolling before rolling a zero-point roll, then the accumulated points
for the turn is added to his total score.
=end

require_relative "player"
require_relative "dice_set"

class Game
  
  FINAL_ROUND_SCORE = 3000
  MIN_SCORE_TO_START = 300
  NUMBER_OF_DICE = 5

  def initialize
    @players = Hash.new()
    @push_stack = Array.new()
    @turn_stack = Array.new()
    @inner_turn_stack = Array.new()
    @final_round = false
  end

  def start_game
    print "Enter number of players: "
    num_of_players = gets.chomp
    num_of_players = num_of_players.to_i
    
    puts "Invalid number of players" if num_of_players <= 0
    return if num_of_players <= 0
  
    num_of_players.times { |n|
      @players[n+1] = Player.new(n+1)
      @push_stack << @players[n+1]
    }
    
    turn = 0
    
    while @push_stack.length != 0 || @turn_stack.length != 0
      @push_stack, @turn_stack = @turn_stack, @push_stack
    
      turn += 1
      
      if !@final_round
        puts "Turn #{turn}:"
        puts "-------"
      else
        puts "Final round"
        puts "-----------"
      end
      
      accumulated_score = 0
      
      while current_player = @turn_stack.shift
        @inner_turn_stack.push(NUMBER_OF_DICE)
        
        while num_of_dices_to_roll = @inner_turn_stack.shift
          dice_set = DiceSet.new(num_of_dices_to_roll)
          dice_set.roll
          dices = dice_set.dices
          score = dice_set.score
          
          #ns_dices = Array.new()
          #dices.each { |x| ns_dices << x if ((x != 1) && (x != 5)) }
          ns_dices = dice_set.get_ns_dices
          
          current_player.is_playing = true if !current_player.is_playing && 
            score >= MIN_SCORE_TO_START
          accumulated_score += score
          
          puts "Player #{current_player.number} rolls: #{dices}"
          puts "Score in this roll: #{score}"
          
          if score != 0
            puts "Accumulated score for this turn: #{accumulated_score}"
            if current_player.is_playing
              if ns_dices.length > 0
                print "Do you want to roll again? (y/n): "
                prompt = gets.chomp
                
                if prompt == "n"
                  current_player.add_score(turn, accumulated_score)
                  puts "Total score: #{current_player.total_score}"
                  @final_round = true if current_player.total_score >= 3000
                  break
                end
                
                puts "Invalid response... assuming 'y' ;-) You're a risk taker" if prompt != "y"
                
                if ns_dices.length == 0
                  @inner_turn_stack.push(NUMBER_OF_DICE)
                else
                  @inner_turn_stack.push(ns_dices.length)
                end
                
              else
                current_player.add_score(turn, accumulated_score)
                puts "Total score: #{current_player.total_score}"
                @final_round = true if current_player.total_score >= 3000
                break
              end
            else
              puts "Total score: #{current_player.total_score}"
            end
          else
            puts "You lost your turn!"
            accumulated_score = 0
            puts "Accumulated score for this turn: #{accumulated_score}"
            puts "Total score: #{current_player.total_score}"
            if current_player.total_score == 0
              current_player.is_playing = false
            end
          end
          
          @final_round = true if current_player.total_score >= 3000
          
        end
        @push_stack.push(current_player) if current_player.total_score < 3000
      end
      
      puts
    end
    
    player_scores = Array.new()
    @players.values.each { |p| player_scores << p.total_score }
    max_score = player_scores.max
    winner = Array.new()
    @players.each { |k, v| winner << k if v.total_score == max_score }
    
    if winner.length > 1
      puts "Game is a draw!"
      winner.each { |w| puts "Winner is player #{w} with score #{max_score}" }
    else
      puts "We have a winner!"
      puts "Winner is player #{winner} with score #{max_score}"
    end
    
  end
end
