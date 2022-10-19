function out=normalizeEs(in)
% Intenta normalizar texto:
% -Saca acentos
% -Pasa a lower case

in=lower(in);


raros={'á','é','í','ó','ú','ñ'};
rarosRep={'a','e','i','o','u','n'};

out=replace(in,raros,rarosRep);