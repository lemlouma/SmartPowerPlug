/*

Connected Object (Thing) from A to Z
Author: Tayeb LEMLOUMA
Tayeb.Lemlouma@irisa.fr

Web : www.lemlouma.com
Github: github.com/lemlouma/
2018 ©

This code is used to make any ESP8266 (version 01 or ESP01) card as a connected object (or Thing). The code allows preconfiguring the ESP01
to automatically connect to an existing  WiFi access point (A.P.) of the LAN or to make the ESP01 acts as an independent A.P.  that can be 
contacted directly from any device. The code enables access to the ESP01 from anywhere using the Web (HTTP protocol). Hence, using the 
programmed ESP01, anyone can control (turn ON or OFF) any electrical device connected with an electrical outlet to our object created on 
top of our programmed ESP01.
At any time, the user can select the WiFi network he wants or makes the object standalone in A.P mode. All user preferences are saved in 
the persistent memory of the ESP8266 (EEPROM).

For a detailed explanation about the code usage and the required connections of cables and GPIOs, please refer to the following videos. 
Please select the youtube subtitles tool for English, as the videos were made in French.
In these videos, the cable connections required to connect the ESP8266 are explained using a breadboard for uploading and testing the code 
with the Arduino IDE through an Arduino Nano. For an independent connected object, you can integrate your programmed ESP8266-01 into the 
printed circuit board (PCB) detailed here: http://www.lemlouma.com/papers/img/SmartPowerPlug_PCBtopSide.png.

Videos :
Part I (23min17s): http://1do.me/pZ 
Part II (36min12s): http://1do.me/7n 
Part III (36min15s): http://1do.me/eG 
Web: http://www.lemlouma.com/papers/IoT_Tuto_SmartPowerPlug.html

*/


#include "ESP8266WiFi.h"
#include "EEPROM.h"
//#include "ESP8266WebServer.h"

String codeVersion = "Version 0.1a  Aug 2018 by Tayeb L. ©";

//Variables used for the user's configuration regarding the WiFi connection (make the ESP01 either an access point (A.P.) or a WiFi client)
String ssidWeb, passwordWeb=""; //the SSID and the password of the WiFi network as set by the user using the Web interface
String listeReseauxWifi=""; //contains the list of scanned WiFi APs (in an HTML form: using the HTML "select" tag)

//Variable en cas de tentative en cours de se connecter à un réseau Wifi
//Variable used to handle trying to connect to a Wifi network
String entrainDeSeconnecter = ""; //indicates that the current state of the connection is : at the beginning of the attempt
boolean orderDeConnexion = false; //indicates that we have just initiated a connection order to an existing A.P.

// Setup GPIO2
int pinGPIO2 = 2;  //the GPIO2 is used to control the output voltage of the electrical device connected to our smart object
int ledStatus = 0; //0=Off,1=On

String esp8266Mac = ""; //this variable will contains the MAC address of the ESP8266


WiFiServer WebServer(80); // run the Web server on the listening port 80
// Web Client
WiFiClient client; //used to handle Web clients (using Web browsers) who request our Web server
//--------------------------------------------------------------------------------------------------------------------
// Setup () general algorithm:
// 1. Display tge welcome message
// 2. We activate the GPIO-02 (used to control the power on of the electrical device connected to our object
// 3. Reading the memory of the ESP8266 (to consider the user preferences already saved: object mode (LAN or Internet) & preferred WiFi 
//    network (name and password)
// 4. Depending on the saved user preferences:
//      4.1. IF the object mode is "Internet" and there is a saved network name (SSID) and WiFi password
//           THEN
//                    Connect to the existing WiFi network (A.P.)
//                    [[
//                    IMPORTANT:
//                      - During the attempt to access an existing A.P. (by our object), the connection of web clients to our A.P. is 
//                      momentarily interrupted
//                      - We use a Web refresh (HTML refresh) to the same IP address of our object. This is done to have the new Web page 
//                      when our object is connected or becomes in A.P mode
//                      - Before attempting to connect to an existing A.P., our object sends a status of "being connected" ("en cours de 
//                      connexion") in the main web page configured with a regular HTML "refresh"
//                    ]]
//                    IF
//                      the attempt fails
//                    THEN
//                      become a WiFi A.P.
//           ELSE
//               become a WiFi A.P.
//      4.2. Run our web server to listen to Web client requests


