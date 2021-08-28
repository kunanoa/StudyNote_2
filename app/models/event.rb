class Event < ApplicationRecord

  def read_event_file
    @events = []
    File.open("#{Rails.root}/log/user.log") do |f|
      f.each_line do |subject|
        unless /^#/ =~ subject
          subject = subject.split(",")
          subject[0] = subject[1].split(" ")[2]    # username
          log_time = subject[1].split(" ")[0][1..19]    # ex) 2021-08-28T11:11:40
          subject[1] = Time.parse(log_time).in_time_zone("Tokyo")
          @events << subject
        end
      end
    end
    @events
  end

  def self.logger_info(current_user_name, message)
    logger = Logger.new("#{Rails.root}/log/user.log")
    logger.info(", #{current_user_name}, #{message}")
  end

  def self.search(search)
    @events = []
    event = Event.new
    events = event.read_event_file
    events.each do |event|
      if event.join.include?(search) then
        @events << event
      end
    end
    @events
  end
end
