class EventsController < ApplicationController
  before_action :require_login

  def index
    @events = Event.search(params[:search] ||= "")
  end

end
