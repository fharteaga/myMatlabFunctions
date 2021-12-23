function table2vars(data)
assert(istable(data))
nombresVar=data.Properties.VariableNames;
        for j=1:length(nombresVar)    
            assignin('base',regexprep(nombresVar{j},' ',''),data.(nombresVar{j}));
        end
       