//             
//--------------------------------------------------------------------------------------------------------------------
void setup() {
  //set empty the list of available WiFi networks
  listeReseauxWifi = "<select id=\"listeWi\" name=\"ssid\"><option value=\"\" selected>Mode local (pas d'Internet)</option></select>";
  Serial.begin(115200); //<----------------------------------------------------- this is for debug purposes, to be removed when all tests are completed
  delay(10);
  Serial.println();//<-------------------------------------------- this is for debug purposes, to be removed when all tests are completed
  Serial.println();//<-------------------------------------------- this is for debug purposes, to be removed when all tests are completed
  Serial.println("** WELCOME TO ESP8266 **");//<------------------ this is for debug purposes, to be removed when all tests are completed
  Serial.println(codeVersion);//<--------------------------------- this is for debug purposes, to be removed when all tests are completed

  // Setup the GPIO2 pin
  pinMode(pinGPIO2, OUTPUT);
  digitalWrite(pinGPIO2, LOW);//this depends on the connection of our prototype explained in the video : (+)Relay<->+PowerSupply AND (-)Relay<->GPIO-02)
                              //LOW will turn On the static solide relay (SSR)
  delay(1000); //wait a little bit !
  ledStatus = 1; 

  //****************************************** Start handling the EEPROM ***********************************************
  // SSID variable uses the first 50 chars, then, 
  // the PASWORD vraiable uses the following 50 chars
  EEPROM.begin(512);  //Initialize EEPROM: Max bytes of eeprom to use
  delay(100);
  //--------------------------------------------------------------------------------------------------------------------
  //                                                IMPORTANT
  //
  // This section must be executed ONLY ONCE to initialize the EEPROM before definitively issuing the ESP01
  // This section initializes the EEPROM (first 100 bytes) to 0
  // TODO: to avoid commenting and de-commenting the code (see my recomendations on : http://www.lemlouma.com/papers/IoT_Tuto_SmartPowerPlug.html):
  //        1. Write a special string in a specific place in the EEPROM, then 
  //        2. Test the existence of this specific string at the beginning of this code.
  //        IF 
  //            the specific string exists
  //        THEN 
  //            we have already initialized the EEPROM
  //        ELSE
  //            initialize the EEPROM as this section does
  //
  //--------------------------------------------------------------------------------------------------------------------
  /*
        //uncomment this section for the first use of the ESP 01
        //comment it for future usage
        //write 100 chars of '\0'
        for(int i=0;i<100;i++) //loop upto string lenght
        {
          EEPROM.write(0x0F+i,'\0'); //Write one by one with starting address of 0x0F
        }
        EEPROM.commit();    //Store data to EEPROM        
  */
  //--------------------------------------------------------------------------------------------------------------------

  //--------------------------------------------------------------------------------------------------------------------      
  // Test if a WiFi setting exist on the ESP01:
  // 1. Test if the first 20 tanks are at "#########"
  // 2. If so, we are in AP mode to configure
  // 3. Otherwise, we extract the SSID (the first 50 tanks from 0 to 49) and the Password (chars from 50 to 100)
  //--------------------------------------------------------------------------------------------------------------------          
        String ssid50char="", pass50char="";   
        //Here we dont know how many bytes to read (the real length of variables : ssid & password), so we use a terminating character
        Serial.println("Lecture de EPROM.."); //<-------------------------------- this is for debug purposes, to be removed when all tests are completed 
        for(int i=0;i<50;i++) 
        {
          char CC;
          CC = char(EEPROM.read(0x0F+i));
          if (CC != '\0'){
            ssid50char = ssid50char + CC; //Read one by one with starting address of 0x0F    
          }
        }  
        Serial.println("-- SSID : *"+ ssid50char+"*");  //<-------------------------------- this is for debug purposes, to be removed when all tests are completed 
        if (ssid50char == "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0") {
            //--------------------------------------------------------------------
            //         CASE 1: NO SAVED SETTINGS IN EEPROM 
            //--------------------------------------------------------------------            
            Serial.println("No existing WiFi setting!"); //<-------------------------------- this is for debug purposes, to be removed when all tests are completed 
            //Se mettre en mode accèss point
            WiFiAP();
            // Scan existing WiFi Networks to give the user the ability to select the WiFi network (Internet mode of the object)
            // NOTE : for performance considerations, we do not scan the network each time IF the user had already a preferred network (anyway, he/she can click on the scan link anytime)
            scanWifiNets(); //this updates the variable listeReseauxWifi            
            
        }else{
            //--------------------------------------------------------------------
            //         CASE 2: THERE IS A SAVED SETTINGS IN EEPROM 
            //--------------------------------------------------------------------           
            Serial.println("There is an existing WiFi setting!");//<-------------------------------- this is for debug purposes, to be removed when all tests are completed 
            //read the password from EPROM (SSID is already read)
            //Serial.println("Reading the password...");  
            for(int i=50;i<100;i++) 
            {
              char CC;
              CC = char(EEPROM.read(0x0F+i));
              if (CC != '\0'){
                  pass50char = pass50char + char(EEPROM.read(0x0F+i)); //Read one by one with starting address of 0x0F
              }    
            }  
            
            //Serial.println("-- Password : *"+ pass50char+"*");  //Print the text on the serial monitor            
            
            // use these two variables in HTML Edit and SELECT elements of the HTML page
            ssidWeb = ssid50char; 
            passwordWeb = pass50char;//+"\0";
            // prepare the HTML SELECT element of the Web page (the user can select the WiFi networj)
            listeReseauxWifi = "<select id=\"listeWi\" name=\"ssid\"><option value=\""+ssidWeb+"\" selected>"+ssidWeb+"</option><option value=\"\">Mode local (pas d'Internet)</option></select>";
            

            /*
            // The following is for debug purposes, to be used if you want
            Serial.println();
            Serial.println("PASWORD : ");
            Serial.println(passwordWeb);
            Serial.println("SSID : ");
            Serial.println(ssidWeb);            
            Serial.println("Liste : ");
            Serial.println(listeReseauxWifi);
            Serial.println();
            */
            // 1. Connection to the Wifi network
            // 2. IF fails THEN become A.P.
            //      Try to connect to WiFi with the values of SSID  and password
            //      If it fails, use the A.P. mode and inform the user that the connection is impossible
            entrainDeSeconnecter = "debutConnect"; //indicates that the current state of the connection is : at the beginning (i.e. we have just started a connection attempt)
            Serial.println("Status of the connection: "+entrainDeSeconnecter);//<-------------------------------- this is for debug purposes, to be removed when all tests are completed 
            orderDeConnexion = true; //this indicated that we just start an order to connect to an existing A.P.
            connectESPauReseauWiFiSinonDevientAP();                         
            
        }//end if (ssid50char == "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0") {
  
  EEPROM.end();                         
  //****************************************** End handling the EEPROM ***********************************************
  
  // Connect to the existing WiFi network AND take an IP address, the ESP8266 will be a WiFi "client" and in the same time a WEB "Server"
  // TODO: flashing a LED when trying to connext and fix it when connected (this will be good for the user's QoE)

  // Start the Web Server 
  WebServer.begin();
  Serial.println("Web Server started");                           // this is for debug purposes, to be removed when all tests are completed 

  // Print the IP address
  Serial.println("You can connect to the ESP8266 at this URL: "); // this is for debug purposes, to be removed when all tests are completed 
  Serial.println("http://");                                      // this is for debug purposes, to be removed when all tests are completed 
  Serial.print(WiFi.localIP());                                   // this is for debug purposes, to be removed when all tests are completed 
  Serial.print("/");                                              // this is for debug purposes, to be removed when all tests are completed 

  // Get the Mac address for our object to be dislayed by the Web user (so he/she can do NAT for example through his/her Internet box)  
  unsigned char mac[6];
  WiFi.macAddress(mac);
  esp8266Mac += getStringFromMacAddress(mac); 

}


