This code is design to test mosquitto to its limits, to start hundreds or thousands of mosquitto bridge connections and then bombard them with endless messages.

The processes include:
 * _bin/publisher.rb_ - publishes messages to the individual mosquitto brokers, to be bridged to the main one
 * _bin/publisher-main.rb_ - publishes messages from the main broker to all the bridges
 * _bin/kill.sh_ - to run incase your system starts to become unrespondive as an emergency

Look at run.eye (Ruby DSL) for the number of processes and publishers.

# Starting and Stopping
To start the test, run:
```eye load run.eye```

To check running processes:
```eye info```

To quit:
```eye quit -s```

# Reviewing the log files
To check throughput:
```tail -f log/subscriber-0.log | pv --line-mode --rate -a >/dev/null```

# Troubleshooting
Check how many misquitto brokers are running:
```ps aux | grep "mosquitto -c" | grep -v grep | wc -l```
