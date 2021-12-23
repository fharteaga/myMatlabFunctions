function resLog=readStataLog(log,idCommands)

assert(ischar(log))
assert(iscellstr(idCommands))
assert(any(size(idCommands)==1))

% Read each line of the log, stop is see beggining or end of command output


N=length(idCommands);
resLog=struct;

for i=1:N
    strIni=sprintf('__inicmd_id_%s_id__',idCommands{i});
    strEnd=sprintf('__endcmd_id_%s_id__',idCommands{i});
    pIni = strfind(log,strIni);
    pEnd= strfind(log,strEnd);
    
    assert(pIni>0&pEnd>0);
    resLog.(idCommands{i})=log(pIni+length(strIni)+1:pEnd-5);
    
end

