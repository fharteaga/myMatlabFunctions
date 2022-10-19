function tabla=renameIfExists(tabla,nameIn,nameOut)

inTable=ismember(nameIn,tabla.Properties.VariableNames);

if(numel(inTable)==1)
    if(inTable)
        tabla=renamevars(tabla,nameIn,nameOut);
    end

elseif(any(inTable))
    assert(numel(nameIn)==numel(nameOut))
    tabla=renamevars(tabla,nameIn(inTable),nameOut(inTable));

end