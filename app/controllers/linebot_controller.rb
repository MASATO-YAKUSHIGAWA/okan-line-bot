class LinebotController < ApplicationController
  require 'line/bot'  # gem 'line-bot-api'
  require 'open-uri'
  require 'kconv'
  require 'rexml/document'

  # callbackアクションのCSRFトークン認証を無効
  protect_from_forgery :except => [:callback]

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head :bad_request
    end
    events = client.parse_events_from(body)
    events.each { |event|
    line_id = event['source']['userId'] # line_id取得

    case event
    when Line::Bot::Event::Follow #フォローされた場合
      client.reply_message(event['replyToken'], first_message)

    when Line::Bot::Event::Unfollow # LINEお友達解除された場合、DBから削除する
      User.find_by(line_id: line_id).destroy
    
    when Line::Bot::Event::Message #メッセージが送られてきた場合
      case event.type
      when Line::Bot::Event::MessageType::Location # 位置情報が入力された場合
        lat = event.message['latitude'] # 緯度
        long = event.message['longitude'] # 経度
        push = "ありがとう"
        area = AreaInfo.find_by_sql(["select * from area_infos order by abs(latitude - ?) + abs(longitude - ?) ASC limit 1 ", lat, long]) #現在地から一番近い観測地点を取得
        if User.find_by(line_id: line_id)
          User.update(line_id: line_id, area_info_id: area.first.id) #ユーザー情報を更新
        else
          User.create(line_id: line_id, area_info_id: area.first.id) #ユーザー情報を保存
        end
      when Line::Bot::Event::MessageType::Text
        if User.find_by(line_id: line_id) #linee_id取得
          user = User.find_by(line_id: line_id)
          user_location = AreaInfo.find(user.area_info_id) #userの観測値情報取得
          input = event.message['text']
          url  = "https://www.drk7.jp/weather/xml/#{user_location.prep_id}.xml"
          xml  = open( url ).read.toutf8
          doc = REXML::Document.new(xml)
          xpath = "weatherforecast/pref/area[#{user_location.area_id}]/"

          min_per = 30
          case input
            # 「明日」or「あした」というワードが含まれる場合
          when /.*(明日|あした).*/
            # info[2]：明日の天気
            per06to12 = doc.elements[xpath + 'info[2]/rainfallchance/period[2]'].text
            per12to18 = doc.elements[xpath + 'info[2]/rainfallchance/period[3]'].text
            per18to24 = doc.elements[xpath + 'info[2]/rainfallchance/period[4]'].text
            if per06to12.to_i >= min_per || per12to18.to_i >= min_per || per18to24.to_i >= min_per
              push =
                "明日の天気だよね。\n明日の#{user_location.prep_name}、#{user_location.area_name}は雨が降りそうだよ(>_<)\n今のところ降水確率はこんな感じだよ。\n　  6〜12時　#{per06to12}％\n　12〜18時　 #{per12to18}％\n　18〜24時　#{per18to24}％\nまた明日の朝の最新の天気予報で雨が降りそうだったら教えるね！"
            else
              push =
                "明日の天気？\n明日の#{user_location.prep_name}、#{user_location.area_name}は雨が降らない予定だよ(^^)\nまた明日の朝の最新の天気予報で雨が降りそうだったら教えるね！"
            end

          when /.*(liff).*/
            push = "line://app/1607924018-2j0Dpx8j"
          end
        end
      end
  
      message = {
        "type": 'text',
        "text": push
      }
      client.reply_message(event['replyToken'], message)
    end
  }
  head :ok
end
  
  def first_message
    [
      {"type": 'text',
      "text": "こんにちは！\n現在位置を送ってね！"},
      {"type": "template", #テンプレートメッセージオブジェクトの共通プロパティ
        "altText": "位置検索中",
        "template": {          #テンプレート指定
            "type": "buttons", #ボタンテンプレート使用
            "title": "現在位置検索",
            "text": "現在の位置を送信しますか？",
            "actions": [
                {
                  "type": "uri",
                  "label": "現在位置を送る",
                  "uri": "line://nv/location" #位置情報画を開くスキーム
                }
            ]
        }
      }
    ]
  end


  def garbage
    render "linebot/garbage"
  end

  private

  def client
    @client ||= Line::Bot::Client.new { |config|
      # 本番環境
    config.channel_secret = "f25a9c6c930126ad7d1f291e3771b4a8"
    config.channel_token = "8BvTmnSr8fP37Hq3EEhaxtQLPpngKgv4tlK/Mpml90NsR9N4UjVx5Iudtg07AQ16NqTsuITHGmdXQ/PsaHqDiB1pHPA6ivNLOozl2MIdJqQzf3PbnV3C+5m+kVpTt2cx/YaYXAj9tRH2+GNgX6R9hgdB04t89/1O/w1cDnyilFU="
    }
  end

end
