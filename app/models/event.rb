class Event < ApplicationRecord

  def read_event_file
    @events = []
    File.open("#{Rails.root}/log/user.log") do |f|
      f.each_line do |subject|
        unless /^#/ =~ subject
          subject = subject.split(",")
          subject[0] = subject[1].split(" ")[2]
          subject[1] = subject[1].split(" ")[0][1..19]
          subject[1] = subject[1].sub!(/T/, ' ')
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
end
