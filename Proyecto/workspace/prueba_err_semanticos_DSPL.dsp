#Este programa describe el comportamiento de una casa inteligente
#el programa tiene varios errores semánticos no se debe generar fichero de salida 
#Primera parte, zona de definiciones 
#Variables
int  		f,c;
float  		winterTemp,summerTemp;
position	p_Sensor;   string    	msg;

#Asignaciones
c = 4; f = 5*cc;    	#error semántico: la variable cc no existe
c = c * 1.5;     	#error semántico: a una variable de tipo entero no se le puede asignar un valor real
summerTemp = 24.5;
winterTemp = summerTemp * 0.85;
p_Sensor = <500,500>;
msg = "Alarma. Alta probabilidad de incendio";


#sensores y actuadores
temperature indoorT p_Sensor "T1";	#error semántico: la posición del sensor está fuera de los límites
					#este  error se podría haber detectado también al asignar el valor a la variable 
temperature indoorTemp <100,100> "T1";
smoke S <250,250> "SH";			

alarm A;			
switch Heat <480,420> "CALEFACCION";  	#warning: el alias es demasiado largo	
					#error semántico: la posición del actuador está fuera de los límites
			
message Whatsapp;	

f = A + 1;    	#error semántico: el nombre de un actuador no puede aparecer en una expresión aritmética	
f = msg * 5;    #error semántico: no se pueden realizar operaciones aritméticas con variables de tipo cadena	

%%
#Segunda parte, definición del comportamiento del sistema en diferentes escenarios

scene Winter [
	start; 
	pause 2.5;   #error semántico: el parámetro de pause no puede ser de tipo real	
	indoorTemp	18.2;	
	if indoorTemp < winterTemp
	then [ 
		Heat ON;    				#error semántico: Heat no existe
		Whatsap ON "Calefacción encendida"; 	#error semántico: Whatsap no existe
	];
	pause c;
	Whatsapp OFF;	
	indoorTemp	28.2;	
	if indoorTemp > p_Sensor + 5  #error semántico: no se pueden realizar operaciones aritméticas con variables de tipo posicion
	then [ 
		S OFF;    #error semántico: S no es un actuador
		Whatsapp ON "Calefacción apagada";
	];
	pause;
	Whatsapp OFF;	
];


scene Fire [
	start; pause 1;
	A	100;  	#error semántico: a un actuador no se le puede asignar un valor
	if (A != 0)     #error semántico: un actuador no puede formar parte de una expresión porque no tiene valor
	then [
		Whatsapp ON msg;			
		repeat 2 [   
			A ON;   
			pause 1;
		];
		Whatsapp OFF;	
	];

];


