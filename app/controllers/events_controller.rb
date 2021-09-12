class EventsController < ApplicationController
  before_action :require_login

  def index
    @start_time_custom = nil
    @end_time_custom = nil

    unless params[:start_time].nil? && params[:end_time].nil?
      date = Event.date(params[:start_time], params[:end_time])
      @start_time_custom = date[0]
      @end_time_custom = date[1]
    end

    @events = Event.search(params[:search] ||= "", @start_time_custom, @end_time_custom)

    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "イベント.csv", type: :csv
        Event.logger_info(current_user.name, "CSVファイル（イベント）をダウンロードしました")
      end
    end
  end  

  def sample_action
    render body: nil
  end
end
