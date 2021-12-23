function tabla = cell2latex(cellImprimir,varargin)

% Default values

% Requires:
% \usepackage{booktabs} : básico de tablas
% \usepackage[flushleft]{threeparttable} : agregar notes
% \usepackage{adjustbox} : pa auto-size
%
% Para agregar mathmode, agregar entre $ $  (Si una fila tiene dos signos y
% no para mathmode, va a tirar lo q está entremedio)

%{
cellImprimir=mat2cellstr(matTable)
opts=struct;
opts.title='';
opts.label='';
opts.header={};
opts.primeraColumna={};
% opts.footnote='';
% opts.panel={0,''};
% opts.withAdjust=true;
% opts.addColumnNumber=true;
% opts.columnasFantasma=[];
% opts.filasFantasma=[];
% opts.alignmentFirstCol={'L{3cm}'};
% 
% opts.standardErrors={};
% opts.stars=getStars(estimate,se);
% opts.alignmentfirstcol='L{3cm}'

opts.file='';

cell2latex(cellImprimir,'opts',opts)

%}
withHeader=false;
withTopAndBottom=true;
incluirPValsNote=false;
agregarColumnasFantasma=false;
agregarFilasFantasma=false;
conPrimeraColumna=false;
conFootnote=false;
footNoteType='float'; % float: \floatfoot{\scriptsize ...} or tablenotes: \begin{tablenotes} .. \item .. \end{tablenotes} (la primera es ancho de página y la segunda es ancho de tabla)
sizeFootnoteFloat='\footnotesize'; %\footnotesize or \scriptsize
conStandardErrors=false;
mergeHeader=true;
withAdjust=false;
verticalAdjustParam=2;
addColumnNumber=false;
withPanel=false;
boldPanelHeader=false;
hlineBeforePanel=false;
skipRowBeforePanel=true;
withStars=false;
alignmentFirstCol={''}; %'l c r @{}l C{3cm} R{3cm} L{3cm} '
alignment=nan;
includeExternalRelativePath=false;
externalRelativePath='';
positionParameter='htbp'; % h! or H for right here!

fixTitleCase=false;

titulo='';
label='';
headerStr='\\';
anchoPrimeraColumna=0;
starPValsNote='';
footnoteText='';
export=false;

assert(iscellstr(cellImprimir),'First input must be a cell string') %#ok<ISCLSTR>
% assert(iscellstr(cellImprimir)||all(cellfun(@(x)ischar(x)|isstring(x),cellImprimir),"all"),'First input must be a cell string') %#ok<ISCLSTR>


