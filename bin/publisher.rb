#!/usr/bin/env ruby
# frozen_string_literal: true

i = ARGV[0].to_i
port = ARGV[1].to_i

count = 0
loop do
  count += 1
  system("mosquitto_pub -p #{port} -q 2 -t 'from/timebox#{i}/recording/new' -m 'message #{count} from timebox#{i}'")
  sleep rand(0.1..1.5)
end
