# Introduction
This code is designed to test mosquitto to its limits, to start hundreds or thousands of mosquitto bridge connections and then bombard them with endless messages.

The idea is to test Mosquitto in an environment where you have:
 * One main broker, normally your Cloud broker
 * Loads of small client side brokers (e.g. installed on each IoH Hub, called a "TimeBox" in these tests)

The processes include:
 *```bin/publisher.rb``` - publishes messages to the individual mosquitto brokers (TimeBoxes), to be bridged to the main one (Cloud)
 * ```bin/publisher-main.rb``` - publishes messages from the main broker (Cloud) to all the bridges (TimeBoxes)
 * ```bin/kill.sh``` - to run incase your system starts to become unrespondive as an emergency

Edit run.eye (Ruby DSL) to tune the number of processes and to set the path of this source code.

## Starting and Stopping

To start the test, run:
```eye load run.eye```
or: ```eye load run.eye -f``` - to start in the foreground

Note: Allow several minutes for eye to start if you are starting 500+ processes

To check running processes:
```eye info```

Top stop the publisher processes:
```eye stop 'publisher_*'```

To quit:
```eye quit -s```
or: ```ctrl +c``` - if running in the foreground

## Reviewing the log files
Inside of ```./log```:

To check throughput of main server:
```tail -f subscriber-0.log | pv --line-mode --rate -a >/dev/null```

To check throughput of rest of servers:
```tail -f subscriber-*.log | grep "for timebox" |pv --line-mode --rate -a >/dev/null```

## Troubleshooting
Check how many misquitto brokers are running:
```ps aux | grep "mosquitto -c" | grep -v grep | wc -l```


