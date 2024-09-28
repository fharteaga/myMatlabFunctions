function tabla = cell2latex(cellToPrint,varargin)

% Default values

% If you compile the .tex, you would need the following extra latex packages:
% \usepackage{booktabs} : basic tables
% \usepackage[flushleft]{threeparttable} : add notes
% \usepackage{adjustbox} : for auto-sizing
%
% If you are including any math formula, it should come between "$"s. The formula itself should not include any "$"

%{
cellToPrint=mat2cellstr(matTable)
opts=struct;
opts.title='';
opts.label='';
opts.header={};
opts.firstColumn={};
% opts.footnote='';
% opts.panel={0,''};
% opts.withAdjust=true;
% opts.addColumnNumber=true;
% opts.spacerColumns=[];
% opts.spacerRows=[];
% opts.alignmentFirstCol={'L{3cm}'};
% 
% opts.standardErrors={};
% opts.stars=getStars(estimate,se);
% opts.alignmentfirstcol='L{3cm}'

opts.file='';

cell2latex(cellToPrint,'opts',opts)

%}

% Optional inputs:
withHeader=false;
withTopAndBottom=true;
includePValsNote=false;
addSpacerColumn=false;
addSpacerRow=false;
withFirstColumn=false;
useCellFirstColumnAsFirstColumn=false;
withFootnote=false;
footNoteType='float'; % float: \floatfoot{\scriptsize ...} or tablenotes: \begin{tablenotes} .. \item .. \end{tablenotes} (first is page-wide, second is table-wide)
sizeFootnoteFloat='\footnotesize'; %\footnotesize or \scriptsize
withStandardErrors=false;
mergeHeader=true;
withAdjust=false;
verticalAdjustParam=2;
addColumnNumber=false;
withPanel=false;
boldPanelHeader=false;
italicPanelHeader=true;
hlineBeforePanel=false;
skipRowBeforePanel=true;
withStars=false;
alignmentFirstCol={''}; %'l c r @{}l C{3cm} R{3cm} L{3cm} '
alignment=nan;
includeExternalRelativePath=false;
externalRelativePath='';
positionParameter='htbp'; % h! or H for right here!
withFontSizeTable=false;
fontSizeTable='\footnotesize';
avoidPvalsNote=false; % Avoid adding stars pvals to footnote if stars al added to the table.



fixTitleCase=false;

title='';
label='';
headerStr='\\';
anchoPrimeraColumna=0;
starPValsNote='';
footnoteText='';
export=false;
printInputLatexCode=true;

assert(iscellstr(cellToPrint),'First input must be a cell string') %#ok<ISCLSTR>
% assert(iscellstr(cellToPrint)||all(cellfun(@(x)ischar(x)|isstring(x),cellToPrint),"all"),'First input must be a cell string') %#ok<ISCLSTR>


