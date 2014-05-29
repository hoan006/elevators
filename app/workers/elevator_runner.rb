class ElevatorRunner
  @queue = :runner
  
  def self.perform
    start_time = Time.now
    while true
      @system = Rails.cache.read("elevator_system")
      if @system
        @system.elevators.each(&:tick!)
        Rails.cache.write("elevator_system", @system)
      end
      sleep(1.0)
      break if Time.now - start_time > 30 * 3600
    end
  end
end