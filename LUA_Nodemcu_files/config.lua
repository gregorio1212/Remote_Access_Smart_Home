--[[
config.lua

Global variable configuration file for better portability
Change for your particular setup. This assumes default Mosquitto config
--]]

-- Pin Declarations
PIN_RED = 1
PIN_GRN = 2
PIN_BLU = 3
PIN_BTN = 4

PIN_ALARM = 6 --gpio12
PIN_BEEP = 5 --gpio 14

-- WiFi
WIFI_SSID = "Kazik84"
WIFI_PASS = "KW8417zaq123"

-- MQTT
MQTT_CLIENTID = "esp-blinkenlite"
MQTT_HOST = "89.79.127.216"--"89.79.127.216" --192.168.1.30
MQTT_PORT = 1883

-- Confirmation message
print("\nGlobal variables loaded...\n")