//--------------------------------------------------------------------------------------------------------------------
// loop () general algo:
// 1. Manage the Web connections to our Web server
//        The Web requests (HTTP requests) can be:
//        1. Turn On the electrical device connected to our object
//        2. Turn Off the electrical device connected to our object
//        3. Change the mode of our object (Internet [i.e. connected to an existing A.P., example the one of the home box] 
//           or LAN [become an independant A.P.])
//        4. Trigger WiFi networks scan to discover existing WiFi networks
//        5. Select an existing WiFi network and enter the corresponding password
//        Note: any change is saved in memory of the ESP8266 thanks to this code
//--------------------------------------------------------------------------------------------------------------------
void loop() {
  // Check if a Web user is connected
  client = WebServer.available();
  if (!client) {
    return; //restart loop
  }

  // Wait until the user sends some data
  Serial.println("New Web user");// this is for debug purposes, to be removed when all tests are completed 
  while (!client.available()) {
    delay(1);
  }

  // Read the first line of the request
  String request = client.readStringUntil('\r\n');
  Serial.println(request);// this is for debug purposes, to be removed when all tests are completed 
  client.flush();

  // Process the request: (NOTE: use "else if" to optimize the processing)
  if (request.indexOf("/LED=ON") != -1) {
    //analogWrite(pinGPIO2, 1023);
    digitalWrite(pinGPIO2, LOW);
    delay(100); //wait a bit
    ledStatus = 1;
  }
  else if (request.indexOf("/LED=OFF") != -1) {
    //analogWrite(pinGPIO2, 0);
    digitalWrite(pinGPIO2, HIGH);
    delay(100); //wait a bit
    ledStatus = 0;
  }
  else if (request.indexOf("/LED=DIM") != -1) {
    analogWrite(pinGPIO2, 512);
    ledStatus = 2;
  }
  else if (request.indexOf("/WIFISCAN") != -1) {
    scanWifiNets(); //this updates the variable listeReseauxWifi
  }  
  else if (request.indexOf("/SETWIFI") != -1) {
      //if we are not already connecting with an SSID and a password
      if(entrainDeSeconnecter!="debutConnect"){
                    int startS;
                    ssidWeb = request;
                    ssidWeb.replace("GET /SETWIFI?ssid=", ""); //case GET /SETWIFI?ssid=blabla&pass=blibli HTTP/1.1
                    ssidWeb.replace("GET /SETWIFI", "");//case GET /SETWIFI HTTP/1.1
                    ssidWeb.replace(" HTTP/1.1", ""); //here ssidWeb will be "Aa&pass=Bb"
                    passwordWeb = ssidWeb; //here passwordWeb contains "Aa&pass=Bb"
                    startS = ssidWeb.indexOf("&pass=");
                    ssidWeb = ssidWeb.substring(0, startS);
                
                    passwordWeb.replace(ssidWeb, ""); //here passwordWeb contains "Aa&pass=Bb", transformed to"&pass=Bp"
                    passwordWeb.replace("&pass=", ""); passwordWeb.trim();
                    
                    ssidWeb = urldecode(ssidWeb);
                    passwordWeb = urldecode(passwordWeb);
                    Serial.println("SSID saisi (décodé): **"+ssidWeb+"**");        //<--- this is for debug purposes, to be removed when all tests are completed 
                    Serial.println("Password saisi (décodé): **"+passwordWeb+"**");//<--- this is for debug purposes, to be removed when all tests are completed 
                
                
                    //1. update the SSID & PASSWD into the Web interface (if the SSID is not empty)
                    if (ssidWeb != "") {
                        //a. prepare the Web fields for SSID & PASSWORD 
                        listeReseauxWifi = "<select id=\"listeWi\" name=\"ssid\"> \
                        <option value=\""+ssidWeb+"\" selected>"+ssidWeb+"</option> \
                        <option value=\"\">Mode local (pas d'Internet)</option> \
                        </select>";
                
                        //b. save ssid & password to EEPROM
                        //====== 3. Write string to eeprom
                        int addr = 0;
                        EEPROM.begin(512);  //Initialize EEPROM: Max bytes of eeprom to use
                        delay(100);
                        // write appropriate byte of the EEPROM.
                        // these values will remain there when the ESP8266 is turned Off      
                        //Write ssid to eeprom
                        Serial.println("Writing SSID to EPROM..."); //50 first chars //<--- this is for debug purposes, to be removed when all tests are completed 
                        for(int i=0;i<=(ssidWeb.length()-1);i++) //loop upto string lenght 
                        {
                          EEPROM.write(0x0F+i,ssidWeb[i]); //Write one by one with starting address of 0x0F
                        }
                        for(int i=(ssidWeb.length());i<50;i++) //we complete the remaining chars in the 50 chars with a null char
                        {
                          EEPROM.write(0x0F+i,'\0'); //Write one by one with starting address of 0x0F
                        }
                        
                        //Write password to eeprom starting from the position number 50 (because the chars from 0 to 49 are dedicated to SSID)
                        Serial.println("Writing PASS to EPROM..."); //50 first chars //<--- this is for debug purposes, to be removed when all tests are completed 
                        int j=0;
                        for(int i=50;i<=(50+passwordWeb.length()-1);i++) //loop upto string lenght
                        {
                          EEPROM.write(0x0F+i,passwordWeb[j]); //Write one by one with starting address of 0x0F
                          j=j+1;
                        }
                        for(int i=(50+passwordWeb.length());i<100;i++) //we complete the remaining chars in the 50 chars with a null char
                        {
                          EEPROM.write(0x0F+i,'\0'); //Write one by one with starting address of 0x0F
                        }                
                
                        EEPROM.commit();    //Store data to EEPROM
                        EEPROM.end();
                
                        //3. try to connect to the WiFi network with the values of SSID & password
                        //3.1 if it fails, we make the ESP in the WiFi AP mode and inform the user in the Web page 
                          entrainDeSeconnecter = "debutConnect"; //indicates that the status of the current connection is at the beginning (i.e. we have just started a connection attempt)
                          Serial.println("Status of the connection: "+entrainDeSeconnecter);//<--- this is for debug purposes, to be removed when all tests are completed 
                          orderDeConnexion = true; //indicates that we just triggered an order of connection to an existing A.P.
                        
                         

                                      
                    }//fin if (ssidWeb != "") {
                    else{
                      //SSID is empty so we are the LOCAL mode of the ESP8266
                      EEPROM.begin(512);  //Initialize EEPROM: Max bytes of eeprom to use 
                      //écrire 100 char de '\0'
                      for(int i=0;i<100;i++) //loop upto string lenght
                      {
                        EEPROM.write(0x0F+i,'\0'); //Write one by one with starting address of 0x0F
                      }
                      EEPROM.commit();    //Store data to EEPROM
                      EEPROM.end();                        
                      entrainDeSeconnecter = "localMode"; //indicates that the status of the current connection is : at the beginning (i.e. we have just started a connection attempt)
                    }   
      }//end if(entrainDeSeconnecter!="debutConnect"){
  }//end if (request.indexOf("/SETWIFI") != -1) {
  // refresh value in seconds: time to refresh the HTML page  if necessarily (case of waiting that the ESP8266 connect to an AP
  int raffrichissement = 30;
  client.println("HTTP/1.1 200 OK");                                                                      //<--- HTTP header required for the Web communication between the Web server and the client
  client.println("Content-Type: text/html; charset=UTF-8");                                               //<--- HTTP header required for the Web communication between the Web server and the client
  client.println("Connection: close");  // the connection will be closed after completion of the response //<--- HTTP header required for the Web communication between the Web server and the client
  //if (entrainDeSeconnecter == "debutConnect"){ client.println("Refresh: 30");}
  client.println("");                                                                                     //<--- end of the HTTP headers required for the Web communication between the Web server and the client
  client.println("<!DOCTYPE HTML>");                                                                      //<--- HTML page content - required for the Web communication between the Web server and the client
  client.println("<html>");                                                                               //<--- HTML page content - required for the Web communication between the Web server and the client
  client.println("<head>");                                                                               //<--- HTML page content - required for the Web communication between the Web server and the client



  
  client.println("<title>ESP8266 IoT Based Object</title>");                                              //<--- HTML page content - required for the Web communication between the Web server and the client
  client.println("<style>");                                                                              //<--- HTML page content - required for the Web communication between the Web server and the client
  client.println("html {text-align: center;}");                                                           //<--- HTML page content - required for the Web communication between the Web server and the client
  client.println("    * {");                                                                              //<--- HTML page content - required for the Web communication between the Web server and the client
  client.println("      font-family: sans-serif;");                                                       //<--- HTML page content - required for the Web communication between the Web server and the client
  client.println("    }");                                                                                //<--- HTML page content - required for the Web communication between the Web server and the client
  client.println("#butt {color: white;font-size: 16px;border-radius: 15px; width:200px; height:200px;}");                                                                      //<--- HTML page content - required for the Web communication between the Web server and the client 
  client.println("#listeWi{width:250px;}");                                                               //<--- HTML page content - required for the Web communication between the Web server and the client 
  client.println("</style>");                                                                             //<--- HTML page content - required for the Web communication between the Web server and the client  
  client.println("</head>");                                                                              //<--- HTML page content - required for the Web communication between the Web server and the client
  client.println("<body>");                                                                               //<--- HTML page content - required for the Web communication between the Web server and the client
  
  //-------------------------------------------------------------------------------------------------------------------
  // This section is added in the beguening of WiFi connection of the ESP01 to an A.P. for special browsers as Safari
  //-------------------------------------------------------------------------------------------------------------------
  Serial.println("Status of the connection: "+entrainDeSeconnecter);
  
  if (entrainDeSeconnecter == "debutConnect"){
      //this code is added for browser that does not support the HTML refresh correctly as SAFARI browser
      Serial.println("Sending to Web client :         setTimeout('Redirect()', "+String(raffrichissement*1000)+");");
      
      client.println("<script type=\"text/javascript\">");                                             //<--- HTML page content - required for the Web communication between the Web server and the client   
      client.println("       function Redirect()");                                                    //<--- HTML page content - required for the Web communication between the Web server and the client 
      client.println("       {");                                                                      //<--- HTML page content - required for the Web communication between the Web server and the client  
      client.println("           window.location=\"http://192.168.1.50/\";");                          //<--- HTML page content - required for the Web communication between the Web server and the client 
      client.println("        }"); 
      client.println("         setTimeout('Redirect()', "+String(raffrichissement*1000)+");"); //this is in milliseconds //<--- HTML page content - required for the Web communication between the Web server and the client     
      client.println("</script>");                                                                     //<--- HTML page content - required for the Web communication between the Web server and the client     
  }
  
  client.println("<a href=\"/\">Home (refresh)</a><br/><br/>");                                            //<--- HTML page content - required for the Web communication between the Web server and the client
  client.println("<b><font style=\"font-size: 25px; color: #4286f4;\">SMART POWER PLUG</font></b><br/>");  //<--- HTML page content - required for the Web communication between the Web server and the client
  client.println("<b><font style=\"font-size: 18px; color: #4286f4;\">version: 0.1a</font></b><br/>");     //<--- HTML page content - required for the Web communication between the Web server and the client
  client.println("<font style=\"font-size: 12px; color: #4286f4;\">MAC: "+esp8266Mac+"</font>");           //<--- HTML page content - required for the Web communication between the Web server and the client
    
  client.println("</br></br>");                                                                            //<--- HTML page content - required for the Web communication between the Web server and the client

  //check the Power status of the realy
  if (ledStatus == 0) {
    client.print("POWER RELAY is Off</br><br/>");                                                          //<--- HTML page content - required for the Web communication between the Web server and the client
    client.println("<form action=\"/LED=ON\"><input id=\"butt\" style=\"background-color: #4CAF50\" type=\"submit\" value=\"TURN POWER ON\" /></form>");   //<--- HTML page content - required for the Web communication between the Web server and the client
  } else if (ledStatus == 1) {
    client.print("POWER RELAY is On</br><br/>");                                                           //<--- HTML page content - required for the Web communication between the Web server and the client
    client.println("<form action=\"/LED=OFF\"><input id=\"butt\" style=\"background-color: #AF4C50;\" type=\"submit\" value=\"TURN POWER OFF\" /></form>"); //<--- HTML page content - required for the Web communication between the Web server and the client
  } //else if (ledStatus == 2) {

  client.println("<br/><br/><b>Configuration Internet <br/>(laisser \"Mode local (pas d'Internet)\" pour le mode LOCAL de l'objet)</b>:<br/>"); //<--- HTML page content
  client.println("<a href=\"/WIFISCAN\">new WiFi scan</a></br>");                                                                                //<--- HTML page content  
  client.println("<form action=\"/SETWIFI\">");                                                                                                 //<--- HTML page content
  client.println(" WiFi network: ");                                                                                                            //<--- HTML page content
  client.println(listeReseauxWifi);                                                                                                             //list of detected WiFi networks  //<--- HTML page content
  client.println("<br/> Password :");                                                                                                           //TODO : hide it as default  //<--- HTML page content
  client.println("  <input type=\"text\" name=\"pass\" size=\"40\" value=\""+passwordWeb+"\">");                                                //<--- HTML page content
  client.println("  <br>");                                                                                                                     //<--- HTML page content
  client.println("  <input type=\"submit\" value=\"Set WiFi Connection\">");                                                                    //<--- HTML page content
  client.println("</form>");                                                                                                                    //<--- HTML page content

  if (entrainDeSeconnecter == "debutConnect") { client.println("<br/><font color=\"#dd6b1f\">connexion WiFi en cours (attendre 30s)..</font><br/>"); } //<--- HTML page content
  else if (entrainDeSeconnecter == "succesConnect") { client.println("<br/><font color=\"#64bc16\">connexion WiFi OK!</font><br/>");}                  //<--- HTML page content
  else if (entrainDeSeconnecter =="echecConnect") { client.println("<br/><font color=\"#dd0b43\">connexion WiFi impossible !<br/>L'objet est rendu en mode local.</font><br/>");} //<--- HTML page content
  else if (entrainDeSeconnecter == "localMode") { client.println("<br/><font color=\"#64bc16\">Objet en mode local !</font><br/>");} //<--- HTML page content


  client.println("</br>");//<--- HTML page content
  client.println("<a href=\"http://www.lemlouma.com\" target=\"_blank\">Smart Power Plug<br/> Tayeb L. Aug. 2018 &copy;</a></br>");//<--- HTML page content

  client.println("</br>");      //<--- HTML page content
  client.println("</body>");    //<--- HTML page content
  client.println("</html>");    //<--- HTML page content

  client.flush();
  delay(10);          // give the web browser time to receive the data
  client.stop();      // close the connection:
  Serial.println("Web user disconnected");  //<-------------------------------- this is for debug purposes, to be removed when all tests are completed 
  Serial.println("");                       //<-------------------------------- this is for debug purposes, to be removed when all tests are completed 

  // I do the following after the HTTP response in order to not block the browser when we try to connect to a WiFi A.P.:  
  if (orderDeConnexion == true){
        //I do the following after the HTTP response in order to not block the browser when we try to connect to a WiFi A.P.:
        connectESPauReseauWiFiSinonDevientAP();
  }//if (orderDeConnexion == true){
  

}//end void loop() {

