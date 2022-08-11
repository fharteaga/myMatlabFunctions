function [areAllUnique,freq]=allunique(var,varargin)

printExamples=0;
printDetails=false;
vars={};
if(~isempty(varargin))

    % This checks a few things, including if there is a struct called "opts"
    varargin=checkVarargin(varargin);

    while ~isempty(varargin)
        switch lower(varargin{1})
            case {'printexamples','pe'}
                printExamples= varargin{2};
                if(islogical(printExamples))
                    printExamples=double(printExamples);
                end
            case {'printdetails','pd'}
                printDetails=varargin{2};
            case {'variablesnames','vars'}
                vars=varargin{2};
                if(not(iscellstr(vars)))
                    vars={vars};
                end


            otherwise
                error(['Unexpected option: ' varargin{1}])
        end
        varargin(1:2) = [];
    end
end


if(istable(var))
    %% If table
    varsT=var.Properties.VariableNames;
    if(isempty(vars))
        vars=varsT;
    else
        assert(all(ismember(vars,varsT)))
    end
    areAllUnique=height(var)==height(unique(var(:,vars)));



else
    %% If matrix or cellstr
    assert(all(not(ismissing(var))),'Cannot check uniques of there are missings')

    if(sum(size(var)>1)>1)
        assert(nargout==1)
        var=reshape(var,numel(var),1);
    end
    areAllUnique=length(var)==length(unique(var));


end

if(areAllUnique)
    printExamples=0;
end

if(nargout>1||printExamples>0)
    if(istable(var))
        freq=duplicates(var,'vars',vars,'printExamples',printExamples,'printDetails',printDetails);
    else
        freq=duplicates(var,'printExamples',printExamples);
    end

end