if(~isempty(varargin))
        % This checks a few things, also if there is struct called "opts"
    varargin=checkVarargin(varargin);
    % Loading optional arguments
    while ~isempty(varargin)
        switch lower(varargin{1})
            case {'titulo','title'}
                titulo = varargin{2};
            case 'label'
                label = varargin{2};
            case 'header'
                % Ancho puede ser igual a ancho de cellImprimir, o ancho de
                % cellImprimir más ancho de primeraColumna
                withHeader=true;
                header = varargin{2};
                assert(iscellstr(header)||all(isstring(header),'all'));
            case {'footnote','note'}
                footnote = varargin{2};
                if(ischar(footnote))
                    footnote={footnote};
                end
                conFootnote=true;
                assert(iscellstr(footnote)||all(isstring(footnote),'all'));
            case {'footnotetype'}
                footNoteType=varargin{2};
            case 'contopybottom'
                withTopAndBottom=varargin{2};
            case {'incluirpvals','incluirpvalsnote'}
                incluirPValsNote=varargin{2};
            case {'columnasfantasma','columnafantasma'}
                % Agrega una columna después de la columna escogida ("0" si es
                % antes de la columna 1). No considera la "primeraColumna"
                agregarColumnasFantasma=true;
                columnasFantasma=varargin{2};
            case {'filasfantasma','filafantasma'}
                % Agrega una fila después de la fila escogida ("0" si es
                % antes de la fila 1).
                agregarFilasFantasma=true;
                filasFantasma=varargin{2};
            case {'primeracolumna','firstcolumn'}
                conPrimeraColumna=true;
                primeraColumna=varargin{2};
                assert(iscellstr(primeraColumna)||all(isstring(primeraColumna),'all'));
            case {'alignmentfirstcol'}
                alignmentFirstCol=varargin{2};
                if(ischar(alignmentFirstCol))
                    alignmentFirstCol={alignmentFirstCol};
                end
            case {'alignment'}
                alignment=varargin{2};
                assert(iscellstr(alignment)||all(isstring(alignment),'all'))
            case {'verticaladjustparam'}
                verticalAdjustParam=varargin{2};
                assert(isnumeric(alignment))
            case {'withadjust','adjust'}
                withAdjust=varargin{2};
            case {'standarderrors','stderrs','stderr','ses'}
                conStandardErrors=true;
                standardErrors=varargin{2};
            case {'stars'}
                withStars=true;
                stars=varargin{2};
            case {'mergeheaders','mergeheader'}
                mergeHeader=varargin{2};
            case {'file','filename'}
                export=true;
                file=varargin{2};
            case {'addcolumnnumbers','addcolumnnumber','addnumber','addnumbers'}
                addColumnNumber=varargin{2};
            case {'panel'}
                % Es un cell de (x,2), donde x es la cantidad de paneles.
                % Primera columna es la posición, segunda el text header del panel.
                % ("0" si es antes de la fila 1)
                panel=varargin{2};
                if(size(panel,1)>0)
                withPanel=true;
                assert(size(panel,2)==2)
                cantPaneles=size(panel,1);
                end
            case {'boldpanelheader'}
                boldPanelHeader=varargin{2};
            case {'positionparameter'}
                positionParameter=varargin{2};
                assert(ischar(positionParameter))

            case {'hlinebeforepanel','linebeforepanel'}
                hlineBeforePanel=varargin{2};
            case {'skiprowbeforepanel'}
                skipRowBeforePanel=varargin{2};
            case {'externalrelativepath','erp'}
                externalRelativePath=varargin{2};
                if(~isempty(externalRelativePath))
                    includeExternalRelativePath=true;
                end
            otherwise
                error(['Unexpected option: ',varargin{1}])
                
        end
        varargin(1:2) = [];
    end
end

assert(not(contains(label,'_')),'Labels of latex tables cannot contain "_"')

% Busca $ $ en cada cell por si hay que reemplazarlo por math environment
anyMath=false;

mathCell={'',''}; % left is the alias for the math, right is the math
counterMath=0;

for c=1:4
    switch c
        case 1
            cellst=cellImprimir;
        case 2
            if(withHeader)
                if(iscategorical(withHeader))
                    withHeader=cellstr(withHeader);
                end
                cellst=header;
            else
                cellst={''};
                continue
            end
        case 3
            if(conPrimeraColumna)
                if(iscategorical(primeraColumna))
                    primeraColumna=cellstr(primeraColumna);
                end
                cellst=primeraColumna;
            else
                cellst={''};
                continue
            end
        case 4
            if(conFootnote)
                cellst=footnote;
            else
                cellst={''};
                continue
            end
    end
    
    withPotentialMath=contains(cellst,'$');
    anyMath=anyMath||any(withPotentialMath,'all');
    
    if(any(withPotentialMath,'all'))
        
        posMath=find(withPotentialMath);
        
        for m=1:length(posMath)
            cellWithMath=cellst{posMath(m)};
            math=unique(extractBetween(cellWithMath,'$','$'));
            if(not(isempty(math)))
                for i=1:length(math)
                    % Busca si ya existe en el arreglo
                    [is,pos]=ismember(['$',math{i},'$'],mathCell(:,2));
                    if(is)
                        cellWithMath=replace(cellWithMath,mathCell{pos,2},mathCell{pos,1});
                    else
                        % Si no exite lo agrega
                        counterMath=counterMath+1;
                        mathCell{counterMath,1}=sprintf('..math%i..',counterMath);
                        mathCell{counterMath,2}=['$',math{i},'$'];
                        cellWithMath=replace(cellWithMath,mathCell{counterMath,2},mathCell{counterMath,1});
                    end
                end
                cellst{posMath(m)}=cellWithMath;
            end
        end
        
        switch c
            case 1
                cellImprimir=cellst;
            case 2
                header=cellst;
            case 3
                primeraColumna=cellst;
            case 4
                footnote=cellst;
        end
    end
