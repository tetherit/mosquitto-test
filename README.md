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
__Note__: Mosquitto uses the same port as RabbitMQ, stop RabbitMQ first

* To __check__ running processes: ```eye info```
* To __stop__ the publisher processes: ```eye stop 'publisher_*'```
* To __quit__ eye:
  * ```eye quit -s```
  * or: ```ctrl +c``` - if running in the foreground

## Reviewing the log files
Inside of ```./log```:

* To check the throughput of Bridges (TimeBoxes) -> Main Server (Cloud):
	* ```tail -f -n1 subscriber-0.log | pv --line-mode --rate -a >/dev/null```

* To check the throughput of Main Server (Cloud) -> Bridges (TimeBoxes):
	* ```tail -f -n1 subscriber-*.log | grep "for timebox" |pv --line-mode --rate -a >/dev/null```

## Troubleshooting
 * Check how many misquitto brokers are running:
	* ```ps aux | grep "mosquitto -c" | grep -v grep | wc -l```


## Results
The following is stark contrast to what I was getting with RabbitMQ:

 * Maxing out 100% CPU, 5GB of ram with 300 connections, 25 messages/sec
 * Using Federation plugin and separate vhost per customer

This is on a VPS provided by transip.eu, Westmere E56xx/L56xx/X56xx (Nehalem-C), 2 cores.

### Mosquitto: 1000 Connections
__Idle__  Average CPU Usage (1 minute) - maintaining the 1,000 connections with keep-alive:

```
$ pidstat 60 -p 25073
18:01:54      UID       PID    %usr %system  %guest    %CPU   CPU  Command
18:02:54     1001     25073    0.28    1.53    0.00    1.82     1  mosquitto
$
$ top
  PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND
25073 deployer  20   0   37104   6012   4300 S   1.6  0.1   0:05.55 mosquitto -c /home/deployer/mosquitto-test/tmp/etc/mosquitto-main.conf -v
```

__Mosquitto: 5 Publishing Threads__: Cloud -> TimeBoxes

__Note__: Mosquitto was taking up the same amount of CPU whether sending 444 mes/sec QOS2 or 874 msg/sec using QOS1.

```
$ pidstat 60 -p 16618
18:38:41      UID       PID    %usr %system  %guest    %CPU   CPU  Command
18:39:41     1001     16618   11.93   35.73    0.00   47.67     0  mosquitto
$
$ top
  PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND
16618 deployer  20   0   37368   6552   4444 R  47.5  0.2   3:32.04 mosquitto -c /home/deployer/mosquitto-test/tmp/etc/mosquitto-main.conf -v
```

Throughput (QOS2):

```
$ tail -f -n1 subscriber-*.log | grep "for timebox" |pv --line-mode --rate -a >/dev/null
[ 459 /s] [ 444 /s]
```

Throughput (QOS1):

```
$ tail -f -n1 subscriber-*.log | grep "for timebox" |pv --line-mode --rate -a >/dev/null
[ 891 /s] [ 874 /s]
```

__Mosquitto: 10 Publishing Thread__: TimeBoxes -> Cloud

__Note__: The bottleneck here was the inefficient Ruby processes, taking up >12% CPU per process, maxing out the CPU.

```
$ pidstat 60 -p 16618
18:58:40      UID       PID    %usr %system  %guest    %CPU   CPU  Command
18:59:40     1001     16618   31.87   23.72    0.00   55.58     1  mosquitto
$
$ top
  PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND
16618 deployer  20   0   41460  10592   4392 R  50.0  0.3   7:14.66 mosquitto -c /home/deployer/mosquitto-test/tmp/etc/mosquitto-main.conf -v
```

Throughput (QOS2):

```
$ tail -f -n1 subscriber-*.log | grep "for timebox" |pv --line-mode --rate -a >/dev/null
[ 274 /s] [ 162 /s]
```

Throughput (QOS1):

```
$ tail -f -n1 subscriber-*.log | grep "for timebox" |pv --line-mode --rate -a >/dev/null
[ 463 /s] [ 454 /s]
```