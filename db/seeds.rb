require 'csv'

csv_data = CSV.read('db/jp_area_infos.csv', headers: true)
csv_data.each do |data|
  AreaInfo.create!(data.to_hash)
end