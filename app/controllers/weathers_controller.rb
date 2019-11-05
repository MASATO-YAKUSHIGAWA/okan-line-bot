class WeathersController < ApplicationController
  require 'line/bot'  # gem 'line-bot-api'
  require 'open-uri'
  require 'kconv'
  require 'rexml/document'
  require 'dotenv'
  require 'date'

  def tomorrow
    # @events = client.parse_events_from(body)
    # @events.each { |event|
    # line_id = event['source']['userId'] # line_id取得
binding.pry
    push = "aa"

  
    # message = {
    #   "type": 'text',
    #   "text": push
    # }
    # client.reply_message(event['replyToken'], message)
    # }
  end

  # private

  # def client
  #   @client ||= Line::Bot::Client.new { |config|
  #     # 本番環境
  #   config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
  #   config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  #   }
  # end

end
