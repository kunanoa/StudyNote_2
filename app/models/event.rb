class Event < ApplicationRecord

  def read_event_file
    @events = []
    File.open("#{Rails.root}/log/#{Rails.env}/user.log") do |f|
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
    logger = Logger.new("#{Rails.root}/log/#{Rails.env}/user.log")
    logger.info(", #{current_user_name}, #{message}")
  end

  def self.date(start_time, end_time)
    date =[]
    start_time = Time.zone.local(start_time["{}(1i)"].to_i, start_time["{}(2i)"].to_i,
                    start_time["{}(3i)"].to_i, start_time["{}(4i)"].to_i, start_time["{}(5i)"].to_i)
    end_time = Time.zone.local(end_time["{}(1i)"].to_i, end_time["{}(2i)"].to_i,
                    end_time["{}(3i)"].to_i, end_time["{}(4i)"].to_i, end_time["{}(5i)"].to_i)
    date = start_time, end_time
  end

  def self.search(search, start_time, end_time)
    @events = []
    event = Event.new
    events = event.read_event_file

    # start_time と end_time がどちらかでも空である場合、search してないことを意味するので、events の値をそのまま渡す。
    if start_time.nil? || end_time.nil?
      @events = events
    # start_time と end_time がどちらも存在する場合、指定期間内で検索を実施する。
    elsif !start_time.nil? && !end_time.nil?
      events.each do |event|
        if (DateTime.parse("#{event[1]}") >= start_time) && (DateTime.parse("#{event[1]}") <= end_time)
          if event.join.include?(search) then
            @events << event
          end
        end
      end
    end
    @events
  end
end
