desc "This task is called by the Heroku scheduler add-on"
task :update_feed => :environment do
  require 'line/bot'  # gem 'line-bot-api'
  require 'open-uri'
  require 'kconv'
  require 'rexml/document'
  require 'dotenv'

  client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
   # メッセージの発信先idを配列で渡す必要があるため、userテーブルよりpluck関数を使ってidを配列で取得
   user_ids = User.all.pluck(:line_id) #user_ids = [user_id1, user_id2, ...]

   user_ids.each do |user_id|
    user = User.find_by(line_id: user_id)
    user_location = AreaInfo.find(user.area_info_id) #userの観測値情報取得

    url  = "https://www.drk7.jp/weather/xml/#{user_location.prep_id}.xml"
    # xmlデータをパース（利用しやすいように整形）
    xml  = open( url ).read.toutf8
    doc = REXML::Document.new(xml)
    # パスの共通部分を変数化（area[1]は「大阪地方」を指定している）
    xpath = "weatherforecast/pref/area[#{user_location.area_id}]/info/rainfallchance/"
    # 6時〜12時の降水確率（以下同様）
    per06to12 = doc.elements[xpath + 'period[2]'].text
    per12to18 = doc.elements[xpath + 'period[3]'].text
    per18to24 = doc.elements[xpath + 'period[4]'].text
  
     # 降水確率によってメッセージを変更する閾値の設定
    mid_per = 40
    if per06to12.to_i >= mid_per || per12to18.to_i >= mid_per || per18to24.to_i >= mid_per
      word3 = "今日は雨や！傘忘れたらあかんで！"
      word3 = "今日は雨かもしやんから、折りたたみでも持っていき！！"
     # 発信するメッセージの設定
      push =
       "#{word3}\n降水確率はこんなもんや\n　  6〜12時　#{per06to12}％\n　12〜18時　 #{per12to18}％\n　18〜24時　#{per18to24}％"
    end

    message = {
      type: 'text',
      text: push
    }
    client.multicast(user_id, message)
 
    end
 "OK"
end