//--------------------------------------------------------------------------------------------------------------------
// Make the ESP8266 in a WiFi Access Point mode, with the SSID : SmartPowerPlug_XX (XX: last two bytes of the MAC @ of the ESP01 to differentiate our ESP if there are several)
//--------------------------------------------------------------------------------------------------------------------
void WiFiAP()
{
  //Make the ESP8266 in a WiFi Access Point mode, with the SSID : SmartPowerPlug_XX (XX: last two bytes of the MAC @ of the ESP01 to differentiate our ESP if there are several)
  //---------------------------------------------------------------
  
  const char WiFiAPpwd[] = "admin";                             //we don't use it for the moment, our ESP8266 wil be an opened WiFi A.P.
  Serial.println();
  Serial.println("Setting Object into a A.P. Mode ... ");

  //Set a custom IP address for the ESP8266
  WiFi.mode(WIFI_AP_STA);
  IPAddress    apIP(192, 168, 1, 50);                           //<-------------------------------- this is for debug purposes, make it to 192.168.1.1 or 192.168.1.254 as recommended 
  WiFi.softAPConfig(apIP, apIP, IPAddress(255, 255, 255, 0));   // Subnet of the network : 255.255.255.0 (or /24)  

  //extract the last two bytes of the MAC @ of the ESP01 to differentiate our ESP if there are several
  uint8_t mac[WL_MAC_ADDR_LENGTH];
  WiFi.softAPmacAddress(mac);
  String macID = String(mac[WL_MAC_ADDR_LENGTH - 2], HEX) +
                 String(mac[WL_MAC_ADDR_LENGTH - 1], HEX);
  macID.toUpperCase();
  String AP_NameString = "SmartPowerPlug_" + macID; //append the last two bytes of the MAC @ of the ESP01 to the SSID of our ESP01 in order differentiate our ESP if there are several
  char AP_NameChar[AP_NameString.length() + 1];
  memset(AP_NameChar, 0, AP_NameString.length() + 1);
  for (int i=0; i<AP_NameString.length(); i++)
    AP_NameChar[i] = AP_NameString.charAt(i);

  
  //we don't use WiFiAPpwd for the moment, our ESP8266 wil be an opened WiFi A.P.
  boolean result = WiFi.softAP(AP_NameChar);//use "WiFi.softAP(AP_NameChar, WiFiAPpwd);" if you want to protect the ESP01 A.P. 
  if(result == true)
  {
    Serial.println("A.P. Ready");                 //<-------------------------------- this is for debug purposes, make it to 192.168.1.1 or 192.168.1.254 as recommended 
    IPAddress myIP = WiFi.softAPIP();
    Serial.println("AP IP address: ");            //<-------------------------------- this is for debug purposes, make it to 192.168.1.1 or 192.168.1.254 as recommended 
    Serial.println(myIP);                         //<-------------------------------- this is for debug purposes, make it to 192.168.1.1 or 192.168.1.254 as recommended 
  }else{
    Serial.println("A.P. mode Failed!");          //<-------------------------------- this is for debug purposes, make it to 192.168.1.1 or 192.168.1.254 as recommended 
  }
}

