function sizeOfTableVars(tablaOrStruct)

if(istable(tablaOrStruct))
    isTable=true;
vars=tablaOrStruct.Properties.VariableNames;
nameObj='TABLE';
elseif(isstruct(tablaOrStruct))
    isTable=false;
vars=fieldnames(tablaOrStruct);
nameObj='STRUCT';
end
fprintf(newline)

fprintf('[Nº]    \t| SIZE      | VARIABLE NAME    \n-------------------------------------------\n')
for i=1:length(vars)
    if(isTable)
        a=tablaOrStruct(:,i);
        classVar=class(a{:,1});
    else
        a=tablaOrStruct.(vars{i});
        classVar=class(a);
    end
    b=whos('a');
    fprintf('[%2i]%s\t| %6s mb | %s \n',i,classVar,mat2cellstr(round(b.bytes/1e6),'rc',1),vars{i})

end
b=whos('tablaOrStruct');
fprintf('-------------------------------------------\n[**] %s\t| %6s mb   \n',nameObj,mat2cellstr(round(b.bytes/1e6),'rc',1))
fprintf(newline)