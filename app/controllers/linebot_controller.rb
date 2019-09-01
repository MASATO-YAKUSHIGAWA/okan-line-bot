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

    events = client.parse_events_from(body)
    events.each { |event|

    case event
    when Line::Bot::Event::Message
      case event.type
      when Line::Bot::Event::MessageType::Text
        input = event.message['text']
        url  = "https://www.drk7.jp/weather/xml/27.xml"
        xml  = open( url ).read.toutf8
        doc = REXML::Document.new(xml)
        xpath = 'weatherforecast/pref/area[1]/'

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
              "明日の天気だよね。\n明日は雨が降りそうだよ(>_<)\n今のところ降水確率はこんな感じだよ。\n　  6〜12時　#{per06to12}％\n　12〜18時　 #{per12to18}％\n　18〜24時　#{per18to24}％\nまた明日の朝の最新の天気予報で雨が降りそうだったら教えるね！"
          else
            push =
              "明日の天気？\n明日は雨が降らない予定だよ(^^)\nまた明日の朝の最新の天気予報で雨が降りそうだったら教えるね！"
          end
        end

      when Line::Bot::Event::MessageType::Location # 位置情報が入力された場合
        latitude = event.message['latitude'] # 緯度
        longitude = event.message['longitude'] # 経度


      end
  
    when Line::Bot::Event::Follow
      push = "こんにちは！\n位置情報を送ってね！"
      client.reply_message(event['replyToken'], location)

        #   # 登録したユーザーのidをユーザーテーブルに格納
        #   line_id = event['source']['userId']
        #   User.create(line_id: line_id)
        #   # LINEお友達解除された場合（機能③）
        # when Line::Bot::Event::Unfollow
        #   # お友達解除したユーザーのデータをユーザーテーブルから削除
        #   line_id = event['source']['userId']
        #   User.find_by(line_id: line_id).destroy
        # end
    end
    message = {
      "type": 'text',
      "text": push
    }
    client.reply_message(event['replyToken'], message)

    }
    head :ok
  end
  
  def location
    {
      "type": "template", #テンプレートメッセージオブジェクトの共通プロパティ
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
  end

  private

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET_ID"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

end
