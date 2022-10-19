function [tablaOut,varNameCombined]=combineDiscreteVars(tablaIn,varNames,varargin)
% Agrega una variable ("combined") a la tabla.

% tablaIn puede ser un array tb. En ese caso, dejar varNames en blanco.
varNameCombined='combined';

if(~isempty(varargin))

    % This checks a few things, including if there is a struct called "opts"
    varargin=checkVarargin(varargin);

    while ~isempty(varargin)
        switch lower(varargin{1})
            case {'varnamecombined'}
                varNameCombined= varargin{2};
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
end

varsT=tablaIn.Properties.VariableNames;

assert(not(ismember(varNameCombined,varsT)))
assert(allunique(varNames))

[unicos,~,ic]=unique(tablaIn(:,varNames),'rows');

if(length(varNames)==2)
    newUnicos=categorical(arrayfun(@(x,y)sprintf('%s - %s',x,y),categorical(unicos.(varNames{1})),categorical(unicos.(varNames{2})),'UniformOutput',false));
    varDescription=sprintf('%s - %s',varNames{1},varNames{2});
elseif(length(varNames)==3)
    newUnicos=categorical(arrayfun(@(x,y,z)sprintf('%s - %s - %s',x,y,z),categorical(unicos.(varNames{1})),categorical(unicos.(varNames{2})),categorical(unicos.(varNames{3})),'UniformOutput',false));
    varDescription=sprintf('%s - %s - %s',varNames{1},varNames{2},varNames{3});
else
    error('Programar!')
end



tablaOut=tablaIn;

tablaOut.(varNameCombined)=newUnicos(ic);
tablaOut.Properties.VariableDescriptions{varNameCombined}=varDescription;

