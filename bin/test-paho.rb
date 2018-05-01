# Just a generic file to test the Paho MQTT library with QOS2

require 'bundler/inline'
gemfile do
  source 'https://rubygems.org'
  gem 'paho-mqtt', github: 'RubyDevInc/paho.mqtt.ruby'
end

### Create a simple client with default attributes
client = PahoMqtt::Client.new({
  host: '127.0.0.1', port: 1883, clean_session: false, persistent: true,
  client_id: 123, username: nil, password: nil,
  will_topic: 'test', will_payload: 'offline', will_qos: 2, will_retain: true,
  keep_alive: 20, ack_timeout: 10
})

### Register a callback on message event to display messages
message_counter = 0
client.on_message do |message|
  puts "Message recieved on topic: #{message.topic} >>> #{message.payload}"
  message_counter += 1
end

### Register a callback on suback to assert the subcription
waiting_suback = true
client.on_suback do
  waiting_suback = false
  puts "Subscribed"
end

waiting_pubcomp_count = 0
client.on_pubcomp do
  waiting_pubcomp_count + 1
  puts "Pubcomp"
end

puts client.connection_state

### Connect to the eclipse test server on port 1883 (Unencrypted mode)
client.connect('127.0.0.1', 1883)

puts client.connection_state

### Subscribe to a topic
client.subscribe(['paho/ruby/test', 2])

### Publlish a message on the topic "paho/ruby/test" with "retain == false" and "qos == 2"
(1..10000).each do |i|
  client.publish("paho/ruby/test", "Hello there #{i}!", true, 2)
  sleep 0.5
end

### Waiting to assert that the message is displayed by on_message callback
loop do
  puts waiting_pubcomp_count
  sleep 5
end

### Calling an explicit disconnect
client.disconnect