if(~isempty(varargin))
    % This checks a few things, also if there is struct called "opts"
    varargin=checkVarargin(varargin);
    % Loading optional arguments
    while ~isempty(varargin)
        switch lower(varargin{1})
            case {'title','titulo'}
                title = varargin{2};
            case 'label'
                label = varargin{2};
            case {'header','headers'} % Width can be equal to the width of cellToPrint, or the width of cellToPrint plus the width of firstColumn
                withHeader=true;
                header = varargin{2};
                assert(iscellstr(header)||all(isstring(header),'all'));
            case {'footnote','note'}
                footnote = varargin{2};
                if(ischar(footnote))
                    footnote={footnote};
                end
                withFootnote=true;
                assert(iscellstr(footnote)||all(isstring(footnote),'all'));
            case {'footnotetype'}
                footNoteType=varargin{2};
            case{'sizefootnotefloat'}
                sizeFootnoteFloat=varargin{2};
            case{'avoidpvalsnote'}
                avoidPvalsNote=varargin{2};
            case 'contopybottom'
                withTopAndBottom=varargin{2};
            case {'incluirpvals','incluirpvalsnote'}
                includePValsNote=varargin{2};
            case {'spacercolumns','columnasfantasma','columnafantasma'}
                % Add a spacer (empty column) after the column number in parameter "spacerColumns" ("0" if it is before column 1)
                % It does not count the firstColumn
                addSpacerColumn=true;
                spacerColumns=varargin{2};
            case {'spacerrows','filasfantasma','filafantasma'}
                % Add a spacer (empty row) after the row number in parameter "spacerColumns" ("0" if is si before row 1)
                addSpacerRow=true;
                spacerRows=varargin{2};
            case {'firstcolumn','primeracolumna'}
                withFirstColumn=true;
                firstColumn=varargin{2};
                assert(iscellstr(firstColumn)||all(isstring(firstColumn),'all'));
            case{'usecellfirstcolumnasfirstcolumn'}
                useCellFirstColumnAsFirstColumn = varargin{2};
            case {'alignmentfirstcol'}
                alignmentFirstCol=varargin{2};
                if(ischar(alignmentFirstCol))
                    alignmentFirstCol={alignmentFirstCol};
                end
            case {'alignment'}
                alignment=varargin{2};
                assert(iscellstr(alignment)||all(isstring(alignment),'all')) % Cannot be just char!
            case {'verticaladjustparam'}
                verticalAdjustParam=varargin{2};
                assert(isnumeric(alignment))
            case {'fontsizetable'}
                fontSizeTable=varargin{2};
                withFontSizeTable=true;
            case {'withadjust','adjust'}
                withAdjust=varargin{2};
            case {'standarderrors','stderrs','stderr','ses'}
                withStandardErrors=true;
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
            case {'panel','panels'}
                % x by 2 cell, where "x" is the number of panels
                % Element of column 1 is the position, of column 2 is the text of the panel.
                % Position reflects "after row x" (ex: "0" if you want the panel to start right before row 1)
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
            case{'printinputlatexcode'}
                printInputLatexCode = varargin{2};

            otherwise
                error(['Unexpected option: ',varargin{1}])

        end
        varargin(1:2) = [];
    end
end

if(useCellFirstColumnAsFirstColumn)
    assert(not(withFirstColumn))
    assert(size(cellToPrint,2)>1)
    firstColumn=cellToPrint(:,1);
    cellToPrint=cellToPrint(:,2:end);
    withFirstColumn=true;
end

assert(not(contains(label,'_')),'Labels of latex tables cannot contain "_"')

% Busca $ $ en cada cell por si hay que reemplazarlo por math environment
anyMath=false;

mathCell={'',''}; % left is the alias for the math, right is the math
counterMath=0;

for c=1:5
    switch c
        case 1
            cellst=cellToPrint;
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
            if(withFirstColumn)
                if(iscategorical(firstColumn))
                    firstColumn=cellstr(firstColumn);
                end
                cellst=firstColumn;
            else
                cellst={''};
                continue
            end
        case 4
            if(withFootnote)
                cellst=footnote;
            else
                cellst={''};
                continue
            end
        case 5
            if(withPanel)
                cellst=panel(:,2);
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
                    % Looks if it's already on the cell
                    [is,pos]=ismember(['$',math{i},'$'],mathCell(:,2));
                    if(is)
                        cellWithMath=replace(cellWithMath,mathCell{pos,2},mathCell{pos,1});
                    else
                        % If not, it is added
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
                cellToPrint=cellst;
            case 2
                header=cellst;
            case 3
                firstColumn=cellst;
            case 4
                footnote=cellst;
            case 5
                panel(:,2)=cellst;

        end
    end
end

if(withFontSizeTable)
    preFontSizeTable='';
else
    preFontSizeTable='..comment..';
end

if(withFirstColumn)
    anchoPrimeraColumna=size(firstColumn,2);
end


