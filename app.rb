get '/' do
  "Hello world"
end

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
end

post '/callback' do
  body = request.body.read
  client_docomo = Docomoru::Client.new(api_key: ENV["DOCOMO_API_KEY"])
  events = client.parse_events_from(body)
  events.each { |event|
    response = client_docomo.create_dialogue(event['message']['text'])
    case event
    when Line::Bot::Event::Message
      case event.type
      when Line::Bot::Event::MessageType::Text
        message = {
          type: 'text',
          text: response.body['utt']
        }
        client.reply_message(event['replyToken'], message)
      end
    end
  }

end
