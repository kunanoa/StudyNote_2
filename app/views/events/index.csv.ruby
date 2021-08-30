require 'csv'
require 'nkf'
csv_data = CSV.generate do |csv|
  csv << %w(時刻 レベル 実行ユーザ イベント内容)
  @events.each do |event|
    csv << [
        event[1],
        event[0],
        event[2],
        event[3]
    ]
  end
end
# 文字コードを強制的に変換する為
NKF::nkf('--sjis -Lw', csv_data)