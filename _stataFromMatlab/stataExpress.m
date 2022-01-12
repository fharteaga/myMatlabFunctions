function stataExpress(code,data)
% Este agarra todas las variables del dataset que sean mencionadas en code,
% y corre el code con el dataset.

if(iscellstr(code)) %#ok<ISCLSTR>

    code=sprintf('%s\n',code{:});
end
assert(ischar(code))



if(nargin==1)
    data=table;
else
    vars=data.Properties.VariableNames;
    nVars=size(data,2);
    relevantVar=false(nVars,1);
    for i=1:nVars
        relevantVar(i)=contains(code, vars{i});
    end
    data=data(:,relevantVar);
end

showPlot=contains(code,{'plot ','rdplot ','scatter ','histogram ','hist ','binsreg ','binscatter '});

if(showPlot)
    paths=pathsStata();
    filePlot=[paths.stataTempfilesPath,'tempPlot.png'];
    code=sprintf('%s\n graph export "%s", replace',code,filePlot);
end


res=runStata(code,data,'getLog',true,'addprecode',false);

log=res.log;
posCommand=regexp(log,code(1:min(length(code),5)));
posEnd=regexp(log,'end of do-file');
cprintf('*[0.0742,0.3711,0.5625]','----- INI LOG STATA ----')
cprintf('[0.0742,0.3711,0.5625]','\n\n%s',log(max(posCommand(1)-2,1):posEnd-4));
cprintf('*[0.0742,0.3711,0.5625]','----- END LOG STATA ----\n')



if(showPlot)
    I = imread(filePlot);
    imshow(I);
    delete(filePlot);
end