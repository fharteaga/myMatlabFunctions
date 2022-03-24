function [dataCollapsed,latexTable,cell2LatexInput]=stataCollapse(idVarName,dataToCollapse,varsNameToCollapse,whichstats,varargin)

% Mejora: hacer que solo rescate las posiciones, y hacer todas las
% funciones dentro de este mfile, para que tb soporte string (y trabaje en
% los eleemntos nativos de cada variables). Incluso puede haber algo más
% eficiente que mi loop wn que recorre todas las observaciones (usar
% grpstat para rescatar posMinMax por ejemplo? muy testeable la
% velocidad... y quizás en ese caso no es necesario crear idVar
% auxiliares...
% USE splitapply!!!!, not sure, cannot combine multiple vars/stats very
% well

% Defaults:
mergeWithOriginal=false;
sortrowsInside=false;
latexTableOpts={};
mat2cellstrOpts={};
withCount=false;
countVarName='count';
customFun=[];

% Loading optional arguments
if(~isempty(varargin))
    % This checks a few things, also if there is struct called "opts"
    varargin=checkVarargin(varargin);
    while ~isempty(varargin)
        switch lower(varargin{1})
            case {'mergewithoriginal','mwo'}
                mergeWithOriginal = varargin{2};
                assert(islogical(varargin{2}))
            case {'sortrows','sort'}
                sortrowsInside=varargin{2};
                assert(islogical(varargin{2}))
            case 'customfun'
                customFun=varargin{2};
                assert(isa(varargin{2},'function_handle')||isa(varargin{2},'struct'))
            case {'latextableopts','latextableoptions'}
                latexTableOpts=varargin{2};
                assert(iscell(varargin{2}))
            case {'mat2cellstropts','mat2cellstroptions'}
                mat2cellstrOpts=varargin{2};
                assert(iscell(varargin{2}))
            case {'count','n'}
                withCount=varargin{2};
            case {'countvarname'}
                countVarName=varargin{2};
            otherwise
                error(['Unexpected option: ' varargin{1}])
        end
        varargin(1:2) = [];
    end
end

assert(istable(dataToCollapse),'Second input must be a table!')



if(ischar(varsNameToCollapse))
    varsNameToCollapse={varsNameToCollapse};
end

if(ischar(whichstats))
    whichstats={whichstats};
end
if(length(whichstats)==1&&length(varsNameToCollapse)>1)
    whichstats=repmat(whichstats,1,length(varsNameToCollapse));
end

assert(length(whichstats)==length(varsNameToCollapse))


% Esto hace que haga el cambio de id a numero, lo que agiliza el proceso!
if(ischar(idVarName))
    idVarName={idVarName};
end

if(withCount)
    assert(not(ismember(countVarName,dataToCollapse.Properties.VariableNames)))
    dataToCollapse.(countVarName)=ones(height(dataToCollapse),1);
    varsNameToCollapse=[varsNameToCollapse,{countVarName}];
    whichstats=[whichstats,{'sum'}]; % Sum because is the one that makes sense in case that the statFunction name is added.
end

assert(iscellstr(varsNameToCollapse))

% Saca el set de la lista de variables
isSetStat=strcmp(whichstats,'set');


setVarsNames=varsNameToCollapse(isSetStat);
varsNameToCollapse=varsNameToCollapse(not(isSetStat));
whichstats=whichstats(not(isSetStat));
assert(allunique(setVarsNames))


containsCustomStat=(any(startsWith(whichstats,'c_')));
containsPosStat=(any(ismember({'first','last','second','third'},whichstats))||any(startsWith(whichstats,'pos')));

% If I told it to sort (sortrowsInside) or order is not relevant, then sort
if(sortrowsInside||not(containsPosStat||containsCustomStat))
    if(sortrowsInside&&(containsPosStat))
        error('If a "position" stat is specified, array must come sorted')
    end
    dataToCollapse=sortrows(dataToCollapse,idVarName);
end



% Chequea que haya un id (o un set!)
assert(ischar(idVarName)||iscellstr(idVarName))
assert(all(not(ismember(idVarName,varsNameToCollapse))),'id vars cannot be collapsed')


cantVars=length(varsNameToCollapse);
assert(length(whichstats)==cantVars,'Defines %i variables a collapsar y %i stats',cantVars,length(whichstats))


if(length(unique(varsNameToCollapse))==cantVars&&not(mergeWithOriginal))
    newNames=varsNameToCollapse;
else
    newNames=cell(size(varsNameToCollapse));
    
    
    whichstatsAlt=whichstats;
    % Change it because names of tables/dataset variables cannot contain "."
    for c=1:length(whichstatsAlt)
        if(all(whichstatsAlt{c}(1:2)=='q.'))
            whichstatsAlt{c}=['q_',whichstatsAlt{c}(3:end)];
        end
    end
    
    for c=1:cantVars
        
        newNames{c}=sprintf('%s_%s',varsNameToCollapse{c},whichstatsAlt{c});
    end
    
    assert(length(newNames)==length(unique(newNames)))
    
end

varNamesOriginalData=dataToCollapse.Properties.VariableNames;
N=height(dataToCollapse);


if(ischar(idVarName)) % If there is a unique idVar
    idVar=dataToCollapse.(idVarName);
    if(isnumeric(idVar))
        assert(all(not(isnan(idVar))),'ID var %s contains a NaN',idVarName)
    elseif(iscategorical(idVar))
        assert(all(not(isundefined(idVar))),'ID var %s contains an undefined (categorical)',idVarName)
    else
        assert(all(not(ismissing(idVar))),'ID var %s contains a missing',idVarName)
    end
    if(mergeWithOriginal)
        % This is to recover the original sorting after merging collapsed
        % data:
        
        assert(not(ismember('auxSort__',varNamesOriginalData)))
        dataToCollapse.auxSort__=(1:N)';
    end
else % If there are multiple idVars
    
    % To preserve original sorting, I create auxSort__
    assert(not(ismember('auxSort__',varNamesOriginalData)))
    dataToCollapse.auxSort__=(1:N)';
    
    
    % Create new idVar
    
    varsAux=dataToCollapse(:,idVarName);
    
    % Check that NaN is not part of varsAux
    for k=1:size(varsAux,2)
        if(isnumeric(varsAux{:,k}))
            assert(all(not(isnan(varsAux{:,k}))),'ID var %s contains a NaN',idVarName{k})
        elseif(iscategorical(varsAux{:,k}))
            assert(all(not(isundefined(varsAux{:,k}))),'ID var %s contains an undefined (categorical)',idVarName{k})
        else
            assert(all(not(ismissing(varsAux{:,k}))),'ID var %s contains a missing',idVarName{k})
        end
    end
    
    % Check if sorted
    assert(isequaln(varsAux,sortrows(varsAux)),'idVars must be sorted --tip: add ,''sort'',true ');
    
    dataAux=unique(varsAux,'rows');
    assert(not(ismember('id__',varNamesOriginalData)))
    dataAux.id__=(1:size(dataAux,1))';
    
    % Create dataset to make the merge multiple id to one
    
    
    
    dataToCollapse=outerjoin(dataToCollapse,dataAux,'keys',idVarName,'mergeKeys',true,'type','left');
    
    dataToCollapse=sortrows(dataToCollapse,'auxSort__');
    idVar=dataToCollapse.id__;
    clearvars varsAux
    
end


subsetToCollapse=dataToCollapse(:,varsNameToCollapse);
subsetToCollapse.Properties.VariableNames=newNames;

categoriesCell=cell(cantVars,4);
categoriesStats={'first','second','third','last'};
categoriesOrdinalStats={'max','min'};
categoriesStatsDoNotConvertBack={'count','countunique','countmissing'};


% Check that all are doubles, if not table2array deja la caga (cuando
% hay distintos tipos)

isCell=false(cantVars,1);

for j=1:cantVars
    test=subsetToCollapse{:,j}(1);
    if(islogical(test)||isnumeric(test)||iscategorical(test))
        if(not(isa(test,'double')))
            
            
            
            subsetToCollapse.(newNames{j})=double(subsetToCollapse.(newNames{j}));
            
            
            if(iscategorical(test))
                if(isordinal(test))
                    assert(ismember(whichstats{j},[categoriesStats,categoriesOrdinalStats,categoriesStatsDoNotConvertBack])||strcmp(whichstats{j}(1:2),'c_')||strcmp(whichstats{j}(1:2),'po'),sprintf('Sorry, %s is categorical, and cannot perform %s!',varsNameToCollapse{j},whichstats{j}) )
                else
                    assert(ismember(whichstats{j},[categoriesStats,categoriesStatsDoNotConvertBack])||strcmp(whichstats{j}(1:2),'c_')||strcmp(whichstats{j}(1:2),'po'),sprintf('Sorry, %s is categorical (not ordinal), and cannot perform %s!',varsNameToCollapse{j},whichstats{j}))
                end
                
                categoriesCell{j,1}=1:length(categories(test));
                categoriesCell{j,2}=categories(test);
                categoriesCell{j,3}=isordinal(test);
                categoriesCell{j,4}=not(ismember(whichstats{j},categoriesStatsDoNotConvertBack));
            else
                cprintf('*systemcommand','[stataCollapse.m Unofficial Warning] ')
                cprintf('systemcommand','Varible %s is a %s (not a double), it is being converted!\n',varsNameToCollapse{j},class(test))
            end
        end
    else
        isCell(j)=true;
    end
end

array_cell=table2cell(subsetToCollapse(:,isCell));
whichstats_cell=whichstats(isCell);
newNames_cell=newNames(isCell);
cantVars_cell=sum(isCell);

array=table2array(subsetToCollapse(:,not(isCell)));
whichstats=whichstats(not(isCell));
newNames=newNames(not(isCell));
cantVars=sum(not(isCell));

%% Collapse:

[varCollapsed,idVarCollapsed,varCollapsed_cell,posMinMax]=stataCollapseArray(idVar,array,whichstats,customFun,array_cell,whichstats_cell);

% Recupera los sets
% No hago esto en stataCollapseArray, pq tendría que preocuparme de pasarle
% como input un vector (matriz) por cada tipo.

cantSets=length(setVarsNames);
cellSets=cell(size(posMinMax,1),cantSets);

for vs=1:cantSets
    setVar=dataToCollapse.(setVarsNames{vs});
    for i=1:size(posMinMax,1)
        cellSets{i,vs}=setVar(posMinMax(i,1):posMinMax(i,2));
    end
end


%% Back to table/dataset

dataCollapsed=table;

dataCollapsed.id__=idVarCollapsed;

% To preserve original sorting, I create auxSort___
dataCollapsed.auxSort___=(1:size(dataCollapsed,1))';

assert(height(dataCollapsed)==height(dataAux));
dataCollapsed=innerjoin(dataCollapsed,dataAux,'keys','id__');

dataCollapsed.id__=[];
dataCollapsed=sortrows(dataCollapsed,'auxSort___');
dataCollapsed.auxSort___=[];



for c=1:cantVars
    % Convert back categorical values:
    if(not(isempty(categoriesCell{c,1}))&&categoriesCell{c,4})
        dataCollapsed.(newNames{c})=categorical(varCollapsed(:,c),categoriesCell{c,1},categoriesCell{c,2},'ordinal',categoriesCell{c,3});
        
    else
        dataCollapsed.(newNames{c})=varCollapsed(:,c);
    end
end

for c=1:cantVars_cell
    dataCollapsed.(newNames_cell{c})=varCollapsed_cell(:,c);
end

% Agrega los sets:

for vs=1:cantSets
    newSetVarName=[setVarsNames{vs},'_set'];
    assert(not(ismember(newSetVarName,[newNames,newNames_cell,idVarName])))
    dataCollapsed.(newSetVarName)=cellSets(:,vs);
    
end





if(mergeWithOriginal)
    if(not(ischar(idVarName)))
        dataToCollapse.id__=[];
    end
    
    % Check that new variables do not exist in original
    cantSameVars=sum(ismember(dataCollapsed.Properties.VariableNames,dataToCollapse.Properties.VariableNames));
    assert(cantSameVars==length(idVarName),'Cannot merge. Original dataset has a variable with the same name that one of the new variables.')
    
    
    dataCollapsed=outerjoin(dataToCollapse,dataCollapsed,'keys',idVarName,'mergeKeys',true,'type','left');
    
    dataCollapsed=sortrows(dataCollapsed,'auxSort__');
    dataCollapsed.auxSort__=[];
end

%% Create Latex Table
if(nargout>1)
    assert(not(mergeWithOriginal))
    % Print latex table with the collapsed dataset
    
    % Check type of idVars
    tableIds=dataCollapsed(:,idVarName);
    cellIds=cell(size(tableIds));
    changes=false(size(tableIds));
    for i=1:width(tableIds)
        auxVar=tableIds{:,i};
        
        if(iscategorical(auxVar))
            cellIds(:,i)=cellstr(auxVar);
        elseif(isnumeric(auxVar))
            cellIds(:,i)=mat2cellstr(auxVar);
        elseif(iscellstr(auxVar)) %#ok<ISCLSTR>
            cellIds(:,i)=auxVar;
        end
        auxCellIds=cellIds(:,i);
        for j=2:height(tableIds)
            
            if(strcmp(auxCellIds{j-1},auxCellIds{j})&&not(any(changes(j,1:i))))
                cellIds{j,i}='';
            elseif(i<width(tableIds))
                changes(j,i)=true;
            end
        end
    end
    
    % Header:
    for i=1:length(varsNameToCollapse)
        if(not(isempty(dataToCollapse.Properties.VariableDescriptions{varsNameToCollapse{i}})))
            varsNameToCollapse{i}=dataToCollapse.Properties.VariableDescriptions{varsNameToCollapse{i}};
        end
    end
    formalWhichstats=whichstats;
    for w=1:length(whichstats)
        
        if(strcmp(whichstats{w}(1:2),'q.'))
            perc=str2double(whichstats{w}(2:end))*100;
            assert(perc>0&&perc<100)
            
            if((perc-floor(perc))==0)
                formalWhichstats{w}=sprintf('%2.0fth Perc.',perc);
            else
                formalWhichstats{w}=sprintf('%4.2fth Perc.',perc);
            end
        else
            switch whichstats{w}
                case 'sum'
                    formalWhichstats{w}='Total';
                case 'mean'
                    formalWhichstats{w}='Mean';
                case 'min'
                    formalWhichstats{w}='Min.';
                case 'max'
                    formalWhichstats{w}='Max.';
                case 'sd'
                    formalWhichstats{w}='Std. Dev.';
                case 'count'
                    formalWhichstats{w}='Obs.';
                case 'relativeSize'
                    formalWhichstats{w}='Perc. of total';
            end
        end
    end
    
    if(ischar(idVarName))
        idVarName={idVarName};
    end
    headerPrimeraCol={dataToCollapse.Properties.VariableDescriptions{idVarName}};
    for h=1:length(headerPrimeraCol)
        if(strcmp(headerPrimeraCol{h},''))
            headerPrimeraCol{h}=idVarName{h};
        end
    end
    
    header=[{dataToCollapse.Properties.VariableDescriptions{idVarName}},varsNameToCollapse;...
        repmat({' '},1,length(idVarName)),formalWhichstats]; %#ok<CCAT1>
    
    
    if(any(changes,'all'))
        latexTableOpts=[latexTableOpts,{'filasFantasma',find(any(changes,2))-1}];
    end
    
    cellTable=mat2cellstr(varCollapsed,mat2cellstrOpts{:});
    latexTable=cell2latex(cellTable,'primeraColumna',cellIds,'header',header,latexTableOpts{:});
    if(nargout>2)
        cell2LatexInput={cellTable,cellIds,header};
    end
end

end
