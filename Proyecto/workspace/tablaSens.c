#include "tablaSens.h"
#include <stdio.h>
#include <string.h>

sens * TablaSens::getPrimero(){
	return primero;
}

bool TablaSens::insertar (tipo_datoTSens *identificador){
	sens * act = getPrimero();
	sens * aux;
	bool enc = false, insertado=false;
	if(act==NULL){
		primero=(sens*)malloc(sizeof(sens));
		primero->elem = *identificador;
		primero->sig=NULL;
		insertado=true;
		//printf("***Insertado %s en la primera posición\n", identificador->nombre);
	}else{
		if(strcmp(act->elem.nombre, identificador->nombre)==0)
			enc=true;		
		while(act->sig!=NULL && !enc){
			act=act->sig;
			if(strcmp(act->elem.nombre, identificador->nombre)==0)
				enc=true;
		}
		if(!enc){
			aux=(sens*)malloc(sizeof(sens));
			aux->elem=*identificador;
			aux->sig=NULL;
			act->sig=aux;
			insertado=true;
			//printf("***No se ha encontrado %s, se crea una nueva entrada en la tabla\n", identificador->nombre);
		}else{
			if(identificador->tipo==act->elem.tipo){
				aux->elem.posY=identificador->posY;
				aux->elem.posX=identificador->posX;
				aux->elem.encendido=identificador->encendido;
				aux->elem.inicializado=identificador->inicializado;
				if(act->sig==NULL)
					aux->sig=NULL;
				else
					aux->sig = act->sig;
				insertado=true;
				//printf("***Se ha encontrado %s y se ha actualizado con el nuevo valor\n", identificador->nombre);
			}//else
				//printf("***Se ha encontrado %s y no coincide en el tipo. No se actualiza\n", identificador->nombre);
		}
	}
	return insertado;
}

bool TablaSens::buscar(tipo_cadena nombre, tipo_datoTSens *identificador){
	sens *aux = getPrimero();
	bool enc=false;
	while(aux!=NULL && !enc){
		if(strcmp(nombre, aux->elem.nombre)==0){
			enc=true;
			strcpy((*identificador).nombre,aux->elem.nombre);
			(*identificador).tipo=aux->elem.tipo;
			(*identificador).posY=aux->elem.posY;
			(*identificador).posX=aux->elem.posX;
			strcpy((*identificador).alias,aux->elem.alias);
			(*identificador).encendido=aux->elem.encendido;
			(*identificador).inicializado=aux->elem.inicializado;
		}else
			aux=aux->sig;
	}
	return enc;
}