if(withHeader&&withFirstColumn)

    if(size(header,2)==(size(cellToPrint,2)+anchoPrimeraColumna))
        assert(not(size(firstColumn,1)==(size(cellToPrint,1)+size(header,1))),'The header of the 1st column must come either in the header or in the first column, but not both')
        conHeaderPrimeraColumna=true;
        headerPrimeraColumna=header(:,1:anchoPrimeraColumna);
        header=header(:,size(firstColumn,2)+1:end);
    elseif(size(firstColumn,1)==(size(cellToPrint,1)+size(header,1)))
        conHeaderPrimeraColumna=true;
        headerPrimeraColumna=firstColumn(1:size(header,1),:);
        firstColumn=firstColumn(size(header,1)+1:end,:);
    elseif(size(cellToPrint,2)==size(header,2))
        conHeaderPrimeraColumna=false;
    else
        error('Header width must be equal to the cellToPrint width or (firstColumn + cellToPrint) width')
    end


else
    conHeaderPrimeraColumna=false;
end

if(withFirstColumn)
    if(isempty(alignmentFirstCol{1}))
        alignmentFirstCol=repmat({'l'},1,size(firstColumn,2));
    else
        assert(all(size(alignmentFirstCol)==[1,size(firstColumn,2)]))
    end
end

if(isnumeric(alignment))
    alignment=repmat({'r'},1,size(cellToPrint,2));
else
    assert(all(size(alignment)==[1,size(cellToPrint,2)]))
end



% Add numbers to header:
if(addColumnNumber)
    headerNumbers=mat2cellstr(1:size(cellToPrint,2),'withParentheses',true);
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

% Add standard errors:
if(withStandardErrors)
    assert(all(size(standardErrors)==size(cellToPrint)),'Size of standard errors matrix must be the same as cellToPrint')


    emptyRow=find(all(ismissing(standardErrors),2))*2;

    newCell=cell(size(cellToPrint).*[2,1]);
    newCell(1:2:end,:)=cellToPrint;
    newCell(2:2:end,:)=standardErrors;
    cellToPrint=newCell;
    if(withFirstColumn)
        newCell=cell(size(firstColumn).*[2,1]);
        newCell(1:2:end,:)=firstColumn;
        firstColumn=newCell;

        firstColumn(emptyRow,1)={'..comment..'};
    else
        firstColumn(emptyRow,1)={'..comment..'};
    end

    if(withStars)
        newCell=repmat({''},size(stars).*[2,1]);
        newCell(1:2:end,:)=stars;
        stars=newCell;
    end


    if(withPanel)
        for i=1:cantPaneles
            panel{i,1}=panel{i,1}*2;
        end
    end
    if(addSpacerRow)
        spacerRows=2*spacerRows;
    end
end

% This creates underline for merged header cells:
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


% Add significance stars
if(withStars)
    assert(all(size(stars)==size(cellToPrint)))
    if(not(avoidPvalsNote))
        includePValsNote=true;
    end

    newCell=cell(size(cellToPrint).*[1,2]);
    newCell(:,1:2:end)=cellToPrint;
    newCell(:,2:2:end)=stars;
    cellToPrint=newCell;

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

    if(addSpacerColumn)
        spacerColumns=2*spacerColumns;
    end
end


