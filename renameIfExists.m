function tablaOrStruct=renameIfExists(tablaOrStruct,nameIn,nameOut)

if(~iscellstr(nameIn)) %#ok<ISCLSTR>
    if(ischar(nameIn))
        nameIn={nameIn};
        assert(ischar(nameOut))
        nameOut={nameOut};
    elseif(isstring(nameIn))
        nameIn=cellstr(nameIn);
        nameOut=cellstr(nameOut);
    end
end

assert(length(nameIn)==length(nameOut))

if(istable(tablaOrStruct))
    inTable=ismember(nameIn,tablaOrStruct.Properties.VariableNames);

    if(numel(inTable)==1)
        if(inTable)
            tablaOrStruct=renamevars(tablaOrStruct,nameIn,nameOut);
        end

    elseif(any(inTable))
        assert(numel(nameIn)==numel(nameOut))
        tablaOrStruct=renamevars(tablaOrStruct,nameIn(inTable),nameOut(inTable));

    end

elseif(isstruct(tablaOrStruct))

    for n=1:length(nameIn)
        tablaOrStruct=renameStructField(tablaOrStruct,nameIn{n},nameOut{n});
    end
else
    error('aca')
end