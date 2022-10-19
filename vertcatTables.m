function newTable=vertcatTables(cellOfTables)

print=true;
[commonVars,notCommonVars]=getCommonVars(cellOfTables);

C=numel(cellOfTables);
for c=1:C
cellOfTables{c}=cellOfTables{c}(:,commonVars);
end
newTable=vertcat(cellOfTables{:});

if(print)
fprintf('These variables are not accross all tables: \n')
fprintf('\t%s\n',notCommonVars{:})
fprintf('\n')
end