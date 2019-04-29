#include <stdlib.h>

typedef char tipo_cadena[50];

union tipo_valor{
	int valor_entero;
	float valor_real;
	bool valor_bool;
};

struct tipo_datoTS{
	tipo_cadena nombre;
	int tipo;
	tipo_valor valor;
	bool inicializado;
};

struct nodo {
	tipo_datoTS elem;
	struct nodo *sig;
};

class Tabla{
	public:
		nodo *primero;

		bool insertar (tipo_datoTS *identificador);
		bool buscar (tipo_cadena nombre, tipo_datoTS *identificador);
		nodo * getPrimero();
};