end



if(conPrimeraColumna)
    anchoPrimeraColumna=size(primeraColumna,2);
end

% Si viene con header y primera columna, chequea q tipo de info trae el
% header
if(withHeader&&conPrimeraColumna)
    
    if(size(header,2)==(size(cellImprimir,2)+anchoPrimeraColumna))
        assert(not(size(primeraColumna,1)==(size(cellImprimir,1)+size(header,1))),'El header de 1ra columna viene o en header o en primera columna, pero no ambas')
        conHeaderPrimeraColumna=true;
        headerPrimeraColumna=header(:,1:anchoPrimeraColumna);
        header=header(:,size(primeraColumna,2)+1:end);
    elseif(size(primeraColumna,1)==(size(cellImprimir,1)+size(header,1)))
        conHeaderPrimeraColumna=true;
        headerPrimeraColumna=primeraColumna(1:size(header,1),:);
        primeraColumna=primeraColumna(size(header,1)+1:end,:);
    elseif(size(cellImprimir,2)==size(header,2))
        conHeaderPrimeraColumna=false;
    else
        error('Ancho del header tiene que ser igual al array o array más primeraColumna')
    end
    
    
else
    conHeaderPrimeraColumna=false;
end

if(conPrimeraColumna)
    if(isempty(alignmentFirstCol{1}))
        alignmentFirstCol=repmat({'l'},1,size(primeraColumna,2));
    else
        assert(all(size(alignmentFirstCol)==[1,size(primeraColumna,2)]))
    end
end

if(isnumeric(alignment))
    alignment=repmat({'r'},1,size(cellImprimir,2));
else
    assert(all(size(alignment)==[1,size(cellImprimir,2)]))
end



% Agrega numeros al header:
if(addColumnNumber)
    headerNumbers=mat2cellstr(1:size(cellImprimir,2),'withParentheses',true);
    if(withHeader)
        header=[headerNumbers;header];
        if(conHeaderPrimeraColumna)
            headerPrimeraColumna=[repmat({''},1,anchoPrimeraColumna);headerPrimeraColumna];
        end
    else
        withHeader=true;
        header=headerNumbers;
    end
    
end

% Agrega standard errors
if(conStandardErrors)
    assert(all(size(standardErrors)==size(cellImprimir)),'Size of standard errors cellMatrix must be the same as mail cellMatrix')
    
    
    % Cambia a "fantasma" si una fila viene sin nada
    filaVacia=find(all(ismissing(standardErrors),2))*2;
    
    newCell=cell(size(cellImprimir).*[2,1]);
    newCell(1:2:end,:)=cellImprimir;
    newCell(2:2:end,:)=standardErrors;
    cellImprimir=newCell;
    if(conPrimeraColumna)
        newCell=cell(size(primeraColumna).*[2,1]);
        newCell(1:2:end,:)=primeraColumna;
        primeraColumna=newCell;
        
        primeraColumna(filaVacia,1)={'..comment..'};
    else
        primeraColumna(filaVacia,1)={'..comment..'};
    end
    
    if(withStars)
        newCell=repmat({''},size(stars).*[2,1]);
        newCell(1:2:end,:)=stars;
        stars=newCell;
    end
    
    % Arreglo posiciones que dependen en el numero de fila
    
    if(withPanel)
        for i=1:cantPaneles
            panel{i,1}=panel{i,1}*2;
        end
    end
    if(agregarFilasFantasma)
        filasFantasma=2*filasFantasma;
    end
end

