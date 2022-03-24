function sizeOfTableVars(tabla)

vars=tabla.Properties.VariableNames;

fprintf(newline)

fprintf('[Nº]    \t| SIZE     | VARIABLE NAME    \n-------------------------------------------\n')
for i=1:length(vars)
    a=tabla(:,i);
    b=whos('a');
    fprintf('[%2i]%s\t| %5i mb | %s \n',i,class(a{:,1}),round(b.bytes/1e6),vars{i})

end
b=whos('tabla');
fprintf('-------------------------------------------\n[**] %s\t| %5i mb   \n','TABLE',round(b.bytes/1e6))
fprintf(newline)