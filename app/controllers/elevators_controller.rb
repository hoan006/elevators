require Rails.root + 'app/models/elevator_system'
require Rails.root + 'app/models/elevator'

class ElevatorsController < ApplicationController
  before_filter :load_system
  after_filter :save_system
  def index
    num_elevators = params[:e].try(:to_i) || 2
    num_floors = params[:f].try(:to_i) || 15
    if @system.elevators.size != num_elevators || @system.elevators.first.num_floors != num_floors
      @system = ElevatorSystem.new(num_elevators, num_floors)
    end
  end
  
  def change_configs
    redirect_to root_path(e: params[:e], f: params[:f])
  end
  
  def touch_outside
    floor = params[:floor].try(:to_i) || 0
    direction = params[:direction] || 'up'
    if direction == 'down'
      @system.touch_down_outside(floor)
    else
      @system.touch_up_outside(floor)
    end
    render 'update_state'
  end
  
  def touch_inside
    floor = params[:floor].try(:to_i) || 0
    index = params[:elevator].to_i
    @system.elevators[index].touch_button(floor)
    render 'update_state'
  end
  
  def update_state
  end
  
  private
  def load_system
    @system = Rails.cache.fetch("elevator_system") do
      ElevatorSystem.new
    end
  end
  
  def save_system
    Rails.cache.write("elevator_system", @system)
  end
end