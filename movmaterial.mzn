include "globals.mzn";

int: n; %numero de bodegas; almacena material que se mide en unidades
int: M; %unidades de material; distribuidos en las n bodegas

int: a;
int: b;
  
array[1..n] of 0..M: m; %distribucion inicial
array[1..n] of 0..M: o; %distribucion final

array[1..n, 1..n] of var 0..M: mov;

array[1..n] of var 0..M: final_material;

constraint a >= 1 /\ b >= 1;
constraint sum(i in 1..n)(m[i]) = M;
constraint sum(i in 1..n)(o[i]) = M;

function var int: calcular_costo(var int: e, int: i, int: j) = pow(e,a) * pow((abs(j-i)),b);

function var int: elementos_en_bodega(int: bodega) = 
  m[bodega] + sum(x in 1..n)(mov[x,bodega] - mov[bodega,x]);

constraint forall(i in 1..n)(mov[i,i] = 0);

%asegura que lo que estoy sacando de una bodega sea menor o igual a lo que habia inicialmente, sumandole y restandole lo que ya he metido o sacado de la misma.
constraint forall(i,j in 1..n)(
  mov[i,j] <= elementos_en_bodega(i)
);

%m=[10,10,5];
%o=[5,10,10];

constraint forall(i in 1..n)(
   elementos_en_bodega(i) = o[i]
);

var int: costo;

constraint costo = sum(i,j in 1..n where i != j)(calcular_costo(mov[i,j],i,j));

%solve satisfy;

solve minimize costo;

output [if fix(mov[i,j] != 0) 
  then "mov[\(i),\(j)] = " ++ show(mov[i,j]) ++ "\n" 
  else "" 
  endif | i,j in 1..n];

output ["\nCosto = " ++ show(costo)];