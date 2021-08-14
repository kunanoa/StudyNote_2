class Event < ApplicationRecord

  def read_event_file
    @events = []
    File.open('app/models/event_log.txt') do |f|
      f.each_line do |subject|
        @events << subject.split(",")
      end
      # イベントの数が100を超える場合は、古い順からイベントを削除。
      count = f.lineno
      if count > 1000
        @events = @events[(count - 1000)..-1]
        delete_log(@events)
      end
    end
    @events
  end

  def self.write_event_file(message)
    File.open('app/models/event_log.txt', mode = "a") do |f|
      f.write("#{message}, #{Date.today} #{DateTime.now.hour}:#{DateTime.now.min}:#{DateTime.now.sec}\n")
    end
  end

  def delete_log(events)
    File.open('app/models/event_log.txt', mode = "w") do |f|
      events.each do |event|
        f.write("#{event}")
      end
    end
  end
end
