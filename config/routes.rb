Elevators::Application.routes.draw do
  root to: "elevators#index"
  post "/change_configs" => "elevators#change_configs"
  post "/touch_outside" => "elevators#touch_outside", format: :js
  post "/touch_inside" => "elevators#touch_inside", format: :js
  post "/update_state" => "elevators#update_state", format: :js

  mount Resque::Server, :at => "/resque"
end
