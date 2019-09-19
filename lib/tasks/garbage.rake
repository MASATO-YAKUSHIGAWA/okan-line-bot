desc "This task is called by the Heroku scheduler add-on"
task :garbage_feed => :environment do
  require 'line/bot'  # gem 'line-bot-api'
  require 'open-uri'
  require 'kconv'
  require 'rexml/document'
  require 'dotenv'
  require 'date'

  client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }

  date = Date.tomorrow #明日の日付を取得

  user_ids = User.all.pluck(:line_id) #user_ids = [user_id1, user_id2, ...]
  user_ids.each do |user_id|
    user = User.find_by(line_id: user_id)

    garbages = Garbage.where(user_id: user.id)
    garbages.each do |garbage|

      en_wday_array = ["first","sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]
      en_wday = en_wday_array[garbage.wday.id] #曜日の取得（英語）

      if garbage.first_nth.id.to_i == 5
        if date.wday == garbage.wday.id.to_i
          push = "明日は#{garbage.wday.name}やから、 \n#{garbage.garbage_type.name}の日やで\n ちゃんとゴミ捨てるんやで！"
        end
      end

      if date == date.nth_week_of_month(garbage.first_nth.id.to_i).day_to(:"#{en_wday}")
        push = "明日は#{garbage.first_nth.name}#{garbage.wday.name}やから、 \n#{garbage.garbage_type.name}の日やで\n ちゃんとゴミ捨てるんやで！"
      elsif garbage.second_nth_id.length != 0 && date == date.nth_week_of_month(garbage.second_nth.id.to_i).day_to(:"#{en_wday}")
        push = "明日は#{garbage.second_nth.name}#{garbage.wday.name}やから、 \n#{garbage.garbage_type.name}の日やで\n ちゃんと捨てるんやで！"
      end
      message = {
        type: 'text',
        text: push
      }
      client.multicast(user_id, message)
    end
  end
end