function [commonVars,notCommonVars]=getCommonVars(cellOfTables)


C=numel(cellOfTables);

commonVars=cellOfTables{1}.Properties.VariableNames;
allVars=cellOfTables{1}.Properties.VariableNames;

for c=2:C
    tabVars=cellOfTables{c}.Properties.VariableNames;
    commonVars=intersect(commonVars,tabVars);
    if(nargout>1)
        allVars=union(allVars,tabVars);
    end
end
if(nargout>1)
    notCommonVars=allVars(not(ismember(allVars,commonVars)));
end