% Fix spacer columns
if(addSpacerColumn)
    assert(all(spacerColumns>=0&spacerColumns<=size(cellToPrint,2)),"Can't add a spacer column after a column that doesn't exist!!")
    cantNuevas=length(spacerColumns);

    % Veo si la nueva columna quiebra algún underline
    if(withHeader)
        [I,J]=size(header);
        for i=1:I
            for c=1:cantNuevas
                posF=spacerColumns(c);
                if(withStars)

                    if(posF>=2&&posF<=J-2)
                        if(all(withUnderline(i,posF-1:posF+2)))
                            %left:
                            if(posF==2||sum(underlineNum(i,1:posF)==underlineNum(i,posF))<=2||ismember(posF-2,spacerColumns))
                                withUnderline(i,posF-1:posF)=false;
                            end
                            %right:
                            if(posF==J-2||sum(underlineNum(i,posF+1:end)==underlineNum(i,posF+1))<=2||ismember(posF+2,spacerColumns))
                                withUnderline(i,posF+1:posF+2)=false;
                            end
                        end

                    end
                    % If there is only one, we take it out
                    if(posF<J&&sum(underlineNum(i,withUnderline(i,:))==underlineNum(i,posF+1))<=2)
                        withUnderline(i,underlineNum(i,:)==underlineNum(i,posF+1))=false;
                    end
                    if(posF>0&&sum(underlineNum(i,withUnderline(i,:))==underlineNum(i,posF))<=2)
                        withUnderline(i,underlineNum(i,:)==underlineNum(i,posF))=false;
                    end
                else
                    if(posF>=1&&posF<=J-1)
                        if(all(withUnderline(i,posF:posF+1)))
                            if(posF==1||sum(underlineNum(i,1:posF)==underlineNum(i,posF))<=1||ismember(posF-1,spacerColumns))
                                withUnderline(i,posF)=false;
                            end
                            if(posF==J-1||sum(underlineNum(i,posF+1:end)==underlineNum(i,posF+1))<=1||ismember(posF+1,spacerColumns))
                                withUnderline(i,posF+1)=false;
                            end
                        end
                    end
                    % If there is only one, we take it out
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

    newCell=repmat({' '},(size(cellToPrint)+[0,cantNuevas]));
    newAllignment=repmat({'r'},(size(alignment)+[0,cantNuevas]));
    if(withHeader)
        newHeader=repmat({' '},(size(header)+[0,cantNuevas]));
        newWithUnderline=false(size(withUnderline)+[0,cantNuevas]);
    end
    posOrig=1;
    posNew=1;
    for i=1:(cantNuevas+1)
        if(i<=length(spacerColumns))
            newEnd=spacerColumns(i)-posOrig+posNew;
            newCell(:,posNew:newEnd)=cellToPrint(:,posOrig:spacerColumns(i));
            newAllignment(:,posNew:newEnd)=alignment(:,posOrig:spacerColumns(i));
            if(withHeader)
                newHeader(:,posNew:newEnd)=header(:,posOrig:spacerColumns(i));
                newWithUnderline(:,posNew:newEnd)=withUnderline(:,posOrig:spacerColumns(i));
            end
            posNew=spacerColumns(i)+i+1;
            posOrig=spacerColumns(i)+1;
        else
            newCell(:,posNew:end)=cellToPrint(:,posOrig:end);
            newAllignment(:,posNew:end)=alignment(:,posOrig:end);
            if(withHeader)
                newHeader(:,posNew:end)=header(:,posOrig:end);
                newWithUnderline(:,posNew:end)=withUnderline(:,posOrig:end);
            end
        end
    end
    cellToPrint=newCell;
    alignment=newAllignment;
    if(withHeader)
        header=newHeader;
        withUnderline=newWithUnderline;
    end



end

% Add first column
if(withFirstColumn)
    assert(size(firstColumn,1)==size(cellToPrint,1),'Left column need to be the height of cellToPrint (or header + cellToPrint)');
    if(withHeader)
        if(conHeaderPrimeraColumna)
            header=[headerPrimeraColumna,header];

        else
            header=[repmat({' '},size(header,1),anchoPrimeraColumna),header];

        end
        withUnderline=[false(size(withUnderline,1),anchoPrimeraColumna),withUnderline];
    end

    cellToPrint=[firstColumn,cellToPrint];


end

% Arregla filas fantasma:
if(addSpacerRow)
    assert(all(spacerRows>=0&spacerRows<=size(cellToPrint,1)),"Can't add a spacer row after a row that doesn't exist!!")
    cantNuevas=length(spacerRows);
    newCell=repmat({' '},(size(cellToPrint)+[cantNuevas,0]));

    posOrig=1;
    posNew=1;
    for i=1:(cantNuevas+1)
        if(i<=length(spacerRows))
            newEnd=spacerRows(i)-posOrig+posNew;
            newCell(posNew:newEnd,:)=cellToPrint(posOrig:spacerRows(i),:);

            posNew=spacerRows(i)+i+1;
            posOrig=spacerRows(i)+1;
        else
            newCell(posNew:end,:)=cellToPrint(posOrig:end,:);
        end
    end
    cellToPrint=newCell;
    if(withPanel)
        for i=1:cantPaneles
            panel{i,1}=panel{i,1}+sum(spacerRows<=panel{i,1});
        end
    end
