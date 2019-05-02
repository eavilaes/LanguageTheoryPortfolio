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
	start; pause;	
	indoorTemp	18.2;	#el sensor indoorTemp ha detectado una temperatura de 18.2 grados
	if indoorTemp < winterTemp
	then [ 
		Heat ON;   #encender calefacción
		Whatsapp ON "Calefacción encendida";
	];
	pause 3;
	Whatsapp OFF;	
	indoorTemp	28.2;	#el sensor indoorTemp ha detectado una temperatura de 28.2 grados
	if indoorTemp > winterTemp + 5
	then [ 
		Heat OFF;    #apagar calefacción
		Whatsapp ON "Calefacción apagada";
	];
	pause;
	Whatsapp OFF;	
];

scene Fire [
	start; pause 1;
	S	100; #el sensor ha detectado la presencia de humo
	if (S != 0)
	then [
		Whatsapp ON msg;			
		repeat 2 [   #se producirán 4 pitidos en intervalos de 1 segundo
			A ON;   
			pause 1;
		];
		Whatsapp OFF;	
	];
];