//------------------------------------------------------------------------------------------------------------------------------------------------
// Main function used to connect the ESP8266 to the WiFi network selected by the user, otherwise return to AP mode (ESP will be a WiFi A.P.)
//------------------------------------------------------------------------------------------------------------------------------------------------
void connectESPauReseauWiFiSinonDevientAP(){
        const char* ssidWebCHAR;
        const char* passwordWebCHAR;
        Serial.println();                         //<-------------------------------- this is for debug purposes, to be removed when all tests are completed 
        //entrainDeSeconnecter = "debutConnect";
        //WiFi.disconnect();
        //WiFi.mode(WIFI_STA);
        /*
        I uncommented the 2 previous lines for the following reason:
          - The logic was to use the WIFI_STA mode to connect the ESP8266 to the existing network, BUT NO:
          - In fact, when sending a connection request, the page does not load at all client side. See this error reported on 
          https://github.com/esp8266/Arduino/issues/1384 
          (message from bachi76 and hakeemta) : 

          Citation :
          "Just to confirm: Indeed, if WIFI_STA was set I experienced constant websocket connection interruptions, usually 1-2 times 
          / min. :
          
          WiFi.mode(WIFI_STA);
          WiFi.begin(..., ...);
          Setting WiFi.mode(WIFI_AP); has completely solved this, even though the ESP connects to the existing network as if were in 
          STA mode..
          
          WiFi.mode(WIFI_AP);
          WiFi.begin(..., ...);
          (I need to connect to an existing network - so using WIFI_AP is actually wrong, but apparently still connecting if the 
          specified network already exists).
          
          With WIFI_STA mode set I couldn't get a stable websocket connection. Tested with two devices to be sure. Looks like a bug to me. 
          @igrr ?        
          "
        
        */
        
        Serial.println("Connecting to ");                                                             //<-------------------------------- this is for debug purposes, to be removed when all tests are completed 
        Serial.println(ssidWeb);                                                                      //<-------------------------------- this is for debug purposes, to be removed when all tests are completed 
        ssidWebCHAR = ssidWeb.c_str(); passwordWebCHAR = passwordWeb.c_str();
        Serial.println("[SSID: *"+String(ssidWebCHAR)+"*, PASSWORD: *"+String(passwordWebCHAR)+"*]"); //<-------------------------------- this is for debug purposes, to be removed when all tests are completed 
        WiFi.begin(ssidWebCHAR, passwordWebCHAR);
        IPAddress ip(192,168,1,50); //We fix the IP address
        IPAddress gateway(192,168,1,102);   
        IPAddress subnet(255,255,255,0);   
        WiFi.config(ip, gateway, subnet);
        int tentative = 0;
        while (WiFi.status() != WL_CONNECTED) {
          delay(500);          //wait 500ms
          Serial.println("."); //<-------------------------------- this is for debug purposes (progression of WiFi connection), to be removed when all tests are completed 
          tentative = tentative+1;
          //try to connect during 20s (40x500ms), don't forget that the client Web page will be refreshed after 30 seconds
          if (tentative > 40){
             //if we made more than 40 try, we stop and go out, we don't insist!
             entrainDeSeconnecter = "echecConnect";
             break; 
          } 
        }
        Serial.println("");                                                                           //<-- this is for debug purposes, to be removed when all tests are completed 
        if (entrainDeSeconnecter !="echecConnect") entrainDeSeconnecter = "succesConnect";
        Serial.println("End of the WiFi connection process, status: "+entrainDeSeconnecter);          //<-- this is for debug purposes, to be removed when all tests are completed 
        orderDeConnexion = false;//to avoid triggering again a connection each received Web request
        
        //If we fail to connect the ESP8266 to an existing WiFi network, become in A.P mode
        if (entrainDeSeconnecter == "echecConnect"){
            Serial.println("Can not connect to WiFi, become a WiFi AP..");
            //become access point
            WiFiAP();

        }
}//end void connectESPauReseauWiFiSinonDevientAP(){

