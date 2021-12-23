function result=readEReturn(fileResStata)

res=readtable(fileResStata);
delete(fileResStata)
ids=unique(res.id);

result=struct;

rowMatrices=endsWith(res.var,{'_NRows'});
for i=1:length(ids)
    res_i=struct;
    sirven=strcmp(res.id,ids{i});
    
    % Scalars
    pos=find(sirven&res.isScalar);
    for j=1:length(pos)
        res_i.(res.var{pos(j)})=res.scalar(pos(j));
    end
    
    % Macros (strings)
    pos=find(sirven&res.isMacro);
    for j=1:length(pos)
        res_i.(res.var{pos(j)})=res.macro{pos(j)};
    end
    
    % Matrics
    pos=find(sirven&rowMatrices);
    
    for j=1:length(pos)
        var=res.var{pos(j)};
        var=var(1:end-6); % Saca "_NRows"
        
        rowN=res.matrix(pos(j));
        colN=res.matrix(sirven&strcmp(res.var,{[var,'_NCols']}));
        matAux=nan(rowN,colN);
        for r=1:rowN
            for c=1:colN
                matAux(r,c)=res.matrix(sirven&strcmp(res.var,sprintf('%s_[%i][%i]',var,r,c)));
            end
        end
        % Si empieza con "_" lo saca
        if(var(1)=='_')
            var=[var(2:end),'_']; % Add "_" at the end because might be another variable that exist without the "_" (Ex: _N, N exist as a scalar!)
        end
        res_i.(var)=matAux;
        %assert(rowN==1)
        
        
    end
    result.(ids{i})=res_i;
end