function [cellTable,headers]=table2cellstr(tabla)

vars=tabla.Properties.VariableNames;
headers=tabla.Properties.VariableDescriptions;
if(isempty(headers))
    headers=vars;

else
    anyEmpty=cellfun(@isempty,headers);
    if(any(anyEmpty))
        headers(anyEmpty)=vars(anyEmpty);
    end
end

cellTable=cell(size(tabla));

for v=1:length(vars)

    var=tabla.(vars{v});
    if(isnumeric(var))

        var=mat2cellstr(var);
    elseif(iscategorical(var)||isstring(var))

        var=cellstr(var);
    elseif(iscellstr(var))
        % Do nothing
    else
        error('aca!')
    end

    cellTable(:,v)=var;
end