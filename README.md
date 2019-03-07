# SmartPowerPlug
Transform an ESP8266 (version 01 or ESP01) card to a Web connected power switch in a context of smart spaces and IoT

## Usage
This code is used to transform any ESP8266 (version 01 or ESP01) card to a connected object (or Thing). The code allows preconfiguring the ESP01 to automatically connect to an existing  WiFi access point (A.P.) of the LAN or to make the ESP01 acts as an independent A.P.  that can be contacted directly contacted from any device using the Web. 

The code enables the access to the ESP01 from anywhere using the Web (HTTP protocol). Hence, using the programmed ESP01, anyone can control (turn ON or OFF) any electrical device connected with an electrical outlet to our object created on top of our programmed ESP01. At any time, the user can select the WiFi network he wants, using the implemented Web interface, or makes the object standalone in an A.P mode. All user preferences are saved in the persistent memory of the ESP8266 (EEPROM).<br/>
![ESP8266 and breadboard prototyping](http://www.lemlouma.com/papers/img/part1_1.png)
![ESP8266 in real-world](http://www.lemlouma.com/papers/img/part3_1.png)

<br/><br/>

## Requirements
For a detailed explanation about the code usage and the required connections of cables and GPIOs, please refer to the following videos. Please select the youtube subtitles tool for English, as the videos content is in French.<br/> In these videos, the cable connections required to connect the ESP8266 are explained using a breadboard for uploading and testing the code with the Arduino IDE through an Arduino Nano. For an independent connected object, you can integrate your programmed ESP8266-01 into the printed circuit board (PCB) detailed here:<br/><br/>
![PCB](http://www.lemlouma.com/papers/img/SmartPowerPlug_PCBtopSide.png)

## Videos :<br/>
Part I (23min17s): http://1do.me/pZ <br/>
Part II (36min12s): http://1do.me/7n <br/>
Part III (36min15s): http://1do.me/eG <br/>
Partie IV [PCB] (34min11s): http://1do.me/3v <br/>
Web: http://www.lemlouma.com/papers/IoT_Tuto_SmartPowerPlug.html<br/>
