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
  end

  def start_game
    print "Enter number of players: "
    num_of_players = gets.chomp
    num_of_players = num_of_players.to_i
    
    puts "Invalid number of players" if num_of_players <= 0
  
    num_of_players.times { |n|
      @players[n+1] = Player.new(n+1)
      @push_stack << @players[n+1]
    }
    
    turn = 0
    final_round = false
    dice_set = DiceSet.new(NUMBER_OF_DICE)
    
    while @push_stack.length != 0 || @turn_stack.length != 0
      @push_stack, @turn_stack = @turn_stack, @push_stack
    
      turn += 1
      if !final_round
        puts "Turn #{turn}:"
        puts "-------"
      else
        puts "Final round"
        puts "-----------"
      end
      
      while current_player = @turn_stack.shift
        dice_set.roll
        dices = dice_set.dices
        score = dice_set.score
  
        current_player.is_playing = true if !current_player.is_playing && score >= 300      
        current_player.add_score(turn, score) if current_player.is_playing
        
        puts "Player #{current_player.number} rolls: #{dices}"
        puts "Score in this round: #{score}"
        puts "Total score: #{current_player.total_score}"
  
        # TODO
        do_all_s_dices_stuff(turn, current_player)      
        do_ns_dices_stuff(turn, current_player, dices)
          
        if !final_round
          if current_player.total_score >= 3000
            final_round = true
          else
            @push_stack.push(current_player)
          end
        end
      end
            
      puts
    end
    
    player_scores = Array.new()
    @players.values.each { |p| player_scores << p.total_score }
    max_score = player_scores.max
    winner = 0
    @players.each { |k, v| winner = k if v.total_score == max_score }
    
    puts "Winner is player #{winner} with score #{max_score}"  
  end
  
  
      
  def do_all_s_dices_stuff(turn, current_player)
    
  end
  
  def do_ns_dices_stuff(turn, current_player, dices)
      ns_dices = Array.new()
      dices.each { |x| ns_dices << x if ((x != 1) && (x != 5)) }
      
      prompt = "n"
      
      if ns_dices.length > 0
        print "Do you want to roll the non-scoring #{ns_dices.length} dices? (y/n): "
        prompt = gets.chomp
      end
      
      return if prompt == "n"
      puts "Invalid response... assuming 'y' ;-) You're a risk taker" if prompt != "y"

      dice_set = DiceSet.new(ns_dices.length)
      dice_set.roll
      n_dices = dice_set.dices
      score = dice_set.score
      current_player.add_score(turn+0.5, score)

      puts "Player #{current_player.number} rolls: #{n_dices}"
      puts "Score in this round: #{score}"
      puts "Total score: #{current_player.total_score}"
  end
  
end