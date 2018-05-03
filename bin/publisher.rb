#!/usr/bin/env ruby
# frozen_string_literal: true

require 'paho-mqtt'

$total = ARGV[0].to_i
$qos_level = ARGV[1].to_i # 1 or 2

def usage
  puts "Usage: ./publisher.rb TOTAL QOS_LEVEL"
  puts "    e.g. ./publisher.rb 1000 2"
  exit 1
end

usage unless [1,2].include?($qos_level)
usage unless $total > 0


# Performance is terrible with many threads, need to investigate using something
# other than Paho. For now limit to 2 threads in favour of more processes.
if $total <= 2
  threads = (1..$total).entries
else
  threads = (1..$total).entries.shuffle
  threads = threads[0...2]
end

$threads = {}
$count = 0

# Create connection threads
threads.each do |i|
  begin
    client_id = "client_#{(rand*1_000_000_000).to_i}"
    client = PahoMqtt::Client.new(persistent: true, client_id: client_id)
    client.connect('127.0.0.1', 1883+i)
    $threads[i] = client
    puts "*** Connected to broker: #{i} (#{client_id})"
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

  # mosquitto_pub -p 1884 -q 2 -t 'from/timebox1/recording/new' -m "message from timebox1"
  $threads[i].publish(topic, msg, true, $qos_level)
end

threads.each do |i|
  return unless $threads.key?(i)
  if $qos_level == 1
    $threads[i].on_puback { send_message(i) }
  elsif $qos_level == 2
    $threads[i].on_pubcomp { send_message(i) }
  end
  send_message(i)
end

# Keep the process going
loop { sleep 1 }
