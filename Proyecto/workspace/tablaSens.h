#include <stdlib.h>

typedef char tipo_cadena[50];

//union tipo_valor{
//	int valor_entero;
//	float valor_real;
//	bool valor_bool;
//};

struct tipo_datoTSens{
	int posY;
	int posX;
	tipo_cadena nombre;
	int tipo;
	tipo_cadena alias;
	float valor;
	bool inicializado;
};

struct sens {
	tipo_datoTSens elem;
	struct sens *sig;
};

class TablaSens{
	public:
		sens *primero;

		bool insertar (tipo_datoTSens *identificador);
		bool buscar (tipo_cadena nombre, tipo_datoTSens *identificador);
		bool actualizarValor (tipo_cadena nombre, float nValor);
		sens * getPrimero();
};
