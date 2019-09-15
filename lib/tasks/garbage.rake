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
      if date == date.nth_week_of_month(garbage.nth.to_i).day_to(:monday)
        push = "明日はゴミの日です \nゴミ"
      end
      message = {
        type: 'text',
        text: push
      }
      client.multicast(user_id, message)
    end
  end
end