#include "tablaInst.h"
#include <stdio.h>

inst * TablaInst::getPrimero(){
	return primero;
}

bool TablaInst::insertar (tipo_datoTInst *identificador){
	inst * act = getPrimero();
	inst * aux;
	bool enc = false, insertado=false;
	if(act==NULL){
		primero=(inst*)malloc(sizeof(inst));
		primero->elem = *identificador;
		primero->sig=NULL;
		insertado=true;
		//printf("***Insertado en la primera posición\n");
	}else{	
		while(act->sig!=NULL)
			act=act->sig;
		aux=(inst*)malloc(sizeof(inst));
		aux->elem=*identificador;
		aux->sig=NULL;
		act->sig=aux;
		insertado=true;
		//printf("***No se ha encontrado, se crea una nueva entrada en la tabla\n");
	}
	return insertado;
}