% Veo donde voy a poner underline antes de (potencialmente) poner
% estrellas:
if(withHeader)
    [I,J]=size(header);
    withUnderline=false(I,J);
    underlineNum=nan(I,J);
    counter=0;
    igualAnt=false;
    for i=1:I
        for j=1:(J-1)
            igual=strcmp(header{i,j},header{i,j+1})&&not(strcmp(header{i,j},' '))&&not(strcmp(header{i,j},''));
            if(igual&&mergeHeader)
                withUnderline(i,j)=true;
                withUnderline(i,j+1)=true;
                if(not(igualAnt))
                    counter=counter+1;
                end
                underlineNum(i,j)=counter;
                underlineNum(i,j+1)=counter;
            end
            
            igualAnt=igual;
        end
        igualAnt=false;
    end
end


% Agrega estrellas
if(withStars)
    assert(all(size(stars)==size(cellImprimir)))
    incluirPValsNote=true;
    
    
    newCell=cell(size(cellImprimir).*[1,2]);
    newCell(:,1:2:end)=cellImprimir;
    newCell(:,2:2:end)=stars;
    cellImprimir=newCell;
    
    newCell=cell(size(alignment).*[1,2]);
    newCell(:,1:2:end)=alignment;
    newCell(:,2:2:end)={'@{}l'};
    alignment=newCell;
    
    if(withHeader)
        newCell=cell(size(header).*[1,2]);
        newCell(:,1:2:end)=header;
        newCell(:,2:2:end)=header;
        header=newCell;
        
        newArray=false(size(withUnderline).*[1,2]);
        newArray(:,1:2:end)=withUnderline;
        newArray(:,2:2:end)=withUnderline;
        withUnderline=newArray;
        
        newArray=nan(size(underlineNum).*[1,2]);
        newArray(:,1:2:end)=underlineNum;
        newArray(:,2:2:end)=underlineNum;
        underlineNum=newArray;
        

    end
    
    % Arreglo posiciones que dependen en el numero de columna
    
    if(agregarColumnasFantasma)
        columnasFantasma=2*columnasFantasma;
    end
end


