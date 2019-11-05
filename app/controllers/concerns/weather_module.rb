module Weather
  def tomorrow_weather
    url  = "https://www.drk7.jp/weather/xml/#{$user_location.prep_id}.xml"
    xml  = open( url ).read.toutf8
    doc = REXML::Document.new(xml)
    xpath = "weatherforecast/pref/area[#{$user_location.area_id}]/"

    min_per = 30

    per06to12 = doc.elements[xpath + 'info[2]/rainfallchance/period[2]'].text
    per12to18 = doc.elements[xpath + 'info[2]/rainfallchance/period[3]'].text
    per18to24 = doc.elements[xpath + 'info[2]/rainfallchance/period[4]'].text
    if per06to12.to_i >= min_per || per12to18.to_i >= min_per || per18to24.to_i >= min_per
      push =
        "明日の天気？\n明日の#{$user_location.prep_name}、#{$user_location.area_name}は雨降りそうやで\n今のところ、\n 6〜12時 #{per06to12}％\n 12〜18時 #{per12to18}％\n 18〜24時 #{per18to24}％\nこんな感じや\nまた明日の朝に雨降りそうやったら教えたるわ！"
    else
      push =
        "明日の天気？\n明日の#{$user_location.prep_name}、#{$user_location.area_name}は雨降らんと思うで\nまた明日の朝に雨降りそうやったら教えたるわ！"
    end

    message = {
      "type": 'text',
      "text": push
    }
    client.reply_message(params[:events][0]['replyToken'], message)

  end
end