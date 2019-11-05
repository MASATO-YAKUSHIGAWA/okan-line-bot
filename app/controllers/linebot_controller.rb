class LinebotController < ApplicationController
  require 'line/bot'  # gem 'line-bot-api'
  require 'open-uri'
  require 'kconv'
  require 'rexml/document'
  require 'dotenv'
  require 'date'
  
  require 'weather_module'
  include Weather

  require 'garbage_module'
  include Garbages

  # callbackアクションのCSRFトークン認証を無効
  protect_from_forgery :except => [:callback]

  def callback
    events.each { |event|
    $line_id = event['source']['userId'] # line_id取得
    case event
      when Line::Bot::Event::Follow #フォローされた場合
        client.reply_message(event['replyToken'], first_message)
      when Line::Bot::Event::Unfollow # LINEお友達解除された場合、DBから削除する
        User.find_by(line_id: $line_id).destroy
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
            @user = User.find_by(line_id: $line_id)
            if @user
              @user.update(line_id: $line_id, area_info_id: area.first.id) #ユーザー情報を更新
            else
              User.create(line_id: $line_id, area_info_id: area.first.id) #ユーザー情報を保存
            end
            user = User.find_by(line_id: $line_id)
            user_location = AreaInfo.find(user.area_info_id)
            push = "#{user_location.area_name}か、\nそんなとこで何してるんや \nたまには帰ってきいや！"
          when Line::Bot::Event::MessageType::Text
            if User.find_by(line_id: $line_id) #line_id取得
              user = User.find_by(line_id: $line_id)
              $user_location = AreaInfo.find(user.area_info_id) #userの観測値情報取得（グローバル変数）
              input = event.message['text']
            case input
              when /.*(お試しです).*/
                push = "line://app/1607924018-E03OZ2vn"
                # 「明日」or「あした」というワードが含まれる場合
              when /.*(明日|あした).*/
                # info[2]：明日の天気
                tomorrow_weather #モジュール呼び出し
              when /.*(ゴミ情報を教えてください).*/
                garbage_info
              when /.*(現在登録されているゴミの日を確認します).*/
                garbage_comfirmation
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

  def garbage_params
    user = User.find_by(line_id: params[:garbage][:line_id])
    user_id = user.id
    params.require(:garbage).permit(:wday_id, :first_nth_id, :second_nth_id, :garbage_type_id).merge(user_id: user_id)
  end

end