end

% Transform header to multi-column if needed:
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
    elseif(italicPanelHeader)
        bold='\textit';
    else
        bold='';
    end
    for c=1:cantPaneles
        posPanel=panel{c,1};
        headerPanel=panel{c,2};
        assert(all(posPanel>=0&posPanel<=size(cellToPrint,1)),'Can''t add a panel row after a row that doesn''t exist!! ')

        newRow=horzcat(skip,'\multicolumn{',sprintf('%i',size(cellToPrint,2)),'}{l}{',bold,'{',headerPanel,'}} \\',newline);

        auxImprimir=cellToPrint(posIni:posPanel,:)';
        preTabla=[preTabla,sprintf(string,auxImprimir{:,:}),newRow]; %#ok<AGROW>
        posIni=posPanel+1;
    end
    auxImprimir=cellToPrint(posIni:end,:)';
    preTabla=[preTabla,sprintf(string,auxImprimir{:,:}),];
else
    imprimir=cellToPrint';
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

preFootnote=''; % footnote is more complex than just adding one commented line...
if(includePValsNote||withFootnote)

    if(withFootnote)

        preFootnote='';
        if(not(includePValsNote))
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
    if(includePValsNote)
        if(strcmp(footNoteType,'tablenotes'))
            starPValsNote= '\item \textit{Notes. }*** p<0.01, ** p<0.05, * p<0.1. ';
        else
            starPValsNote= ' \textit{Notes. }*** p<0.01, ** p<0.05, * p<0.1. ';
        end
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


    if(not(isempty(label))||not(isempty(title)))
        if(fixTitleCase&&not(isempty(title)))
            apiKey='';
            title=char(pyrunfile(sprintf("titleCaseConverter.py '%s' '%s'",title,apiKey),'r'));
        end
        tit=['\caption{',title,'\label{',label,'}}',newline];

    else
        tit=['..comment..\caption{  \label{  }}',newline];
    end

    top=horzcat(newline,'\begin{table}..',positionParameter,'..',newline,...
        '\captionsetup{justification=centering}',newline,...
        '\centering',newline,...
        tit,...
        topAdj,newline,...
        preFootnote,environmentTableNotesTop,newlineFootnote,...
        preFontSizeTable,fontSizeTable,newline,...
        '\begin{tabular}{',sprintf('%s',alignmentFirstCol{:}),sprintf('%s',alignment{:}),'}',newline,...
        '\addlinespace',newline,...
        '\toprule',newline);%,...);widthPrimeraCol
    %repmat('&',1,numColumnas-1),'\\\\ \n',...
    %'\\midrule \n');

    bottom=horzcat('\bottomrule',newline,...
        '..comment..\addlinespace',newline,...
        '\end{tabular}',newline,...
        '\captionsetup{justification=justified}',newline,...
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


    if(printInputLatexCode)
        posTex=strfind(file,'.tex');
        if(~isempty(posTex));file=file(1:posTex(end)-1);end 

        % Busca el relative path

        if(~isempty(pos))
            file1=file(pos(end)+1:end);
            fprintf('\\input{%s}\n\n',file1);

            newPos=pos(pos<(pos(end)-1)); 
            if(~isempty(newPos))
                file2=file(newPos(end)+1:end);
                fprintf('\\input{%s}\n\n',file2);
            end

            if(includeExternalRelativePath)
                if(not(endsWith(externalRelativePath,'/')))
                    externalRelativePath= sprintf('%s/',externalRelativePath);
                end
                fprintf('\\input{%s}\n\n',[externalRelativePath,file1]);
            end

        else
            if(includeExternalRelativePath)
                if(not(endsWith(externalRelativePath,'/')))
                    externalRelativePath= sprintf('%s/',externalRelativePath);
                end
                fprintf('\\input{%s}\n\n',[externalRelativePath,file]);
            end
        end

    end
end

end

