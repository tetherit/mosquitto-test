#!/usr/bin/env ruby
# frozen_string_literal: true

total = ARGV[0].to_i
count = 0
loop do
  count += 1
  i = (1..total).entries.sample
  system("mosquitto_pub -p 1883 -q 2 -t 'to/timebox#{i}/cameras' -m \"message #{count} for timebox#{i}\"")
  sleep rand(0.01..0.5)
end
