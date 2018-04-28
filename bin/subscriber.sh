i=$1
port=$2

echo mosquitto_sub -p $port -q 2 -t '#' -i subscriber_${i} -C 1 # to clear session
mosquitto_sub -p $port -q 2 -t '#' -i subscriber_${i} -C 1 # to clear session

echo mosquitto_sub -p $port -q 2 -t '#' -i subscriber_${i} -c
mosquitto_sub -p $port -q 2 -t '#' -i subscriber_${i} -c
