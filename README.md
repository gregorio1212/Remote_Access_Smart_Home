# Remote_Access_Smart_Home
In this project, we have built a smart home prototype and controlled it using a webserver 
that works as a remote access to the smart home. The hardware used to perform this project is:

1 - (Michał)Raspberry pi 3B+ (Apache Webserver/MQTT client   AND   MQTT broker);
2 - (Gregório)Raspberry pi 3B+ (MQTT client);
3 - (Michał)Raspberry pi pico (sends data to (Michał)Raspberry pi 3B+);
4 - (Gregório)Raspberry pico (receives commands from Nodemcu and sends data to (Gregório)Raspberry pi 3B+);
5 - NodeMCU board - ESP-12E (MQTT client);
6 - Sound detector module (output to (Gregório)Pico);
7 - Buzzer (controlled by (Gregório)Pico);
8 - RGB LED (controlled by NodeMCU board);

Some other useful information regarding software part of the project:

- The MQTT broker is a free Mosquitto broker;
- Apache Webserver utilizes HTML and javascript(jquery) to handle the MQTT communications;
- (Gregório)Pico was programmed using C;
- (Michał)Pico was programmed using MicroPython;
- Python was used for the clients in both Raspberry pi while Lua was used in the NodeMCU board;
