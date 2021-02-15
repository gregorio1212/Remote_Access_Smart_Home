import serial
import paho.mqtt.client as mqtt

MQTT_HOST = "89.79.127.216"
MQTT_PORT = 1883

def on_connect(self, client, userdata,rc):
	print("Connected with result code "+str(rc)+"\n")
	print("Subscribed to smarthome/info/temp1")

def on_message_temp(self, client, userdata, msg):
	print("\n\t* TEMPERATURE UPDATED")

def command_error(self):
	print("Error: Unknown command")

client = mqtt.Client(client_id="pico-temperature")

client.username_pw_set(username="brazil",password="inpoland2021")

client.on_connect = on_connect
client.message_callback_add("smarthome/info/temp1", on_message_temp)
client.will_set("smarthome/info/device2","offline",qos=0, retain=True)

client.connect(MQTT_HOST, MQTT_PORT, 60)
client.loop_start()

ser = serial.Serial('/dev/ttyACM0', 115200, timeout=1)

client.publish("smarthome/info/device2",payload="online",qos=0,retain=True)

while(1):
	temp = ser.readline()
	if(temp!=b''):
		temp =round(float(temp),1)
		print("%.1f" % temp)
		client.publish("smarthome/info/temp1",payload=temp,qos=0,retain=False)
