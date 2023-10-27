function [out,varNameCombined]=combineDiscreteVars(tablaIn,varNames,varargin)
% Generates a variable that represents unique values for the table or array.

% Output is the new variable. Is a table if output='variable'

output='variable'; % table or variable
varNameCombined='combined'; % Only if output=='table'
withMissingWarningMessage=true;
omitMissings=true;


if(~isempty(varargin))

    % This checks a few things, including if there is a struct called "opts"
    varargin=checkVarargin(varargin);

    while ~isempty(varargin)
        switch lower(varargin{1})
            case {'namevarcombined','varnamecombined'}
                varNameCombined= varargin{2};
            case{'withmissingwarningmessage'}
                withMissingWarningMessage= varargin{2};
            case{'omitnans','omitmissings'}
                omitMissings=varargin{2};
            case{'output'}
                output=varargin{2};
            otherwise
                error(['Unexpected option: ' varargin{1}])
        end
        varargin(1:2) = [];
    end
end

if(not(istable(tablaIn)))
    arrayIn=tablaIn;
    tablaIn=table;
    cantVars=size(arrayIn,2);
    assert(cantVars>1)
    varNames=cell(cantVars,1);
    for w=1:cantVars
        varNames{w}=sprintf('var%i',w);
        tablaIn.(varNames{w})=arrayIn(:,w);
    end
else
    if(isempty(varNames))
        varNames=tablaIn.Properties.VariableNames;
    end
end

assert(allunique(varNames))

rowWithMissing=any(ismissing(tablaIn(:,varNames)),2);
if(any(rowWithMissing))
    if(omitMissings)
        if(withMissingWarningMessage)
            cprintf('*systemcommand','[combineDiscreteVars.m Unofficial Warning] ')
            cprintf('systemcommand','%.2f %% of observations (%i of %i) contain missings in at least one of the variables\n',mean(rowWithMissing)*100,sum(rowWithMissing),length(rowWithMissing))
        end
    else

        error('%.2f %% of observations (%i of %i) contain missings in at least one of the variables\n',mean(rowWithMissing)*100,sum(rowWithMissing),length(rowWithMissing))
    end
end

[unicos,~,ic]=unique(tablaIn(not(rowWithMissing),varNames),'rows');

if(length(varNames)==2)
    newUnicos=categorical(arrayfun(@(x,y)sprintf('%s - %s',x,y),categorical(unicos.(varNames{1})),categorical(unicos.(varNames{2})),'UniformOutput',false));
    varDescription=sprintf('%s - %s',varNames{1},varNames{2});
elseif(length(varNames)==3)
    newUnicos=categorical(arrayfun(@(x,y,z)sprintf('%s - %s - %s',x,y,z),categorical(unicos.(varNames{1})),categorical(unicos.(varNames{2})),categorical(unicos.(varNames{3})),'UniformOutput',false));
    varDescription=sprintf('%s - %s - %s',varNames{1},varNames{2},varNames{3});
elseif(length(varNames)==4)
    newUnicos=categorical(arrayfun(@(x,y,z,w)sprintf('%s - %s - %s - %s',x,y,z,w),categorical(unicos.(varNames{1})),categorical(unicos.(varNames{2})),categorical(unicos.(varNames{3})),categorical(unicos.(varNames{4})),'UniformOutput',false));
    varDescription=sprintf('%s - %s - %s - %s',varNames{1},varNames{2},varNames{3},varNames{4});
else
    error('Programar!')
end


varComb=categorical(nan(height(tablaIn),1));
varComb(not(rowWithMissing))=newUnicos(ic);

if(strcmpi(output,'table'))
    assert(not(ismember(varNameCombined,tablaIn.Properties.VariableNames)))
    tablaIn.(varNameCombined)=varComb;
    tablaIn.Properties.VariableDescriptions{varNameCombined}=varDescription;
    out=tablaIn;
elseif(strcmpi(output,'variable'))
    out=varComb;
else
    error('aca')
end

