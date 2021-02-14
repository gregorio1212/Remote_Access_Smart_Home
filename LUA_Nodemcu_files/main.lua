--[[
main.lua

File where MQTT interfacing and functions depending on payloads and topics are stored
--]]

-- Array that hold functions names and has as index the topics
m_dis = {}


-- Standard counter variable. Used for modulo arithmatic
local count = 0

function safety(m, pl)
    m:publish("smarthome/info/alarm", "Roger that", 0, 0,
           function(m) print("ALARM COMMAND") end)
      
    gpio.mode(PIN_BEEP, gpio.OUTPUT)
    gpio.mode(PIN_ALARM, gpio.OUTPUT)
    if pl == "beep" then
        m:publish("smarthome/info/alarm", "beep", 0, 0,
            function(m) print("RINGING ALARM") end)
        gpio.write(PIN_ALARM, gpio.LOW)
        gpio.write(PIN_BEEP, gpio.HIGH)
    end

    if pl == "off" then
        m:publish("smarthome/info/alarm", "off", 0, 0,
            function(m) print("ALARM TURNING OFF") end)
        gpio.write(PIN_ALARM, gpio.LOW)
        gpio.write(PIN_BEEP, gpio.LOW)
    end
        
    if pl == "on" then
        m:publish("smarthome/info/alarm", "on", 0, 0,
            function(m) print("SETTING THE ALARM") end)
        gpio.write(PIN_ALARM, gpio.HIGH)
        gpio.write(PIN_BEEP, gpio.LOW)
    end
end
       

function animate(m, pl)
	-- Confirm that an animation message was received on the /mcu/cmd topic
	m:publish("smarthome/info/ledstate", "Roger that", 0, 0,
			function(m) print("LED COMMAND") end) --/mcu
	
	-- Main option control structure. Pretty gross-looking but it works
	-- Option 0 turns everything off
	if pl == "0" then
		-- Confirm LED being turned off to serial terminal and MQTT broker
		m:publish("smarthome/info/ledstate", "0", 0, 0,
			function(m) print("LED OFF") end) --/mcu
		
		-- Reset the counter and stop the timer from another function
		count = 0
		timer:stop()
		
		-- PWM process is still running but duty cycle is just set to zero
		pwm.setduty(PIN_RED, 0)
		pwm.setduty(PIN_GRN, 0)
		pwm.setduty(PIN_BLU, 0)
	
	-- RBG Mode
	elseif pl == "1" then
		-- Confirm LED in RGB mode to serial terminal and MQTT broker
		m:publish("smarthome/info/ledstate", "1", 0, 0,
			function(m) print("RGB Mode") end) --/mcu
		
		-- Just stop the timer from another loop
		timer:stop()
		
		-- Use function declared in init_man.lua to blink through red, green,
		-- and blue
		timer:alarm(500,tmr.ALARM_AUTO,function()
			count = count + 1
			rgb_solid(count % 3)
		end)
	
	-- Pick a "random" color and make it breathe mode
	elseif pl == "2" then
		-- Confirm LED in random breathe mode to serial terminal and MQTT broker
		m:publish("smarthome/info/ledstate", "2", 0, 0,
			function(m) print("Random-Breathe Mode") end) --/mcu
		
		-- Reset the counter and stop the timer from another function
		timer:stop()
		count = 0
		
		-- Create variables run the breather alarm. Start with random color at
		-- full brightness (percent = 100)
		local percent = 100
		local count_up  = false
		local red = (tmr.now()) % 512
		--tmr.delay(red)
		local grn = (tmr.now()) % 512
		--tmr.delay(grn)
		local blu = (tmr.now()) % 512

		-- Breather alarm function run every 20 ms
		timer:alarm(20,tmr.ALARM_AUTO,function()
			-- Set the LED brightness
			pwm.setduty(PIN_RED, red * percent / 100)
			pwm.setduty(PIN_BLU, blu * percent / 100)
			pwm.setduty(PIN_GRN, grn * percent / 100)
			
			-- Logic to either dim or brighten
			if count_up == false then
				percent = percent - 1
				if percent < 0 then
					percent = 0
					count_up = true
				end
			else
				percent = percent + 1
				if percent > 100 then
					percent = 100
					count_up = false
				end
			end
		end)
	
	-- Lots of random blinking craziness
	elseif pl == "3" then
		-- Confirm LED in disco mode to serial terminal and MQTT broker
		m:publish("smarthome/info/ledstate", "3", 0, 0,
			function(m) print("Disco Mode") end) --/mcu
		
		-- Reset the counter and stop the timer from another function
		timer:stop()
		count = 0
		
		-- Crazy disco alarm every 20 ms
		timer:alarm(20,tmr.ALARM_AUTO,function()
			pwm.setduty(PIN_GRN, (tmr.now())%512)
			pwm.setduty(PIN_RED, (tmr.now())%512)
			pwm.setduty(PIN_BLU, (tmr.now())%512)
		end)
	
	-- Something went wrong somehow
	else
		-- Print and publish to serial terminal and MQTT broker respectively
		-- that something went wrong
		m:publish("smarthome/info/ledstate", "--> Error: Unknown Command", 0, 0,
			function(m) print("ERROR: UNKNOWN COMMAND") end) --/mcu
	end
end


-- As part of the dispatcher algorithm, this assigns a topic name as a key or
-- index to a particular function name
m_dis["smarthome/cmd/led"] = animate -- 0 1 2 3
m_dis["smarthome/cmd/alarm"] = safety -- beep on off

-- initialize mqtt client with keepalive timer of 60sec
-- we could set clean session to 0 to have a "persisten connection"
m = mqtt.Client(MQTT_CLIENTID, 60, "brazil", "inpoland2021")


-- Set up Last Will and Testament (optional)
-- Broker will publish a message with qos = 0, retain = 0, data = "offline"
-- to topic "/lwt" if client don't send keepalive packet
m:lwt("smarthome/info/device1", "offline", 0, 1)


-- When client connects, print status message and subscribe to cmd topic
m:on("connect", function(m) 
	-- Serial status message
	print ("\n\n", MQTT_CLIENTID, " connected to MQTT host ", MQTT_HOST,
		" on port ", MQTT_PORT, "\n\n")

    m:publish("smarthome/info/device1", "online", 0, 0,
            function(m) print("Device 1 is online") end)

	-- Subscribe to the topic where the ESP8266 will get commands from
	m:subscribe("smarthome/cmd/#", 0,
		function(m) print("Subscribed to smarthome/cmd/#") end) --/mcu
end)
   



-- When client disconnects, print a message and list space left on stack
m:on("offline", function(m)
	print ("\n\nDisconnected from broker")
	print("Heap: ", node.heap())
end)


-- On a publish message receive event, run the message dispatcher and
-- interpret the command
m:on("message", function(m,t,pl)
	print("PAYLOAD: ", pl)
	print("TOPIC: ", t)
	
	-- This is like client.message_callback_add() in the Paho python client.
	-- It allows different functions to be run based on the message topic
	if pl~=nil and m_dis[t] then
		m_dis[t](m,pl)
	end
end)

-- Connect to the broker
m:connect(MQTT_HOST, MQTT_PORT, 0, 1)
