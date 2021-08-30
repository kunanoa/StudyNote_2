class EventsController < ApplicationController
  before_action :require_login

  def index
    @events = Event.search(params[:search] ||= "")

    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "イベント.csv", type: :csv
        Event.logger_info(current_user.name, "CSVファイル（イベント）をダウンロードしました")
      end
    end
  end
end
