function allUniques=checkUniquenessById(idVarName,tabla,varargin)

conMensaje=true;
if(~isempty(varargin))
    
    % This checks a few things, including if there is a struct called "opts"
    varargin=checkVarargin(varargin);
    
    while ~isempty(varargin)
        switch lower(varargin{1})
            case {'conmensaje'}
                conMensaje= varargin{2};
                
            otherwise
                error(['Unexpected option: ' varargin{1}])
        end
        varargin(1:2) = [];
    end
end



vars=removeFromSet(tabla.Properties.VariableNames,idVarName);
tabla=stataCollapse(idVarName,tabla,vars,'set');
withExample=true;

singletons=false(length(vars),1);
for v=1:length(vars)
   uniques=cellfun(@(x)(length(unique(x))-sum(ismissing(x)))<=1,tabla.([vars{v},'_set']));
   singletons(v)=all(uniques);
   
    if(not(singletons(v)))
        fprintf('Var %s in not unique in %.1f%% of obs within %s  (example below)\n ',vars{v},mean(not(uniques))*100,idVarName);
        if(withExample)
            pos=find(not(uniques),3);
           disp(tabla(pos,{idVarName,[vars{v},'_set']}));
           disp(tabla.([vars{v},'_set']){pos(1)});
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
        fprintf('%s\n',idVarName);
    end
    end
end