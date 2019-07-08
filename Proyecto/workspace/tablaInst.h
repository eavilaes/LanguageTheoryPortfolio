#include <stdlib.h>

typedef char tipo_cadena[50];

union tipo_cont{
	int valor_entero;
	float valor_real;
	bool valor_bool;
	tipo_cadena valor_cadena;
};

struct tipo_datoTInst{
	int tipo;
	tipo_cont valor;
	tipo_cadena ref;
	int nBucle=0;
};

struct inst {
	tipo_datoTInst elem;
	struct inst *sig;
};

class TablaInst{
	public:
		inst *primero;

		bool insertar (tipo_datoTInst *identificador);
		inst * getPrimero();
};
