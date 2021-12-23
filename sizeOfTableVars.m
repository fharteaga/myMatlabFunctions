function sizeOfTableVars(tabla)

vars=tabla.Properties.VariableNames;

for i=1:length(vars)
    a=tabla(:,i);
    b=whos('a');
    fprintf(' Col %2i Size %5i mb  %s\n',i,round(b.bytes/1e6),vars{i})
end