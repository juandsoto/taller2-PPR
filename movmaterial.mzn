include "globals.mzn";

int: n; %numero de bodegas; almacena material que se mide en unidades
int: M; %unidades de material; distribuidos en las n bodegas

int: a;
int: b;
  
array[1..n] of 0..M: m; %distribucion inicial
array[1..n] of 0..M: o; %distribucion final

array[1..n, 1..n] of var 0..M: mov;

constraint a >= 1 /\ b >= 1;
constraint sum(i in 1..n)(m[i]) = M;
constraint sum(i in 1..n)(o[i]) = M;

function var int: calcular_costo(var int: e, int: i, int: j) = pow(e,a) * pow((abs(j-i)),b);

% Restricciones
constraint forall(i,j in 1..n where i != j)(
  (mov[i,j] = abs(o[i] - m[i]) \/ mov[j,i] = abs(o[i] - m[i])) \/ o[i] = m[i]
);

var int: costo;

constraint costo = sum(i,j in 1..n where i != j)(calcular_costo(mov[i,j],i,j));

solve minimize costo;


output [show(mov) ++ " - " ++ show(costo)];