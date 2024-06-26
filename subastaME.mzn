% Parámetros
int: N; % cantidad de generadores en el mercado eléctrico.
int: M; % número de unidades de tiempo en que está dividido el día.
array[0..M-1] of int: D;  % arreglo que representa la demanda de energía en KW de los consumidores en cada hora j.
int: P; % precio máximo de compra por KW.
array[0..M-1, 1..N] of int: C; % matriz que representa la capacidad de producción de energía en KW de cada generador i en cada hora j.
array[1..N] of int: PV;  % arreglo que representa el precio de venta de energía por KW de cada generador i.

% Variables
var int: PC; % precio de compra de la energía. 
array[0..M-1, 1..N] of var int: V; % matriz que representa la cantidad de KW que debe comprarse a cada generador i en cada hora j.
array[1..N] of var int: PVSelected; % arreglo que representa el precio de venta de energía por KW de cada generador i seleccionado.

% Restricciones

% No negatividad.
constraint assert(N >= 0, "(N): la cantidad de generadores en el mercado eléctrico debe ser mayor o igual a 0.");
constraint assert(M >= 1, "(M): el número de unidades de tiempo en que está dividido el día debe ser mayor o igual a 1.");
constraint assert(P >= 0, "(P): el precio máximo de compra por KW debe ser mayor o igual a 0.");
constraint PC >= 0;

constraint forall(j in 0..M-1)(
  D[j] >= 0
);

constraint forall(j in 0..M-1)(
  forall(i in 1..N)(
    C[j,i] >= 0
  )
);

constraint forall(i in 1..N)(
  PV[i] >= 0
);

constraint forall(i in 1..N)(
  PVSelected[i] >= 0
);

constraint forall(j in 0..M-1)(
  forall(i in 1..N)(
    V[j,i] >= 0
  )
);

% Se satisface toda la demanda en cada unidad de tiempo.
constraint forall(j in 0..M-1)(
  D[j] = sum(i in 1..N)(V[j,i])
);


% El precio al que se compra la energía a cada generador no supera el precio máximo de compra establecido.
constraint forall(i in 1..N)(
  PVSelected[i] <= P
);

% La compra de energía a cada generador no supera su capacidad.
constraint forall(j in 0..M-1)(
  forall(i in 1..N)(
    V[j,i] <= C[j,i]
  )
);

% El precio de compra es el mayor PVi entre los precios de venta de los generadores seleccionados.
constraint forall(i in 1..N)(
  if sum(j in 0..M-1)(V[j,i]) > 0 then PVSelected[i] = PV[i] else PVSelected[i] = 0 endif
);

constraint forall(i in 1..N)(
  PVSelected[i] <= PC
);


% Condición redundante
constraint PC = max(PVSelected);

% Objetivo
solve :: int_search(V, anti_first_fail, indomain_min) minimize PC;


output ["V =\n"];
output ["Hora | " ];
output ["Gen \(i) " | i in 1..N];
output ["\n"];
output ["\(j)    " ++ "\([V[j,i] | i in 1..N])" ++ "\n" | j in 0..M-1];
output ["Precio de compra = \(PC)\n"];
        
