class Plateau
  def initialize(w, h)
    # Check for boundary conditions
    # raise an exception if boundary conditions are not met
    @w = w
    @h = h
    @rover = nil
    @rovers = Array.new()
  end
  
  def start(x, y, d)
    @rover = Rover.new(x, y, d)
    @rovers << @rover
    #puts "#{@rover.x}, #{@rover.y}, #{@rover.d}"
  end
  
  def move(step)
    case step
    when "M"
      (new_x, new_y, new_d) = move_step(@rover.x, @rover.y, @rover.d)
      if valid_move(new_x, new_y, new_d)
        @rover.x, @rover.y, @rover.d = new_x, new_y, new_d
      end
      #puts "#{step}: #{@rover.x}, #{@rover.y}, #{@rover.d}"
    when "L"
      change_d(step)
      #puts "#{step}: #{@rover.x}, #{@rover.y}, #{@rover.d}"
    when "R"
      change_d(step)
      #puts "#{step}: #{@rover.x}, #{@rover.y}, #{@rover.d}"
    end
  end
  
  def get_rover_position
    return @rover.x, @rover.y, @rover.d
  end
  
  private
  def change_d(turn)
    if turn == "L"
      case @rover.d
      when "N"
        @rover.d = "W"
      when "E"
        @rover.d = "N"
      when "S"
        @rover.d = "E"
      when "W"
        @rover.d = "S"
      end
    elsif turn == "R"
      case @rover.d
      when "N"
        @rover.d = "E"
      when "E"
        @rover.d = "S"
      when "S"
        @rover.d = "W"
      when "W"
        @rover.d = "N"
      end
    end
  end

  def valid_move(x, y, d)
    boundary_condition = true
    boundary_condition = false if x < 0 || y < 0 || x > @w || y > @h
    collision_condition = false
    @rovers.each { |rover| collision_condition = true if x == rover.x && y == rover.y }
    #puts "#{boundary_condition}, #{collision_condition}"
    return boundary_condition & !collision_condition
  end
  
  def move_step(x, y, d)
    case d
    when "N"
      return x, y+1, d
    when "E"
      return x+1, y, d
    when "S"
      return x, y-1, d
    when "W"
      return x-1, y, d
    end
  end
end
