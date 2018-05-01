# Installing Dependencies
```apt-get install mosquitto mosquitto-clients mosquitto-auth-plugin```

# Creating passwd file
```
touch /etc/mosquitto/passwd
mosquitto_passwd -b /etc/mosquitto/passwd testuser testpasswd
```

# Editing config file
* Edit /etc/mosquitto/mosquitto.conf to add:
```
password_file /etc/mosquitto/passwd
allow_anonymous false
```