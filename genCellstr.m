function genCellstr(input)

if(istable(input))
    cell=input.Properties.VariableNames;
else
    assert(iscellstr(input));
    cell=input;
end

a='';
a=sprintf('%s{',a);
for i=1:(length(cell)-1)
    a=sprintf('%s''%s'',',a,cell{i});
end
a=sprintf('%s''%s''}',a,cell{end});
showShorcut(a);