% Arregla columnas fantasma:
if(agregarColumnasFantasma)
    assert(all(columnasFantasma>=0&columnasFantasma<=size(cellImprimir,2)),'Can''t add a ghost column after a column that doesn''t exist!! ')
    cantNuevas=length(columnasFantasma);
    
    % Veo si la nueva columna quiebra algún underline
    if(withHeader)
        [I,J]=size(header);
        for i=1:I
            for c=1:cantNuevas
                posF=columnasFantasma(c);
                if(withStars)
                    
                    if(posF>=2&&posF<=J-2)
                        if(all(withUnderline(i,posF-1:posF+2)))
                            %izq:
                            if(posF==2||sum(underlineNum(i,1:posF)==underlineNum(i,posF))<=2||ismember(posF-2,columnasFantasma))
                                withUnderline(i,posF-1:posF)=false;
                            end
                            %der:
                            if(posF==J-2||sum(underlineNum(i,posF+1:end)==underlineNum(i,posF+1))<=2||ismember(posF+2,columnasFantasma))
                                withUnderline(i,posF+1:posF+2)=false;
                            end
                        end
                        
                    end
                    % Si queda solo uno, lo sacamos:
                    if(posF<J&&sum(underlineNum(i,withUnderline(i,:))==underlineNum(i,posF+1))<=2)
                        withUnderline(i,underlineNum(i,:)==underlineNum(i,posF+1))=false;
                    end
                    if(posF>0&&sum(underlineNum(i,withUnderline(i,:))==underlineNum(i,posF))<=2)
                        withUnderline(i,underlineNum(i,:)==underlineNum(i,posF))=false;
                    end
                else
                    if(posF>=1&&posF<=J-1)
                        if(all(withUnderline(i,posF:posF+1)))
                            if(posF==1||sum(underlineNum(i,1:posF)==underlineNum(i,posF))<=1||ismember(posF-1,columnasFantasma))
                                withUnderline(i,posF)=false;
                            end
                            if(posF==J-1||sum(underlineNum(i,posF+1:end)==underlineNum(i,posF+1))<=1||ismember(posF+1,columnasFantasma))
                                withUnderline(i,posF+1)=false;
                            end
                        end
                    end
                      % Si queda solo uno, lo sacamos:
                    if(posF<J&&sum(underlineNum(i,withUnderline(i,:))==underlineNum(i,posF+1))<=1)
                        withUnderline(i,underlineNum(i,:)==underlineNum(i,posF+1))=false;
                    end
                    if(posF>0&&sum(underlineNum(i,withUnderline(i,:))==underlineNum(i,posF))<=1)
                        withUnderline(i,underlineNum(i,:)==underlineNum(i,posF))=false;
                    end
                end
            end
        end
    end
    
    newCell=repmat({' '},(size(cellImprimir)+[0,cantNuevas]));
    newAllignment=repmat({'r'},(size(alignment)+[0,cantNuevas]));
    if(withHeader)
        newHeader=repmat({' '},(size(header)+[0,cantNuevas]));
        newWithUnderline=false(size(withUnderline)+[0,cantNuevas]);
    end
    posOrig=1;
    posNew=1;
    for i=1:(cantNuevas+1)
        if(i<=length(columnasFantasma))
            newEnd=columnasFantasma(i)-posOrig+posNew;
            newCell(:,posNew:newEnd)=cellImprimir(:,posOrig:columnasFantasma(i));
            newAllignment(:,posNew:newEnd)=alignment(:,posOrig:columnasFantasma(i));
            if(withHeader)
                newHeader(:,posNew:newEnd)=header(:,posOrig:columnasFantasma(i));
                newWithUnderline(:,posNew:newEnd)=withUnderline(:,posOrig:columnasFantasma(i));
            end
            posNew=columnasFantasma(i)+i+1;
            posOrig=columnasFantasma(i)+1;
        else
            newCell(:,posNew:end)=cellImprimir(:,posOrig:end);
            newAllignment(:,posNew:end)=alignment(:,posOrig:end);
            if(withHeader)
                newHeader(:,posNew:end)=header(:,posOrig:end);
                newWithUnderline(:,posNew:end)=withUnderline(:,posOrig:end);
            end
        end
    end
    cellImprimir=newCell;
    alignment=newAllignment;
    if(withHeader)
        header=newHeader;
        withUnderline=newWithUnderline;
    end
    

    
end

% Agrega la 1ra columna
if(conPrimeraColumna)
    assert(size(primeraColumna,1)==size(cellImprimir,1),'Left column need to be the height of the data!');
    if(withHeader)
        if(conHeaderPrimeraColumna)
            header=[headerPrimeraColumna,header];
            
        else
            header=[repmat({' '},size(header,1),anchoPrimeraColumna),header];
            
        end
    end
    
    cellImprimir=[primeraColumna,cellImprimir];
    withUnderline=[false(size(withUnderline,1),anchoPrimeraColumna),withUnderline];
end

% Arregla filas fantasma:
if(agregarFilasFantasma)
    assert(all(filasFantasma>=0&filasFantasma<=size(cellImprimir,1)),'Can''t add a ghost row after a row that doesn''t exist!! ')
    cantNuevas=length(filasFantasma);
    newCell=repmat({' '},(size(cellImprimir)+[cantNuevas,0]));
    
    posOrig=1;
    posNew=1;
    for i=1:(cantNuevas+1)
        if(i<=length(filasFantasma))
            newEnd=filasFantasma(i)-posOrig+posNew;
            newCell(posNew:newEnd,:)=cellImprimir(posOrig:filasFantasma(i),:);
            
            posNew=filasFantasma(i)+i+1;
            posOrig=filasFantasma(i)+1;
        else
            newCell(posNew:end,:)=cellImprimir(posOrig:end,:);
        end
    end
    cellImprimir=newCell;
    if(withPanel)
        for i=1:cantPaneles
            panel{i,1}=panel{i,1}+sum(filasFantasma<=panel{i,1});
        end
    end
end

