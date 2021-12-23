function vector=scalarForTable(scalar,table)

if(ischar(scalar))
    scalar={scalar};
end
assert(numel(scalar)==1);
assert(istable(table))
vector=repmat(scalar,height(table),1);


