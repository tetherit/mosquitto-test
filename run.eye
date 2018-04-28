require 'erb'
require 'fileutils'

MOSQUITTO_PROCESSES = 1000

$current_path = File.expand_path(__dir__)

Eye.load('./eye/*.rb')
Eye.config do
  logger File.join($current_path, './log/eye.log')
end

# Increase the file/process limits to run this test
system('sudo ulimit -u 28370 -n 71680')

def defaults(i, name)
  log_path = File.join($current_path, "./log/#{name}-#{i}.log")
  FileUtils.rm(log_path) if File.exist?(log_path)

  daemonize true
  pid_file "./tmp/pid/#{name}-#{i}.pid"
  stdall log_path
  stop_signals [:KILL] # We want to see the durability of mosquitto with kills
end

def mosquitto_group(i)
  db_path = File.join($current_path, "./tmp/dbs/mosquitto-timebox#{i}.db")
  FileUtils.rm(db_path) if File.exist?(db_path)

  process :timebox_mosquitto do
    render_template(
      'mosquitto-timebox.conf', "mosquitto-timebox#{i}.conf", {i: i}
    )
    conf_path = File.join($current_path, "./tmp/etc/mosquitto-timebox#{i}.conf")
    start_command "mosquitto -c #{conf_path} -v"
    defaults(i, 'mosquitto')
  end

  process :subscriber do
    port = 1883+i
    start_command "mosquitto_sub -p #{port} -q 2 -t '#' -i subscriber_#{i} -c"
    defaults(i, 'subscriber')
  end

  process :publisher do
    port = 1883+i
    start_command "./bin/publisher.rb #{i} #{port}"
    defaults(i, 'publisher')
  end
end


Eye.application 'mosquitto_test' do
  working_dir $current_path
  trigger :flapping, times: 10, within: 1.minute, retry_in: 10.minutes

  group "mosquitto_main" do
    chain grace: 1.seconds # chained start-restart with 1s interval, one by one.
    process :mosquitto do
      render_template('mosquitto.conf', 'mosquitto-main.conf')
      conf_path = File.join($current_path, './tmp/etc/mosquitto-main.conf')
      start_command "mosquitto -c #{conf_path} -v"
      defaults(0, 'mosquitto')
    end

    process :subscriber do
      start_command "mosquitto_sub -p 1883 -q 2 -t '#' -i subscriber_0 -c"
      defaults(0, 'subscriber')
    end

    process :publisher do
      start_command "./bin/publisher-main.rb #{MOSQUITTO_PROCESSES}"
      defaults(0, 'publisher')
    end

  end

  (1..MOSQUITTO_PROCESSES).each do |i|
    group "mosquitto_#{i}" do
      chain grace: 1.seconds # chained start-restart with 1s interval, one by one.
      mosquitto_group(i)
    end
  end
end
