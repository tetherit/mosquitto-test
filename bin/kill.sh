ps aux | grep "eye monitoring" | awk '{ print $2 }' | xargs kill -9
killall -9 mosquitto
killall -9 mosquitto_sub
ps aux | grep publisher | awk '{ print $2 }' | xargs kill -9

