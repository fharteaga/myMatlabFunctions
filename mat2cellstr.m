function cellNueva=mat2cellstr(mat,varargin)

%% Options:
% revisarColumnas : revisa columnas para decidir precision
% precision: precision de los numeros
% precisionEntero: precision de enteros if revisarColumnas=true
% precisionDecimal: precision de decimales if revisarColumnas=true
% conParentesis:
% withThousandsSeparator: agrega comma pa separar miles
% prefijo
% sufijo
% returnChar or rc: devuelve char

% Default values
conParentesis=false;
estaPrecision=false;
precisionDecimal='%.2f';
precisionEntero='%i';
revisarCol=false;
revisarFil=false;
sufijo='';
prefijo='';
parIni='';
parEnd='';
withThousandsSeparator=true;
thousandsSeparator=',';
returnChar=false;
nanReplacement='';
spanish=false;% True changes commas for dots, and dots for commas;

if(~isempty(varargin))
    
  varargin=checkVarargin(varargin);
% Loading optional arguments
while ~isempty(varargin)
    switch lower(varargin{1})
        case {'revisarcolumnas','revisarcols','checkcolumns','cc'}
            revisarCol = varargin{2};
        case {'revisarfilas','revisarfils','checkrows','cr'}
            revisarFil = varargin{2};
        case 'precision'
            estaPrecision=true;
            precision=varargin{2};
        case {'precisionentero','integerprecision','ip'}
            precisionEntero=varargin{2};
        case {'precisiondecimal','decimalprecision','dp'}
            precisionDecimal=varargin{2};
        case 'sufijo'
            sufijo=varargin{2};
        case 'nanreplacement'
            nanReplacement=varargin{2};
        case 'prefijo'
            prefijo=varargin{2};
        case {'conparentesis','withparenthesis','withparentheses','wp'} % parentheses is the plural of parenthesis
            conParentesis=varargin{2};
        case {'withthousandsseparator','withseparator','ws','wts'}
            withThousandsSeparator=varargin{2};
        case {'returnchar','rc'}
            returnChar=varargin{2};
        case {'spanish','s'}
            spanish=varargin{2};
        otherwise
            error(['Unexpected option: ' varargin{1}])
    end
    varargin(1:2) = [];
end
end

assert(numel(mat)==1||not(returnChar))

assert(not(revisarCol&&revisarFil))
if(revisarFil)
    revisarCol=true;
    mat=mat';
end

if(conParentesis)
    parIni='(';
    parEnd=')';
end

if(estaPrecision&&revisarCol)
    error('Si vay a revisar columnas, no puedes elegir "precision". Sí puedes elegir "precisionEntero" y "precisionDecimal"')
elseif(not(estaPrecision)&&not(revisarCol))
    if(any(any((mat-floor(mat))>0)))
        precision=precisionDecimal;
    else
        precision=precisionEntero;
    end
end

[alto,ancho]=size(mat);
cellNueva=cell(size(mat));

for j=1:ancho
    if(revisarCol)
        if(any((mat(:,j)-floor(mat(:,j)))>0))
            precision=precisionDecimal;
        else
            precision=precisionEntero;
        end
    end
    for i=1:alto
        if(withThousandsSeparator)
            auxNueva=separator(sprintf(precision,mat(i,j)),thousandsSeparator);
            cellNueva{i,j}=[parIni,prefijo,auxNueva,sufijo,parEnd];
        else
            cellNueva{i,j}=sprintf([parIni,prefijo,precision,sufijo,parEnd],mat(i,j));
        end
    end
end

cellNueva(cellfun(@(x) strcmp(x,[parIni,prefijo,'NaN',sufijo,parEnd]),cellNueva))={nanReplacement};


if(spanish)
cellNueva=replace(cellNueva,{',','.'},{'.',','});
end


if(revisarFil)
    cellNueva=cellNueva';
end

if(returnChar)
   cellNueva=cellNueva{1}; 
end


    function S_out=separator(S,thousandsSeparator)
        pos=strfind(S, '.');
        fin=1;
        if(isempty(pos));pos=length(S)+1;end % Si no tiene decimal
        if(S(1)=='-');fin=2;end % Si tiene un signo negativo
        S(2,  pos-4:-3:fin) = thousandsSeparator;
        
        % Esto remplaza la coma por espacio en lugares que no deberia haber
        % coma (evita ' ,   , 12,123.123123')
        S(2,(S(1,:)==char(32)|S(1,:)=='-')&S(2,:)==thousandsSeparator)=char(32);
        darVuelta=S(1,:)=='-'&S(2,:)==char(32);
        S(:,darVuelta)=S([2 1],darVuelta);
        
        S_out = transpose(S(S ~= char(0)));
    end

end