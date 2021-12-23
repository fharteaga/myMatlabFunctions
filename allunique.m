function [areAllUnique,freq]=allunique(var)


if(istable(var))
    %% If table
    
    areAllUnique=height(var)==height(unique(var));
    
    if(nargout>1)
        
        ids=var.Properties.VariableNames;
        
        assert(not(ismember('ones_a_',ids)))
        assert(not(ismember('order_a_',ids)))
        
        
        var.ones_a_=ones(height(var),1);
        var.order_a_=(1:height(var))';
        var=sortrows(var,ids);
        var=stataCollapse(ids,var,'ones_a_','sum','mergewithoriginal',true);
        var=sortrows(var,'order_a_');
        freq=var.ones_a__sum;
        
    end
    
else 
    %% If matrix or cellstr
    assert(all(not(ismissing(var))),'Cannot check uniques of there are missings')
    
    if(sum(size(var)>1)>1)
        assert(nargout==1)
        var=reshape(var,numel(var),1);
    end
    areAllUnique=length(var)==length(unique(var));
    
    if(nargout>1)
        
        a=table;
        a.id=var;
        a.ones=ones(height(a),1);
        a.order=(1:height(a))';
        a=sortrows(a,'id');
        a=stataCollapse('id',a,'ones','sum','mergewithoriginal',true);
        a=sortrows(a,'order');
        freq=a.ones_sum;
        
    end
end