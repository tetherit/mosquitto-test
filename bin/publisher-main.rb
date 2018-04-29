#!/usr/bin/env ruby
# frozen_string_literal: true

require 'paho-mqtt'

$total = ARGV[0].to_i

$client = PahoMqtt::Client.new(username: 'testuser', password: 'testpasswd')
$client.connect('127.0.0.1', 1883)

$count = 0
def send_message
  $count += 1
  i = rand(1..$total)

  topic = "to/timebox#{i}/cameras"
  msg = "message #{$count} #{Time.now} for timebox#{i}"
  # puts "Publishing topic: #{topic} msg: #{msg}"

  # mosquitto_pub -p 1883 -q 2 -u testuser -P testpasswd -t 'to/timebox1/cameras' -m "message for timebox1"
  $client.publish(topic, msg, true, 2)
end

$client.on_pubcomp do
  send_message
end
send_message

loop { sleep 1 }
