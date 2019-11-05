module Garbages

  def garbage_info
    user = User.find_by(line_id: $line_id)
    @allgarbages = Garbage.where(user_id: user.id)
    client.reply_message(params[:events][0]['replyToken'], garbage_message(@allgarbages.length))
  end

  def garbage_comfirmation
    user = User.find_by(line_id: $line_id)
    @allgarbages = Garbage.where(user_id: user.id)

    push = "今登録されてるゴミの日や\nちゃんとゴミ捨てるんやで！"
    @array = []
    if @allgarbages.length > 0
      @allgarbages.each do |allgarbage|
        if allgarbage.second_nth_id.length != 0
          g_message = {"type": "template",
                      "altText": "現在登録されているゴミの日表示中",
                      "template": {
                        "type": "buttons",
                        "title": "現在登録されているゴミの日",
                        "text": "種類：#{allgarbage.garbage_type.name}\n週    ：#{allgarbage.first_nth.name}、#{allgarbage.second_nth.name} \n曜日：#{allgarbage.wday.name}",
                        "actions": [
                            {
                              "type": "uri",
                              "label": "編集する",
                              "uri": ENV['LIFF_EDIT_URL']+"?id=#{allgarbage.id}&wday=#{allgarbage.wday.id}&nth=#{allgarbage.first_nth.id}&type=#{allgarbage.garbage_type.id}" #garbageの情報をurlパラメータとしてjsに渡す
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
              "text": "種類：#{allgarbage.garbage_type.name}\n週    ：#{allgarbage.first_nth.name} \n曜日：#{allgarbage.wday.name}",
              "actions": [
                  {
                    "type": "uri",
                    "label": "編集する",
                    "uri": ENV['LIFF_EDIT_URL']+"?id=#{allgarbage.id}&wday=#{allgarbage.wday.id}&nth=#{allgarbage.first_nth.id}&type=#{allgarbage.garbage_type.id}" #garbageの情報をurlパラメータとしてjsに渡す
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
      client.reply_message(params[:events][0]['replyToken'], @array)
    else
      push = "まだ登録されてへんわ、登録しなさい"
    end

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
                  "uri": ENV['LIFF_REGISTER_URL']
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

end
