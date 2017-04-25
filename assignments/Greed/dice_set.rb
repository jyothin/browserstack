class DiceSet
  def initialize(count)
    @count = count
    @hash = Hash.new(0)
    @stack = Array.new
  end
  
  def roll
    @dices = Array.new
    random = Random.new
    @count.times.each { |n| 
        r = (((random.rand() * 10) % 5) + 1)
        r = (r - (r % 1)) 
        @dices << r.round
    }
  end

  def dices
      @dices
  end

  def score
    @dices.each { |n| 
      @hash[n] += 1;
    }
    @hash.keys.each { |key| @stack.push(key) }
    score = 0 
    while key = @stack.pop() do
      if key == 1
          if @hash[key] >= 3
              score += 1000
              @hash[key] -= 3
              @stack.push(key) unless @hash[key] == 0
          else
              score += (@hash[key] * 100)
              @hash[key] -= @hash[key]
          end
      else
          if @hash[key] >= 3
              score += (key * 100)
              @hash[key] -= 3
              @stack.push(key) unless @hash[key] == 0
          else
              score += (@hash[key] * 50) if key == 5
          end
      end
    end
    return score
  end
  
end