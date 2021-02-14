#!/usr/bin/env python3

import paho.mqtt.client as mqtt
import serial
from time import sleep

MQTT_HOST = "89.79.127.216"
MQTT_PORT = 1883
com = serial.Serial('COM4',115200,timeout=1) #windows only
#com = serial.Serial('/dev/ttyUSB0',115200,timeout=1)  # smth like this should work for linux
# ---------------------------------------


def on_connect(self, cl, userdata, rc):
    print("\nConnected with result code " + str(rc) + "\n")
    client.publish("smarthome/info/device3", payload="online", qos=0, retain=True)


client = mqtt.Client(client_id="michal-pico")
client.username_pw_set(username="brazil",password="inpoland2021")
client.on_connect = on_connect
client.will_set("smarthome/info/device3", "offline", 1, True)
client.connect(MQTT_HOST, MQTT_PORT, 60)
client.loop_start()

while True:
    com.flushInput()
    r = com.readline()
    while (r.decode('UTF-8').strip() == ''):
        r = com.readline()
    print(r.decode('UTF-8').strip())
    client.publish("smarthome/info/temp2", payload=r.decode('UTF-8').strip(), qos=0, retain=True)
    sleep(30)