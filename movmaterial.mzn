include "globals.mzn";

int: n; %numero de bodegas; almacena material que se mide en unidades
int: M; %unidades de material; distribuidos en las n bodegas

int: a;
int: b;
  
array[1..n] of 0..M: m; %distribucion inicial
array[1..n] of 0..M: o; %distribucion final

array[1..n, 1..n] of var 0..M: mov;

function var int: calcular_costo(var int: e, int: i, int: j) = pow(e,a) * pow((abs(j-i)),b);

function var int: elementos_en_bodega(int: bodega) = 
  m[bodega] + sum(x in 1..n where x!=bodega)(mov[x,bodega] - mov[bodega,x]);

constraint a >= 1 /\ b >= 1 /\ n >= 2 /\ M >= 0;
constraint sum(i in 1..n)(m[i]) = M;
constraint sum(i in 1..n)(o[i]) = M;

constraint forall(i in 1..n)(mov[i,i] = 0);

%Restriccion redundante
%constraint sum(i in 1..n)(elementos_en_bodega(i)) = M;

%asegura que lo que estoy sacando de una bodega sea menor o igual a lo que habia inicialmente, sumandole y restandole lo que ya he metido o sacado de la misma.
constraint forall(i,j in 1..n where i!=j)(
  mov[i,j] <= elementos_en_bodega(i) 
);

%asegura que cada bodega contenga exactamente los elementos que se indican en la distribucion final 'o'
constraint forall(i in 1..n)(
   elementos_en_bodega(i) = o[i]
);

%rompe simetrias, una vez se pasa material de la bodega i a la bodega j, no puede devolverse nada de la bodega j a la bodega i. No tendría sentido 
constraint forall(i,j in 1..n where i!=j)(
  mov[i,j] > 0 -> mov[j,i] = 0
);

var int: costo;

constraint costo = sum(i,j in 1..n where i != j)(calcular_costo(mov[i,j],i,j));

%solve satisfy;

%solve minimize costo;

solve :: int_search(mov, dom_w_deg, indomain_min) minimize costo;

output [if fix(mov[i,j] != 0) 
  then "mov[\(i),\(j)] = " ++ show(mov[i,j]) ++ "\n" 
  else "" 
  endif | i,j in 1..n];

output ["\nCosto = " ++ show(costo)];