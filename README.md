# Introduction
This code is designed to test mosquitto to its limits, to start hundreds or a thousand of mosquitto bridge connections and then bombard them with messages.

The idea is to test Mosquitto in an environment where you have:
 * One main broker, normally your Cloud broker
 * Loads of small client side brokers (e.g. installed on each IoH Hub, called a "TimeBox" in these tests)

The processes include:

 * ```bin/publisher.rb``` - publishes messages to the individual mosquitto brokers (TimeBoxes), to be bridged to the main one (Cloud)

 * ```bin/publisher-main.rb``` - publishes messages from the main broker (Cloud) to all the bridges (TimeBoxes)

 * ```bin/kill.sh``` - to run incase your system starts to become unrespondive as an emergency

Edit run.eye (Ruby DSL) to tune the number of processes and to set the path of this source code.

## Starting and Stopping

* To __start__ the test, run:
  * ```eye load run.eye```
  * or: ```eye load run.eye -f``` - to start in the foreground

__Note__: Allow several minutes for eye to start if you are starting 500+ processes

* To __check__ running processes: ```eye info```
* To __stop__ the publisher processes: ```eye stop 'publisher_*'```
* To __quit__ eye:
  * ```eye quit -s```
  * or: ```ctrl +c``` - if running in the foreground

## Reviewing the log files
Inside of ```./log```:

* To check the throughput of Bridges (TimeBoxes) -> Main Server (Cloud):
	* ```tail -f subscriber-0.log | pv --line-mode --rate -a >/dev/null```

* To check the throughput of Main Server (Cloud) -> Bridges (TimeBoxes):
	* ```tail -f subscriber-*.log | grep "for timebox" |pv --line-mode --rate -a >/dev/null```

## Troubleshooting
 * Check how many misquitto brokers are running:
	* ```ps aux | grep "mosquitto -c" | grep -v grep | wc -l```


