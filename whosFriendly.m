
whosFriendly_local(whos)

function whosFriendly_local(varsFromWhos)

fprintf(newline)
cumSizeMB=0;
fprintf('[Nº]    \t| SIZE      | VARIABLE NAME    \n-------------------------------------------\n')
for i=1:length(varsFromWhos)
    b=varsFromWhos(i);
    sizeVarMB=b.bytes/1e6;
    cumSizeMB=cumSizeMB+sizeVarMB;
    classV=b.class;
    if(strcmpi(classV,'categorical')); classV='categoric.';end


    fprintf('[%3i]%s\t| %6s mb | %s \n',i,classV,mat2cellstr(round(sizeVarMB),'rc',1),b.name)

end

fprintf('-------------------------------------------\n[**] %s\t| %6s mb   \n','TOTAL',mat2cellstr(round(cumSizeMB),'rc',1))

fprintf(newline)
end