class LinebotController < ApplicationController
  require 'line/bot'  # gem 'line-bot-api'
  require 'open-uri'
  require 'kconv'
  require 'rexml/document'
  require 'dotenv'
  require 'date'

  # callbackアクションのCSRFトークン認証を無効
  protect_from_forgery :except => [:callback]

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head :bad_request
    end
    @events = client.parse_events_from(body)
    @events.each { |event|
    line_id = event['source']['userId'] # line_id取得

    case event
    when Line::Bot::Event::Follow #フォローされた場合
      client.reply_message(event['replyToken'], first_message)

    when Line::Bot::Event::Unfollow # LINEお友達解除された場合、DBから削除する
      User.find_by(line_id: line_id).destroy

    when Line::Bot::Event::Postback
      postback_data = event["postback"]["data"].split("&")
      if postback_data[0] == "garbage_destroy"
        garbage_destroy(postback_data[1])
        client.reply_message(event['replyToken'], delete_comfirmation)
      elsif postback_data[0] == "garbage_capacity"
        client.reply_message(event['replyToken'], garbage_capacity)
      end
    when Line::Bot::Event::Message #メッセージが送られてきた場合
      case event.type
      when Line::Bot::Event::MessageType::Location # 位置情報が入力された場合
        lat = event.message['latitude'] # 緯度
        long = event.message['longitude'] # 経度
        area = AreaInfo.find_by_sql(["select * from area_infos order by abs(latitude - ?) + abs(longitude - ?) ASC limit 1 ", lat, long]) #現在地から一番近い観測地点を取得
        if User.find_by(line_id: line_id)
          User.update(line_id: line_id, area_info_id: area.first.id) #ユーザー情報を更新
        else
          User.create(line_id: line_id, area_info_id: area.first.id) #ユーザー情報を保存
        end
        user = User.find_by(line_id: line_id)
        user_location = AreaInfo.find(user.area_info_id)
        push = "#{user_location.area_name}か、\nそんなとこで何してるんや \nたまには帰ってきいや！"
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
                "明日の天気？\n明日の#{user_location.prep_name}、#{user_location.area_name}は雨降りそうやで\n今のところ、\n　  6〜12時　#{per06to12}％\n　12〜18時　 #{per12to18}％\n　18〜24時　#{per18to24}％\nこんな感じや\nまた明日の朝に雨降りそうやったら教えたるわ！"
            else
              push =
                "明日の天気？\n明日の#{user_location.prep_name}、#{user_location.area_name}は雨降らんと思うで\nまた明日の朝に雨降りそうやったら教えたるわ！"
            end

          when /.*(ゴミ情報を教えてください).*/
            allgarbages = Garbage.where(user_id: user.id)
            client.reply_message(event['replyToken'], garbage_message(allgarbages.length))

          when /.*(現在登録されているゴミの日を確認します).*/
            push = "今登録されてるゴミの日や\nちゃんとゴミ捨てるんやで！"
            @array = []
            allgarbages = Garbage.where(user_id: user.id)
            if allgarbages.length > 0
              allgarbages.each do |allgarbage|
                if allgarbage.second_nth_id.length != 0
                  g_message = {"type": "template",
                              "altText": "現在登録されているゴミの日表示中",
                              "template": {
                                "type": "buttons",
                                "title": "現在登録されているゴミの日",
                                "text": "種類：#{allgarbage.garbage_type.name}\n週    ：#{allgarbage.first_nth.name}週、#{allgarbage.second_nth.name}週 \n曜日：#{allgarbage.wday.name}",
                                "actions": [
                                    {
                                      "type": "uri",
                                      "label": "編集する",
                                      "uri": "line://app/1607924018-Dagz65o2?id=#{allgarbage.id}&wday=#{allgarbage.wday.id}&nth=#{allgarbage.first_nth.id}&type=#{allgarbage.garbage_type.id}" #garbageの情報をurlパラメータとしてjsに渡す
                                    },
                                    {
                                      "type": "postback",
                                      "label": "削除する",
                                      "data": "garbage_destroy&#{allgarbage.id}"
                                    },
                                  ],
                                }
                              }
                else 
                  g_message = {"type": "template",
                    "altText": "現在登録されているゴミの日表示中",
                    "template": {
                      "type": "buttons",
                      "title": "現在登録されているゴミの日",
                      "text": "種類：#{allgarbage.garbage_type.name}\n週    ：#{allgarbage.first_nth.name}週 \n曜日：#{allgarbage.wday.name}",
                      "actions": [
                          {
                            "type": "uri",
                            "label": "編集する",
                            "uri": "line://app/1607924018-Dagz65o2?id=#{allgarbage.id}&wday=#{allgarbage.wday.id}&nth=#{allgarbage.first_nth.id}&type=#{allgarbage.garbage_type.id}" #garbageの情報をurlパラメータとしてjsに渡す
                          },
                          {
                            "type": "postback",
                            "label": "削除する",
                            "data": "garbage_destroy&#{allgarbage.id}"
                          },
                        ],
                      }
                    }
                end
                @array << g_message
              end
              client.reply_message(event['replyToken'], @array)
            else
              push = "まだ登録されてへんわ、登録しなさい"
            end
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
      "text": "久しぶりやな\nあんた今どこおるんや？"},
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

  def garbage_message(length)
    if 0 <= length && length < 5
      [
        {"type": 'text',
        "text": "ゴミの日メニューや"},
        {"type": "template",
          "altText": "ゴミの日メニュー選択画面",
          "template": {
            "type": "buttons",
            "title": "ゴミの日メニュー",
            "text": "選択しいや",
            "actions": [
                {
                  "type": "message",
                  "label": "確認する",
                  "text": "現在登録されているゴミの日を確認します"
                },
                {
                  "type": "uri",
                  "label": "登録する",
                  "uri": "line://app/1607924018-2j0Dpx8j"
                },
            ],
          }
        }
      ]
    elsif length >= 5
      [
        {"type": 'text',
        "text": "ゴミの日メニューや"},
        {"type": "template",
          "altText": "ゴミの日メニュー選択画面",
          "template": {
            "type": "buttons",
            "title": "ゴミの日メニュー",
            "text": "選択しいや",
            "actions": [
                {
                  "type": "message",
                  "label": "確認する",
                  "text": "現在登録されているゴミの日を確認します"
                },
                {
                  "type": "postback",
                  "label": "登録する",
                  "data": "garbage_capacity&over"
                },
            ],
          }
        }
      ]
    end
  end

  def garbage
    @garbage = Garbage.new
  end

  def garbage_create
    @garbage = Garbage.create(garbage_params)
  end

  def garbage_edit
    @garbage = Garbage.find(params[:id])
  end

  def garbage_update
    @garbage = Garbage.find(params[:garbage][:id])
    @garbage.update(wday_id: params[:garbage][:wday_id], first_nth_id: params[:garbage][:first_nth_id], second_nth_id: params[:garbage][:second_nth_id], garbage_type_id: params[:garbage][:garbage_type_id])
  end

  def garbage_destroy(data_id)
    Garbage.find(data_id).destroy
  end

  def delete_comfirmation
    {
    "type": 'text',
    "text": "削除したわ"
    }
  end

  def garbage_capacity
    {
      "type": 'text',
      "text": "5件登録されてんで\nこれ以上登録できへんわ"
    }
  end


  private

  def client
    @client ||= Line::Bot::Client.new { |config|
      # 本番環境
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  def garbage_params
    user = User.find_by(line_id: params[:garbage][:line_id])
    user_id = user.id
    params.require(:garbage).permit(:wday_id, :first_nth_id, :second_nth_id, :garbage_type_id).merge(user_id: user_id)
  end

end
