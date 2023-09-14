function tablaOrStruct=removeIfExists(tablaOrStruct,nameVarToRemove,varargin)

warnIfExist=false;

if(~isempty(varargin))
    
    % This checks a few things, including if there is a struct called "opts"
    varargin=checkVarargin(varargin);
    
    while ~isempty(varargin)
        switch lower(varargin{1})
			case{'warnifexist'}
				warnIfExist = varargin{2};

                
            otherwise
                error(['Unexpected option: ' varargin{1}])
        end
        varargin(1:2) = [];
    end
end

if(~iscellstr(nameVarToRemove)) %#ok<ISCLSTR>
    if(ischar(nameVarToRemove))
        nameVarToRemove={nameVarToRemove};
    elseif(isstring(nameVarToRemove))
        nameVarToRemove=cellstr(nameVarToRemove);
    end
end


if(istable(tablaOrStruct))
    inTable=ismember(nameVarToRemove,tablaOrStruct.Properties.VariableNames);

    if(any(inTable))
        if(warnIfExist)
            warning('Removing the following variables:')
            fprintf('%s\n',nameVarToRemove{inTable})
        end
        tablaOrStruct=removevars(tablaOrStruct,nameVarToRemove(inTable));
    end

elseif(isstruct(tablaOrStruct))

    inStruct=isfield(tablaOrStruct,nameVarToRemove);

    if(any(inStruct))
        if(warnIfExist)
            warning('Removing the following variables:')
            fprintf('%s\n',nameVarToRemove{inStruct})
        end
        tablaOrStruct = rmfield(tablaOrStruct,nameVarToRemove(inStruct));

    end
else
    error('Acá')

end


