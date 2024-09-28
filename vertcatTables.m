function newTable=vertcatTables(cellOfTables,varargin)

fillWithMissing={}; % Fill specific variables that are not common with missing values if the variable doesn't exist
fillAllWithMissing=false; % Fill all variables that are not common with missing values if the variable doesn't exist
avoidDisplayDiagnosticIfFillMiss=false;
diagnosticCommonVars=false;
keepOnlyVars={}; % If empty, then it does nothing.

if(~isempty(varargin))

    % This checks a few things, including if there is a struct called "opts"
    varargin=checkVarargin(varargin);

    while ~isempty(varargin)
        switch lower(varargin{1})
            case {'fillwithmissing'}
                fillWithMissing= varargin{2};
            case {'diagnosticcommonvars','diagnostic','d'}
                diagnosticCommonVars= varargin{2};
            case {'fillallwithmissing'}
                fillAllWithMissing= varargin{2};
            case {'avoiddisplaydiagnosticiffillmiss'}
                avoidDisplayDiagnosticIfFillMiss= varargin{2};
			case{'keeponlyvars'}
				keepOnlyVars = varargin{2};

            otherwise
                error(['Unexpected option: ' varargin{1}])
        end
        varargin(1:2) = [];
    end
end

C=numel(cellOfTables);

if(numel(keepOnlyVars)>0)
    for c=1:C
        cellOfTables{c}=cellOfTables{c}(:,keepOnlyVars);
    end
end

if(fillAllWithMissing&&not(avoidDisplayDiagnosticIfFillMiss)||diagnosticCommonVars)
    diagnosticCommonVars=true;
else
    diagnosticCommonVars=false;
end

[~,notCommonVars,allVars,allVarsTypesUnique]=getCommonVars(cellOfTables,'checkIfTypeIsUnique',true,'diagnosticCommonVars',diagnosticCommonVars);

if(fillAllWithMissing)
    fillWithMissing=notCommonVars;
end


if(not(isempty(fillWithMissing)))
    [inAny,posAll]=ismember(fillWithMissing,allVars);
    assert(all(inAny),'Variables to fill with missing are not in any of the tables');
    typeFillWithMissing=allVarsTypesUnique(posAll);

    F=numel(fillWithMissing);
    for c=1:C
        vars=cellOfTables{c}.Properties.VariableNames;
        for f=1:F
            if(not(ismember(fillWithMissing{f},vars)))
                cellOfTables{c}.(fillWithMissing{f})=scalarForTable(getMissingByClass(typeFillWithMissing{f}),cellOfTables{c});
            end
        end
    end
end

[commonVars]=getCommonVars(cellOfTables,'checkIfTypeIsUnique',true);

for c=1:C
    cellOfTables{c}=cellOfTables{c}(:,commonVars);
end
newTable=vertcat(cellOfTables{:});
