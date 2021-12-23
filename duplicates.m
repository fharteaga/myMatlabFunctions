function dup=duplicates(tableIn)

% To do: deal with missing

if(istable(tableIn))
    
    vars=tableIn.Properties.VariableNames;
    assert(not(ismember('ones_d_',vars)))
    assert(not(ismember('order_d_',vars)))
    
    
else
    
    assert(size(tableIn,2)==1)
    var=tableIn;
    tableIn=table;
    tableIn.var=var;
    vars='var';
end

%assert(not(ismember('dup',tableIn.Properties.VariableNames)),'Already a variable called "dup"')

assert(nargin==1);

tableIn.ones_d_=ones(height(tableIn),1);
tableIn.order_d_=(1:height(tableIn))';
tableIn=sortrows(tableIn,vars);

% Check if there are missings: missings are counts are "the same"
for v=1:length(vars)
    var=tableIn{:,v};
    miss=ismissing(var);
    if(any(miss))
    warning('Variable %s has %i missing values (%.1f%%)',vars{v},sum(miss),100*mean(miss))
    
    if(isnumeric(var))
       var(miss)=max(var)+2;
    elseif(iscategorical(var))
        var=addcats(var,'___missing___');
         var(miss)='___missing___';
    elseif(iscellstr(var)) %#ok<ISCLSTR>
         var(miss)={'___missing___'};
    else
        error('aca')
        
    end
    tableIn{:,v}=var;
    end
end

tableIn=stataCollapse(vars,tableIn,'ones_d_','sum','mergewithoriginal',true);
tableIn=sortrows(tableIn,'order_d_');
%tableIn.Properties.VariableNames{'ones_d__sum'}='dup';
%tableIn.ones_d_=[];
%tableIn.order_d_=[];

dup=tableIn.ones_d__sum;