% Arregla el header si va pa multicolumn;
if(withHeader)
    [I,J]=size(header);
    headerStr='';
    for i=1:I
        counterIgual=1;
        counterColumn=0;
        counterPrint=1;
        headerStrAux='';
        cline='';
        for j=1:J-1
            counterColumn=counterColumn+1;
            igual=strcmp(header{i,j},header{i,j+1})&&not(strcmp(header{i,j},' '))&&not(strcmp(header{i,j},''));
            if(igual&&mergeHeader)
                counterIgual=counterIgual+1;
            elseif(counterIgual>1&&not(igual))
                if(counterPrint==1)
                    counterPrint=counterPrint+1;
                    headerStrAux=horzcat('\multicolumn{',sprintf('%i',counterIgual),'}{c}{',header{i,j},'}');
                else
                    headerStrAux=horzcat(headerStrAux,'&\multicolumn{',sprintf('%i',counterIgual),'}{c}{',header{i,j},'}');
                end
                counterIgual=1;
            else
                if(counterPrint==1)
                    counterPrint=counterPrint+1;
                    headerStrAux=header{i,j};
                else
                    if(j<=anchoPrimeraColumna)
                        headerStrAux=horzcat(headerStrAux,' &\multicolumn{1}{l}{',header{i,j},'}');
                    else
                        headerStrAux=horzcat(headerStrAux,' &\multicolumn{1}{c}{',header{i,j},'}');
                    end
                end
            end
        end
        if(counterIgual>1)
            if(counterPrint==1)

                headerStrAux=horzcat('\multicolumn{',sprintf('%i',counterIgual),'}{c}{',header{i,j+1},'}');

            else
                headerStrAux=horzcat(headerStrAux,'&\multicolumn{',sprintf('%i',counterIgual),'}{c}{',header{i,j+1},'}');
            end
        else
            if(counterPrint==1)
                headerStrAux=header{i,j+1};
            else
                headerStrAux=horzcat(headerStrAux,' &\multicolumn{1}{c}{',header{i,j+1},'}');
            end
        end
        % Add underline
        cline='';
        underlining=false;
        for j=1:J
            if(withUnderline(i,j)&&not(underlining))
                cline=[cline,'\cline',sprintf('{%i-',j)];
                underlining=true;
            end
            if(not(withUnderline(i,j))&&underlining)
                cline=[cline,sprintf('%i}',j-1)];
                underlining=false;
            end
            if(j==J&&underlining)
                cline=[cline,sprintf('%i}',j)];
                underlining=false;
            end
        end
        if(i==I&&strcmp(cline,''));cline='\midrule';end
        
        headerStr=[headerStr,headerStrAux,'\\',cline,newline];
    end
end
% Esto pone lineas pero no sé si lo quiero mantner
if(false)
    
    cellLinea=cell(1,size(cellImprimir,2));
    cellLinea(1,2:end)=repmat({''},1,size(cellImprimir,2)-1);
    cellLinea{1,1}='\midrule %%';
    
    if(isnumeric(lineasCada))
        
        linea=(lineasCada+1):(lineasCada+1):(size(cellImprimir,1)+floor(size(cellImprimir,1)/lineasCada)-1);
        
    else
        
        vaLinea=false(size(cellImprimir,1)-1,1);
        for i=1:size(cellImprimir,1)-1
            if(not(isempty(cellImprimir{i+1,1})||ismember(cellImprimir{i+1,1},{'',' ','  '})))
                vaLinea(i)=true;
            end
        end
        linea=find(vaLinea)+(1:sum(vaLinea))';
    end
    nuevasFilas=1:(size(cellImprimir,1)+length(linea));
    posInfo=nuevasFilas(not(ismember(nuevasFilas,linea)));
    cellImprimirNueva=cell(size(cellImprimir)+[length(linea) 0]);
    cellImprimirNueva(posInfo,:)=cellImprimir;
    
    cellImprimirNueva(linea,:)=repmat(cellLinea,length(linea),1);
    cellImprimir=cellImprimirNueva;
end

numColumnas=size(cellImprimir,2);

% Keep for future sprintf
string=horzcat('%s ',repmat(' & %s',1,numColumnas-1),' \\\\ \n');


