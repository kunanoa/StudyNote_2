class EventsController < ApplicationController
  before_action :require_login

  def index
    event = Event.new
    @events = event.read_event_file
  end

end
