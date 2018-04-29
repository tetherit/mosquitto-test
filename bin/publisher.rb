#!/usr/bin/env ruby
# frozen_string_literal: true

require 'paho-mqtt'

$total = ARGV[0].to_i
$threads = {}

$count = 0

# Create connection threads
(1..$total).each do |i|
  begin
    client = PahoMqtt::Client.new
    client.connect('127.0.0.1', 1883+i)
    $threads[i] = client
    puts "*** Connected to broker: #{i}"
  rescue
    puts "!!! Failed to connect to broker #{i}"
  end
end

def send_message(i)
  return unless $threads.key?(i)

  $count += 1
  topic = "from/timebox#{i}/recording/new"
  msg = "message #{$count} #{Time.now} from timebox#{i}"
  # puts "Publishing topic: #{topic} msg: #{msg}"

  $threads[i].publish(topic, msg, true, 1)
end

(1..$total).each do |i|
  return unless $threads.key?(i)
  $threads[i].on_puback do
    send_message(i)
  end
  send_message(i)
end

# Keep the process going
loop { sleep 1 }