//--------------------------------------------------------------------------------------------------------------------
// Scan WiFi networks that exist around our object so that the user can selects one
// (the user select once and this will be saved. But he/she can change his/her choice anytime
// the choice of the user is saved in EEPROM which is persistent even after restarting the ESP8266)
//--------------------------------------------------------------------------------------------------------------------
void scanWifiNets() {
  //Scan existing WiFi networks  
  listeReseauxWifi = "<select id=\"listeWi\" name=\"ssid\"><option value=\"\" selected>Mode local (pas d'Internet)</option>";

  // WiFi.scanNetworks will return the number of wiFi networks found in the neighborhood
  int n = WiFi.scanNetworks();
  Serial.println("scan done");                                                            //<-- this is for debug purposes, to be removed when all tests are completed 
  if (n == 0) {
    //Serial.println("no networks found");
  } else {
    //Serial.println(n);
    //Serial.println(" networks found");
    for (int i = 0; i < n; ++i) {
      // Print SSID and RSSI for each network found
      Serial.println(i + 1);                                                //<-- this is for debug purposes, to be removed when all tests are completed 
      Serial.println(": ");                                                 //<-- this is for debug purposes, to be removed when all tests are completed 
      Serial.println(WiFi.SSID(i));                                         //<-- this is for debug purposes, to be removed when all tests are completed 
      Serial.println(" (");                                                 //<-- this is for debug purposes, to be removed when all tests are completed 
      Serial.println(WiFi.RSSI(i));                                         //<-- this is for debug purposes, to be removed when all tests are completed 
      Serial.println(")");                                                  //<-- this is for debug purposes, to be removed when all tests are completed 
      Serial.println((WiFi.encryptionType(i) == ENC_TYPE_NONE) ? " " : "*");//<-- this is for debug purposes, to be removed when all tests are completed 
      delay(10);
      //when the discovered network is encrypted, append to its SSID a "*"
      String encrypt = (WiFi.encryptionType(i) == ENC_TYPE_NONE) ? " " : "*";
      listeReseauxWifi = listeReseauxWifi + "<option value=\""+WiFi.SSID(i)+"\">"+WiFi.SSID(i)+" ["+String(WiFi.RSSI(i))+encrypt+"]</option>";
    }
  }
  
  listeReseauxWifi = listeReseauxWifi +"</select>";
  Serial.println("");


}//end void scanWifiNets() {

