#!/usr/bin/env ruby
# frozen_string_literal: true

require 'paho-mqtt'

$total = ARGV[0].to_i
$qos_level = ARGV[1].to_i # 1 or 2

def usage
  puts "Usage: ./publisher-main.rb TOTAL QOS_LEVEL"
  puts "    e.g. ./publisher-main.rb 1000 2"
  exit 1
end

usage unless [1,2].include?($qos_level)
usage unless $total > 0

client_id = "client_#{(rand*1_000_000).to_i}"
puts "Client ID: #{client_id}"

$client = PahoMqtt::Client.new(username: 'testuser', password: 'testpasswd', client_id: client_id)
$client.connect('127.0.0.1', 1883)

$count = 0
def send_message
  $count += 1
  i = rand(1..$total)

  topic = "to/timebox#{i}/cameras"
  msg = "message #{$count} #{Time.now} for timebox#{i}"
  # puts "Publishing topic: #{topic} msg: #{msg}"

  # mosquitto_pub -p 1883 -q 2 -u testuser -P testpasswd -t 'to/timebox1/cameras' -m "message for timebox1"
  $client.publish(topic, msg, true, $qos_level)
end

if $qos_level == 1
  $client.on_puback { send_message } # QOS1
elsif $qos_level == 2
  $client.on_pubcomp { send_message } # QOS2
end
send_message

loop { sleep 1 }
