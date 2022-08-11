function sizeOfTableVars(tabla)

vars=tabla.Properties.VariableNames;

fprintf(newline)

fprintf('[Nº]    \t| SIZE      | VARIABLE NAME    \n-------------------------------------------\n')
for i=1:length(vars)
    a=tabla(:,i);
    b=whos('a');
    fprintf('[%2i]%s\t| %6s mb | %s \n',i,class(a{:,1}),mat2cellstr(round(b.bytes/1e6),'rc',1),vars{i})

end
b=whos('tabla');
fprintf('-------------------------------------------\n[**] %s\t| %6s mb   \n','TABLE',mat2cellstr(round(b.bytes/1e6),'rc',1))
fprintf(newline)