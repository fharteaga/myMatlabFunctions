function sqlInsertFromTable(tablas,output)

if(~iscell(tablas))
    tablas={tablas};
end

fileID = fopen(output,'w');

for t=1:length(tablas)
    tabla=tablas{t};
    nameTabla=tabla.Properties.Description;
    assert(not(isempty(nameTabla)))
    
    fprintf(fileID,'\ndelete from %s;\n\n',nameTabla);
    varNames=tabla.Properties.VariableNames;
    varNames_aux=sprintf('%s,',varNames{:});
    varNames_aux=varNames_aux(1:end-1);
    cellI=repmat({'%i'},length(varNames),1);
    i_aux=sprintf('%s,',cellI{:});
    i_aux=i_aux(1:end-1);
    
    query=sprintf('\nINSERT INTO %s (%s) VALUES (%s);',nameTabla,varNames_aux,i_aux);
    data=table2array(tabla);    
   
        
        for i=1:size(data,1)
            fprintf(fileID,query,data(i,:));
        end
    
    fprintf(fileID,'\n\n');
end

fclose(fileID);


