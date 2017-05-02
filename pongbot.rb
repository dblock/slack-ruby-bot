require 'slack-ruby-bot'
require 'fastly'

class PongBot < SlackRubyBot::Bot
  command 'ping' do |client, data, match|
    client.say(text: 'pong', channel: data.channel)
  end
end

class ServiceBot< SlackRubyBot::Bot
  match /^service_lookup (?<service_id>\w*)$/ do |client, data, match|
    fastly = Fastly.new(api_key: ENV['FASTLY_API_KEY'])
    service_id = "#{match[:service_id]}"
    begin 
    	service_obj = fastly.get_service(service_id)
    	customer_id = service_obj.customer_id
      customer = fastly.get_customer(customer_id)
      client.say(channel: data.channel, text: service_id + " is a service that belongs to " + customer.name + ' (CID:  ' + customer_id + ')')
    rescue StandardError=>e
      client.say(channel: data.channel, text: 'Sorry, that Service ID is not in our system.')
    end
  end
end

PongBot.run
ServiceBot.run