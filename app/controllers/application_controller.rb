class ApplicationController < ActionController::Base
  around_action :set_time_zone

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  #Needed to ensure thread safety when using Time.zone
  def set_time_zone(&block)
    time_zone = cookies[:user_time_zone] || Time.zone.name
    Time.use_zone(time_zone, &block)
  end
end
