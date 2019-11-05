class ApplicationController < ActionController::Base

  def client
    @client ||= Line::Bot::Client.new { |config|
      # 本番環境
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  def events
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head :bad_request
    end
    @events = client.parse_events_from(body)
  end
end
