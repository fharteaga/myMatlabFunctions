function allUniques=checkUniquenessById(idVarName,tabla,varargin)

conMensaje=true;
withExample=true;
convertMatToStrInDetails=false;
if(~isempty(varargin))

    % This checks a few things, including if there is a struct called "opts"
    varargin=checkVarargin(varargin);

    while ~isempty(varargin)
        switch lower(varargin{1})
            case {'conmensaje'}
                conMensaje= varargin{2};
            case {'withexample'}
                withExample= varargin{2};
            case {'mat2str','m2s'}
                convertMatToStrInDetails=varargin{2};
            otherwise
                error(['Unexpected option: ' varargin{1}])
        end
        varargin(1:2) = [];
    end
end



vars=removeFromSet(tabla.Properties.VariableNames,idVarName);
tabla=stataCollapse(idVarName,tabla,[vars,vars],[repmat({'set'},1,length(vars)),repmat({'countunique'},1,length(vars))]);


singletons=false(length(vars),1);
for v=1:length(vars)
    uniques=cellfun(@(x)(length(unique(x))-sum(ismissing(x)))<=1,tabla.([vars{v},'_set']));
    singletons(v)=all(uniques);

    if(iscellstr(idVarName))
        idVarStr=sprintf('%s -',idVarName{:});
    else
        idVarStr=idVarName;
        idVarName={idVarName};
    end

    if(not(singletons(v)))
      
        fprintf('\nVar %s in not unique for %i (of %i: %.1f%%) obs in %s  (example below)\n\n ',vars{v},sum(not(uniques)),length(uniques),mean(not(uniques))*100,idVarStr);
        if(withExample)
            cantExample=3;
            pos=find(not(uniques),cantExample);
            fprintf('Examples (%i) in which %s is not unique within ID (last column are the count of unique values):\n',cantExample,vars{v})
            if(convertMatToStrInDetails)
                disp(displayFullIntegers(tabla(pos,[idVarName,vars{v}])));
            else
                disp(tabla(pos,[idVarName,vars{v}]));
            end
            fprintf('Example of dispertion of %s for the first row of the table above:\n',vars{v})
            (tab(tabla.([vars{v},'_set']){pos(1)}));
        end
    end


end
allUniques=all(singletons);
if(allUniques)
    if(conMensaje)
        fprintf('All vars unique within ');

        if(iscellstr(idVarName))
            fprintf(' %s ',idVarName{:});
            fprintf('\n');
        else
            error('aca')
        end
    end
end