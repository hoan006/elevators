class Elevator  
  attr_reader :num_floors, :state, :direction
  
  IDLE = 1
  RUNNING = 2
  OPENING = 3
  OUT_OF_ORDER = 4

  NONE = 0
  UP = 1
  DOWN = 2
  
  # which floor this elevator should move to
  attr_reader :inside_floors, :outside_floors
  
  # current floor position (could be decimal)
  attr_reader :current_floor
  
  def initialize(num_floors = 15)
    @num_floors = num_floors
    @state = IDLE
    @direction = UP
    @current_floor = 1
    @inside_floors = []
    @outside_floors = []
  end
  
  def floors_to_go
    (self.inside_floors + self.outside_floors).sort
  end
  
  # trigger when a person touched a floor button inside the elevator
  def touch_button(floor)
    @inside_floors << floor
    @inside_floors.uniq!
  end
  
  # trigger when the system dispatches this target floor to this elevator
  def dispatch_floor(floor)
    @outside_floors << floor
    @outside_floors.uniq!
  end
  
  SPEED_PER_TICK = 0.5 # floor
  
  # after 1 tick (1 second), relocate the current floor
  def tick!
    # do nothing if there's no target floor to go
    if floors_to_go.empty?
      @state = IDLE
      return
    end
    
    # open the elevator if it's just reached one of the target floors
    # Assuming the opening time is 1 tick - The elevator should move on next tick if it has any remaining target floor
    if floors_to_go.include?(@current_floor)
      @state = OPENING
      @inside_floors.delete(@current_floor)
      @outside_floors.delete(@current_floor)
      return
    end

    lowest_floor = floors_to_go.first
    highest_floor = floors_to_go.last

    # relocate the location, depends on target floors & current direction
    @state = RUNNING
    if @current_floor < lowest_floor
      @current_floor = [@current_floor + SPEED_PER_TICK, lowest_floor].min
      @direction = UP
    elsif current_floor > highest_floor
      @current_floor = [@current_floor - SPEED_PER_TICK, highest_floor].max
      @direction = DOWN
    else # lowest_floor < current_floor < highest_floor
      if @state == IDLE
        # If the elevator is idle, pick the shorter direction
        @direction = highest_floor - @current_floor < @current_floor - lowest_floor ? UP : DOWN
      end

      # Follow the current direction
      if @direction == UP
        next_above_floor = floors_to_go.find{|floor| floor > @current_floor}
        throw "Moving up - Something wrong: #{self}" unless next_above_floor
        @current_floor = [@current_floor + SPEED_PER_TICK, next_above_floor].min
      else
        next_below_floor = floors_to_go.reverse.find{|floor| floor < @current_floor}
        throw "Moving down - Something wrong: #{self}" unless next_below_floor
        @current_floor = [@current_floor - SPEED_PER_TICK, next_below_floor].min
      end
    end
  end
end