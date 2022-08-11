function dup=duplicates(tableIn,varargin)

printExamples=0;
printDetails=false;
convertMatToStrInDetails=false;
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
            case {'mat2str','m2s'}
                convertMatToStrInDetails=varargin{2};
    

            otherwise
                error(['Unexpected option: ' varargin{1}])
        end
        varargin(1:2) = [];
    end
end


if(istable(tableIn))
    varsT=tableIn.Properties.VariableNames;
    if(isempty(vars))
        vars=varsT;
    else
        assert(all(ismember(vars,varsT)))
    end
    assert(not(ismember('ones_d_',varsT)))
    assert(not(ismember('order_d_',varsT)))
    assert(not(ismember('order_dp_',varsT)))


else

    assert(not(printDetails))
    assert(isempty(vars))
    assert(size(tableIn,2)==1)
    var=tableIn;
    tableIn=table;
    tableIn.var=var;
    vars={'var'};
end


% Check if there are missings: missings are counts are "the same"
numericMissReplacment=nan(length(vars),1);
for v=1:length(vars)
    var=tableIn.(vars{v});
    miss=ismissing(var);
    if(any(miss))
        warning('Variable %s has %i missing values (%.1f%%)',vars{v},sum(miss),100*mean(miss))

        if(isnumeric(var))
            numericMissReplacment(v)=max(var,[],'omitnan')+1;
            assert(not(numericMissReplacment(v)==Inf))
            var(miss)=numericMissReplacment(v);
        elseif(iscategorical(var))
            var=addcats(var,'___missing___');
            var(miss)='___missing___';
        elseif(iscellstr(var)) %#ok<ISCLSTR>
            var(miss)={'___missing___'};
        else
            error('aca')

        end
        tableIn.(vars{v})=var;
    end
end

tableIn.ones_d_=ones(height(tableIn),1);
tableIn.order_d_=(1:height(tableIn))';
tableIn=sortrows(tableIn,vars);
if(printExamples)
    tableIn.order_dp_=(1:height(tableIn))';
end


if(printExamples==0)
    tableD=stataCollapse(vars,tableIn,'ones_d_','sum','mergewithoriginal',true);
elseif(printDetails)
    tableD=stataCollapse(vars,tableIn,{'ones_d_','order_dp_','order_dp_'},{'sum','first','last'},'mergewithoriginal',true);
else
    tableD=stataCollapse(vars,tableIn,{'ones_d_','order_dp_'},{'sum','first'},'mergewithoriginal',true);
end

% Revert to original order
tableD=sortrows(tableD,'order_d_');
dup=tableD.ones_d__sum;


if(printExamples>0)


    % Replace missing numerics:

    for v=1:length(vars)
        if(not(isnan(numericMissReplacment(v))))
            var=tableD.(vars{v});
            var(var==numericMissReplacment(v))=nan;
            tableD.(vars{v})=var;

            if(printDetails)
                var=tableIn.(vars{v});
                var(var==numericMissReplacment(v))=nan;
                tableIn.(vars{v})=var;
            end
        end
    end




    tableD=sortrows(tableD,'ones_d__sum','descend');
    tableOut=tableD(tableD.order_dp_==tableD.order_dp__first&tableD.ones_d__sum>1,:);

    if(height(tableOut)<printExamples)
        %warning('There are no more than %i duplicates',height(tableOut))
        printExamples=height(tableOut);
    end


    tableOut.DUPLICATES=tableOut.ones_d__sum;
    tableAux=tableOut(1:printExamples,['DUPLICATES',vars]);
    fprintf('\n')
    if(printExamples>1)
        fprintf('Examples (%i out of %i duplicated obs):\n',printExamples,height(tableOut))
    else
        fprintf('Example (out of %i duplicated obs)\n',height(tableOut))
    end


    fprintf('\n')
    disp(tableAux)

    if(printDetails)

        for e=1:printExamples
            tableAux_d=tableIn(tableIn.order_dp_>=tableOut.order_dp__first(e)&tableIn.order_dp_<=tableOut.order_dp__last(e),varsT);
            if(convertMatToStrInDetails)
               tableAux_d=displayFullIntegers(tableAux_d);
            end
            disp(tableAux_d)
        end
    end

end

