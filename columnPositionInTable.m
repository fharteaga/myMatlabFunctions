function pos=columnPositionInTable(table)
varNames=table.Properties.VariableNames;
pos=struct;
for i=1:length(varNames)
    pos.(varNames{i})=i;
end