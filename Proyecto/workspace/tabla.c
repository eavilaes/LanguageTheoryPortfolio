#include "tabla.h"
#include <stdio.h>
#include <string.h>

nodo * Tabla::getPrimero(){
	return primero;
}

bool Tabla::insertar (tipo_datoTS *identificador){
	nodo * act = getPrimero();
	nodo * aux;
	bool enc = false, insertado=false;
	if(act==NULL){
		primero=(nodo*)malloc(sizeof(nodo));
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
			aux=(nodo*)malloc(sizeof(nodo));
			aux->elem=*identificador;
			aux->sig=NULL;
			act->sig=aux;
			insertado=true;
			//printf("***No se ha encontrado %s, se crea una nueva entrada en la tabla\n", identificador->nombre);
		}else{
			if(identificador->tipo==act->elem.tipo){
				aux->elem.valor=identificador->valor;
				if(act->sig==NULL)
					aux->sig=NULL;
				else
					aux->sig = act->sig;
				aux->elem.inicializado=true;
				insertado=true;
				//printf("***Se ha encontrado %s y se ha actualizado con el nuevo valor\n", identificador->nombre);
			}//else
				//printf("***Se ha encontrado %s y no coincide en el tipo. No se actualiza\n", identificador->nombre);
		}
	}
	return insertado;
}

bool Tabla::buscar(tipo_cadena nombre, tipo_datoTS *identificador){
	nodo *aux = getPrimero();
	bool enc=false;
	while(aux!=NULL && !enc){
		if(strcmp(nombre, aux->elem.nombre)==0){
			enc=true;
			strcpy((*identificador).nombre,aux->elem.nombre);
			(*identificador).tipo=aux->elem.tipo;
			if(identificador->tipo==0)
				(*identificador).valor.valor_entero=aux->elem.valor.valor_entero;
			else if(identificador->tipo==1)
				(*identificador).valor.valor_real=aux->elem.valor.valor_real;
			else
				(*identificador).valor.valor_bool=aux->elem.valor.valor_bool;
		}else
			aux=aux->sig;
	}
	return enc;
}
