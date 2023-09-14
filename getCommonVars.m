function [commonVars,notCommonVars,allVars,allVarsTypesUnique]=getCommonVars(cellOfTables,varargin)

checkIfTypeIsUnique=false;
diagnosticCommonVars=false;
logicalAndDoubleSameType=true; % Since logical and double can be concatenated, I transform all logical to doubles for "checking purposes"
         
if(~isempty(varargin))

    % This checks a few things, including if there is a struct called "opts"
    varargin=checkVarargin(varargin);

    while ~isempty(varargin)
        switch lower(varargin{1})
            case {'checkiftypeisunique'}
                checkIfTypeIsUnique= varargin{2};
            case {'d','diagnosticcommonvars'}
                diagnosticCommonVars= varargin{2};

            otherwise
                error(['Unexpected option: ' varargin{1}])
        end
        varargin(1:2) = [];
    end
end


C=numel(cellOfTables);
tabVars=cell(C,1);
c=1;
tabVars{c}=cellOfTables{c}.Properties.VariableNames;
allVars=tabVars{c};
commonVars=tabVars{c};

for c=2:C
    tabVars{c}=cellOfTables{c}.Properties.VariableNames;
    commonVars=intersect(commonVars,tabVars{c});
    allVars=union(allVars,tabVars{c});
end

if(diagnosticCommonVars)
    if(not(isempty(commonVars)))
        fprintf('Common vars in all tables:\n')
        fprintf('\t%s\n',commonVars{:})
    end

    for c=1:C
        notInT=allVars(not(ismember(allVars,tabVars{c})));
        if(not(isempty(notInT)))
            fprintf('\nMissing vars in table %i:\n',c)
            fprintf('\t%s\n',notInT{:})
            fprintf('\n')
        else
            fprintf('\nThere are not missing vars in table %i.\n\n',c)
        end
    end

end

if(nargout>2||checkIfTypeIsUnique)
    V=numel(allVars);
    allVarsTypes=repmat({''},V,C);
    allVarsTypesUnique=repmat({''},V,C);
    allVarsCantTypes=nan(V,1);

    for c=1:C
        types=varfun(@class,cellOfTables{c},'OutputFormat','cell');
        [is,pos]=ismember(tabVars{c},allVars);
        assert(all(is))
        allVarsTypes(pos,c)=types;
        
    end


    
    if(checkIfTypeIsUnique)




        allSameType=true;
        for v=1:V
            sirvenType=not(ismissing(allVarsTypes(v,:)))&not(strcmp(allVarsTypes(v,:),'missing'));
            uniqueTypes=unique(allVarsTypes(v,sirvenType));
            allVarsCantTypes(v)=length(uniqueTypes);

            if(allVarsCantTypes(v)==1)
                allVarsTypesUnique{v}=uniqueTypes{1};

            elseif(logicalAndDoubleSameType&&allVarsCantTypes(v)==2&&all(ismember({'logical','double'},uniqueTypes)))

                allVarsTypesUnique{v}='double';


            else
                 
                allSameType=false;
                fprintf('Variable %s has different types among tables:\n',allVars{v})
                for c=1:C
                    t=allVarsTypes(v,c);
                    if(not(ismissing(t)))
                        fprintf('\t Table %i :%s\n',c,t{1});
                    end

                end
            end
        end
        if(not(allSameType))
            error('Not all variables the same type,look above')

        end
    end
end

if(nargout>1)
    notCommonVars=allVars(not(ismember(allVars,commonVars)));
end