class ElevatorSystem
  attr_reader :elevators
  
  def initialize(num_elevators = 2, num_floors = 15)
    @elevators = []
    0.upto(num_elevators - 1).each do
      @elevators << Elevator.new(num_floors)
    end
  end
  
  # trigger when someone waiting for elevator at some floor touch the UP button on the wall
  def touch_up_outside(floor)
    return if floor == @elevators.first.num_floors
    dispatch_touch(floor, Elevator::UP)
  end
  
  # trigger when someone waiting for elevator at some floor touch the DOWN button on the wall
  def touch_down_outside(floor)
    return if floor == 1
    dispatch_touch(floor, Elevator::DOWN)
  end
  
  private

  # Which elevator should receive this target floor
  def dispatch_touch(floor, direction)
    # Find some idle elevator if possible
    idle_elevator = self.elevators.find{ |elevator| elevator.state == Elevator::IDLE }
    if idle_elevator
      idle_elevator.dispatch_floor(floor)
      return
    end
    
    # Find the closest elevator which is moving in the same direction
    closest_elevator = nil
    self.elevators.each do |elevator|
      next if elevator.direction != direction
      if closest_elevator.nil? || (elevator.current_floor - floor).abs < (closest_elevator.current_floor - floor).abs
        closest_elevator = elevator
      end
    end
    if closest_elevator
      closest_elevator.dispatch_floor(floor)
      return
    end
    
    # Last resort: Find the elevator that seems to move to this floor faster
    best_elevator = nil
    best_estimated_time = nil
    self.elevators.each do |elevator|
      estimated_time = (elevator.current_floor - floor).abs / Elevator::SPEED_PER_TICK # time to move
      floors_to_open = elevator.floors_to_go.select{ |f| elevator.direction == Elevator::UP ? (f > floor) : (f < floor) }
      estimated_time += floors_to_open # time to open on each target floor before it reaches this 'floor'
      if best_estimated_time.nil? || best_estimated_time > estimated_time
        best_estimated_time = estimated_time
        best_elevator = elevator
      end
    end
    best_elevator.dispatch_floor(floor)
  end
end
