#Este programa describe el comportamiento de una casa inteligente
#el programa es correcto
#Primera parte, zona de definiciones 
#Variables
int  		f,c;
float  		winterTemp,summerTemp;
position	p_Sensor;   string    	msg;

#Asignaciones
c = 4; f = 5*c;
summerTemp = 24.5;
winterTemp = summerTemp * 0.85;
p_Sensor = <f,c+16>;
msg = "Alarma. Alta probabilidad de incendio";

#sensores y actuadores
temperature indoorTemp p_Sensor "T1";	#sensor de temperatura
smoke S <250,250> "S2";			#sensor de humo
light L <500,500> "L1";			#sensor de luminosidad

alarm A ;			#alarma sonora
switch Heat <480,420> "CA";	#calefacción
switch Lamp <550,250> "La";	#lámpara 
message Whatsapp;		#envío de mensajes

%%

#Segunda parte, definición del comportamiento del sistema en diferentes escenarios
scene Winter [
	start; pause 1;
	indoorTemp	18.2;	#el sensor indoorTemp ha detectado una temperatura de 18.2 grados

];