//-----------------------------------------------------------------------------------------------------------------------------------------------------
// Function used to decode the data received by through the Web (example special characters in the password typed by the user in the HTML edit element)
//-----------------------------------------------------------------------------------------------------------------------------------------------------
String urldecode(String str) 
{
    
    String encodedString="";
    char c;
    char code0;
    char code1;
    for (int i =0; i < str.length(); i++){
        c=str.charAt(i);
      if (c == '+'){
        encodedString+=' ';  
      }else if (c == '%') {
        i++;
        code0=str.charAt(i);
        i++;
        code1=str.charAt(i);
        c = (h2int(code0) << 4) | h2int(code1);
        encodedString+=c;
      } else{
        
        encodedString+=c;  
      }
      
      yield();
    }
    
   return encodedString;
}//end String urldecode(String str)
//--------------------------------------------------------------------------------------------------------------------------------------
// Function used by the function urldecode
// useful for decoding special chars in the ssid / pass received by the Web request (a password can contain any special character)
//--------------------------------------------------------------------------------------------------------------------------------------
unsigned char h2int(char c) 
{
    if (c >= '0' && c <='9'){
        return((unsigned char)c - '0');
    }
    if (c >= 'a' && c <='f'){
        return((unsigned char)c - 'a' + 10);
    }
    if (c >= 'A' && c <='F'){
        return((unsigned char)c - 'A' + 10);
    }
    return(0);
}//unsigned char h2int(char c)

//--------------------------------------------------------------------------------------------------------------------
// Function used by setup to display the ESP8266 mac @
//--------------------------------------------------------------------------------------------------------------------
String getStringFromMacAddress(const uint8_t* mac)
{
  String stringResult;
  for (int i = 0; i < 6; ++i) {
    stringResult += String(mac[i], 16);
    if (i < 5)
    stringResult += ':';
  }
  return stringResult;
}