if(withPanel)
    preTabla='';
    posIni=1;
    if(skipRowBeforePanel)
        skip=['\\',newline];
    else
        skip='';
    end
    if(hlineBeforePanel)
        skip=[skip,'\hline'];
    end
    if(boldPanelHeader)
        bold='\textbf';
    else
        bold='';
    end
    for c=1:cantPaneles
        posPanel=panel{c,1};
        headerPanel=panel{c,2};
        assert(all(posPanel>=0&posPanel<=size(cellImprimir,1)),'Can''t add a panel row after a row that doesn''t exist!! ')
        
        newRow=horzcat(skip,'\multicolumn{',sprintf('%i',size(cellImprimir,2)),'}{l}{',bold,'{',headerPanel,'}} \\',newline);
        
        auxImprimir=cellImprimir(posIni:posPanel,:)';
        preTabla=[preTabla,sprintf(string,auxImprimir{:,:}),newRow]; %#ok<AGROW>
        posIni=posPanel+1;
    end
    auxImprimir=cellImprimir(posIni:end,:)';
    preTabla=[preTabla,sprintf(string,auxImprimir{:,:}),];
else
    imprimir=cellImprimir';
    preTabla=sprintf(string,imprimir{:,:});
end

if(strcmp(footNoteType,'tablenotes'))
newlineFootnote=newline;
        environmentTableNotesTop='\begin{threeparttable}';
        environmentTableNotesBottom='\end{threeparttable}';
else
newlineFootnote='';
        environmentTableNotesTop='';
        environmentTableNotesBottom='';
end

preFootnote='..comment..';
if(incluirPValsNote||conFootnote)
    
    if(conFootnote)

            preFootnote='';
        if(not(incluirPValsNote))
            footnote{1}=['\textit{Notes. }',footnote{1}];
        end
        if(strcmp(footNoteType,'tablenotes'))
        footnote=sprintf('\\item %s\n', footnote{:});
        else
    footnote=sprintf('%s\n', footnote{:});
        end
        
    else
        footnote='';
    end
    if(incluirPValsNote)
        starPValsNote= '\item \textit{Notes. }*** p<0.01, ** p<0.05, * p<0.1.';
    end

    environmentTableNotesTop='';
    environmentTableNotesBottom='';
    if(strcmp(footNoteType,'float')) % float: \floatfoot{\scriptsize ...})

        
        footnoteText=horzcat('\floatfoot{',sizeFootnoteFloat ,newline,...
            starPValsNote,...
            footnote,...
            '}',newline);

    elseif(strcmp(footNoteType,'tablenotes'))
        footnoteText=horzcat('\begin{tablenotes}',newline,...
            '\small',newline,...
            starPValsNote,...
            footnote,...
            '\end{tablenotes}',newline);



    else

    end
end
intro=sprintf('\n..comment.. Table generated with cell2latex.m  on  %s\n',datestr(now));
if(withTopAndBottom)
    


    
    if(withAdjust)
        topAdj=horzcat('\begin{adjustbox}{max width=\textwidth,max totalheight=\textheight-',sprintf('%i',verticalAdjustParam),'\baselineskip}');
        botAdj='\end{adjustbox}';
    else
        topAdj=horzcat('..comment..\begin{adjustbox}{max width=\textwidth,max totalheight=\textheight-',sprintf('%i',verticalAdjustParam),'\baselineskip}');
        botAdj='..comment..\end{adjustbox}';
    end
    
        
    if(not(isempty(label))||not(isempty(titulo))||true)% Apparently is mandatory
        if(fixTitleCase&&not(isempty(titulo)))
            apiKey='';
            titulo=char(pyrunfile(sprintf("titleCaseConverter.py '%s' '%s'",titulo,apiKey),'r'));
       end
        tit=['\caption{',titulo,'\label{',label,'}}',newline];
       
    else
        tit=['..comment..\caption{  \label{  }}',newline];
    end
    
    top=horzcat(newline,'\begin{table}..',positionParameter,'..',newline,...
        '\centering',newline,...
        tit,...
        topAdj,newline,...
        preFootnote,environmentTableNotesTop,newlineFootnote,...
        '..comment..\footnotesize',newline,...
        '\begin{tabular}{',sprintf('%s',alignmentFirstCol{:}),sprintf('%s',alignment{:}),'}',newline,...
        '\addlinespace',newline,...
        '\toprule',newline);%,...);widthPrimeraCol
    %repmat('&',1,numColumnas-1),'\\\\ \n',...
    %'\\midrule \n');
    
    bottom=horzcat('\bottomrule',newline,...
        '..comment..\addlinespace',newline,...
        '\end{tabular}',newline,...
        footnoteText,...
        preFootnote,environmentTableNotesBottom,newlineFootnote,...
        botAdj,newline,...
        '\end{table}',newline);
    
    %         '\\label{',label,'} \n',...
    
    if(withHeader)
    tabla=horzcat(intro,top,headerStr,newline,preTabla,bottom);
    else
tabla=horzcat(intro,top,preTabla,bottom);
    end
else
    tabla=horzcat(intro,headerStr,newline,preTabla);
end

%% Special characters

% First column is the in, second is the out:
matSpecial={...
    '$','\$';...
    '[','$[$';...
    ']','$]$';...
    '%','\%';...
    '>=','$\geq$';...
    '<=','$\leq$';...
    '<','$<$';...
    '>','$>$';...
    '_','\_';...
    '|','$|$';...
    '..comment..','%';...
    ['..',positionParameter,'..'],['[',positionParameter,']']};

for i=1:size(matSpecial,1)
    tabla=strrep(tabla,matSpecial{i,1},matSpecial{i,2});
end
if(anyMath)
    for i=1:size(mathCell,1)
        tabla=strrep(tabla,mathCell{i,1},mathCell{i,2});
    end
end

if(false)
    %% Test special
    clc
    a=sprintf('Hola \n Qué tal\n Yo bienP.P, tu%%??\n');
    disp(a)
    matSpecial={'[','$[$';...
        ']','$]$';...
        '%','\%';...
        '>=','$\geq$';...
        '<=','$\leq$';...
        '<','$<$';...
        '>','$>$';...
        '_','\_';...
        '..comment..','%'};
    
    for i=1:size(matSpecial,1)
        a=strrep(tabla,matSpecial{i,1},matSpecial{i,2});
    end
    disp(a)
end
%%

if(nargout==0)
    display(tabla);
end

if(export)
    if(~contains(file,'.tex'));file=[file,'.tex'];end
    
    % Add check if folder exist
    pos=strfind(file,'/');
    
    if(~isempty(pos))
        assert(isfolder(file(1:pos(end))),sprintf('Dir %s apparently does not exist',file(1:pos(end))))
    end
    
    
    fid = fopen(file,'wt');
    fprintf(fid, '%s', tabla);
    fclose(fid);
    
    % Imprime el codigo pa meter al tex:
    
    posTex=strfind(file,'.tex');
    if(~isempty(posTex));file=file(1:posTex(end)-1);end % Texpad alega si tiene .tex!
    
    % Busca el relative path
    
    if(~isempty(pos))
        file1=file(pos(end)+1:end);
        fprintf('\\include{%s}\n\n',file1);
        
        newPos=pos(pos<(pos(end)-1)); % Ve si hay otro "/" (q no está pegado al anterior)
        if(~isempty(newPos))
            file2=file(newPos(end)+1:end);
            fprintf('\\include{%s}\n\n',file2);
        end
        
        if(includeExternalRelativePath)
            if(not(endsWith(externalRelativePath,'/')))
                externalRelativePath= sprintf('%s/',externalRelativePath);
            end
            fprintf('\\include{%s}\n\n',[externalRelativePath,file1]);
        end
        
    else
         if(includeExternalRelativePath)
            if(not(endsWith(externalRelativePath,'/')))
                externalRelativePath= sprintf('%s/',externalRelativePath);
            end
            fprintf('\\include{%s}\n\n',[externalRelativePath,file]);
        end
    end
    
            
end

end

