function [tipo,levelStrata]=stratifiedRand(tabla,varargin)

% "tabla" is a Table, and all the variables are using to create stratas.
% Vars in the table must be ordered in the level of granularity/importance
% of the strata. Less granular or more important stratas should go first.


stratVars=tabla.Properties.VariableNames;
numTreatsProvided=false;
relativeSizeProvided=false;

if(~isempty(varargin))
    
    % This checks a few things, including if there is a struct called "opts"
    varargin=checkVarargin(varargin);
    
    while ~isempty(varargin)
        switch lower(varargin{1})
            case {'numtreatments'}
                numTreats= varargin{2};
                numTreatsProvided= true;
            case {'relativesize'}
                relativeSize= varargin{2};
                relativeSizeProvided= true;
                
            otherwise
                error(['Unexpected option: ' varargin{1}])
        end
        varargin(1:2) = [];
    end
end

if(not(numTreatsProvided)&&not(relativeSizeProvided))
    numTreats=2;
    relativeSize=[1 1]/2;
elseif(numTreatsProvided&&not(relativeSizeProvided))
    relativeSize=ones(1,numTreats)/numTreats;
elseif(not(numTreatsProvided)&&relativeSizeProvided)
    numTreats=numel(relativeSize);
end




%% Minum size of strata
strataMinSize=nan;
for i=2:20
    mod_=mod(relativeSize*i,1);
    if(all(mod_<1e-14))
        strataMinSize=i;
        break
    end
end

assert(length(relativeSize)==numTreats);
assert(abs(sum(relativeSize)-1)<1e-14,'Sum of relative sizes must be 1')
assert(not(isnan(strataMinSize)))

assert(not(ismember('ones_SR',stratVars)))
assert(not(ismember('random_SR',stratVars)))
assert(not(ismember('tipo',stratVars)))
assert(not(ismember('orden_SR',stratVars)))
assert(not(ismember('ordenOrig_SR',stratVars)))

% Original sort:

tabla.ordenOrig_SR=(1:height(tabla))';
tabla.random_SR=rand(height(tabla),1);
tabla.ones_SR=ones(height(tabla),1);




%%

varsCollapse={'ones_SR'};
customFun=struct;
statsCollapse={'sum'};

for i=1:(numTreats-1)
    stat=sprintf('relsize%i',i);
    statsCollapse=[statsCollapse,{['c_',stat]}]; %#ok<AGROW>
    varsCollapse=[varsCollapse,{'random_SR'}]; %#ok<AGROW>
    customFun.(stat)=@(x)quantile(x,sum(relativeSize(1:i)));
end



% I sort according to random_SR because I want to clasify the misfits randomly:


%% Loop reducing the number of strata, generting different levels of misfits:

numStrata=length(stratVars);
tableToGetMisfits=tabla;
withTableTreat=false;
for s=1:numStrata
    
    tableToGetMisfits=sortrows(tableToGetMisfits,[stratVars(1:end-(s-1)),'random_SR']);
    tableToGetMisfits.orden_SR=(1:height(tableToGetMisfits))';

    tableToGetMisfits=stataCollapse(stratVars(1:end-(s-1)),tableToGetMisfits,{'orden_SR','ones_SR'},{'min','sum'},'mergewithoriginal',true);
    tableToGetMisfits.ordenWithinGroup=tableToGetMisfits.orden_SR-tableToGetMisfits.orden_SR_min+1;
    
    % Clasify misfits:
    tableToGetMisfits.isMisfit=tableToGetMisfits.ordenWithinGroup<=mod(tableToGetMisfits.ones_SR_sum,strataMinSize);
    tableToGetMisfits.ones_SR_sum=[];
    tableToGetMisfits.orden_SR_min=[];
    tableToGetMisfits.ordenWithinGroup=[];
    
    % Assing treatment in each stratum that is NOT misfits 
    tablaNoMisfit=tableToGetMisfits(not(tableToGetMisfits.isMisfit),:);
    
    if(height(tablaNoMisfit)>0)
        tablaNoMisfit=stataCollapse(stratVars(1:end-(s-1)),tablaNoMisfit,varsCollapse,statsCollapse,'mergewithoriginal',true,'customfun',customFun);
        tablaNoMisfit.tipo=ones(height(tablaNoMisfit),1);
        
        for i=1:(numTreats-1)
            stat=sprintf('c_relsize%i',i);
            tablaNoMisfit.tipo=tablaNoMisfit.tipo+double(tablaNoMisfit.random_SR>tablaNoMisfit.(['random_SR_',stat]));
        end
      
        
        tablaNoMisfit.levelStrata=ones(height(tablaNoMisfit),1)*(numStrata-s+1);
        if(withTableTreat)
            treatWithinStrata=[treatWithinStrata;tablaNoMisfit(:,{'ordenOrig_SR','tipo','levelStrata'})]; %#ok<AGROW>
        else
            treatWithinStrata=tablaNoMisfit(:,{'ordenOrig_SR','tipo','levelStrata'});
            withTableTreat=true;
            
        end
    end
    tablaMisfit=tableToGetMisfits(tableToGetMisfits.isMisfit,:);
    if(s<numStrata)
        tableToGetMisfits=tablaMisfit;
        tableToGetMisfits.isMisfit=[];
    end

    % Chequear que esto está correcto:
    if(height(tableToGetMisfits)==0)
        break
    end
end


% Now, I assign treatment to realmisfits:
if(height(tablaMisfit)>0)
    tablaMisfit.tipo=ones(height(tablaMisfit),1);
    
    for i=1:(numTreats-1)
        stat=sprintf('relsize%i',i);
        tablaMisfit.tipo=tablaMisfit.tipo+double(tablaMisfit.random_SR>customFun.(stat)(tablaMisfit.random_SR));
    end
    tablaMisfit.levelStrata=zeros(height(tablaMisfit),1);
    if(withTableTreat)
        treatWithinStrata=[treatWithinStrata;tablaMisfit(:,{'ordenOrig_SR','tipo','levelStrata'})]; %#ok<AGROW>
    else
        treatWithinStrata=tablaMisfit(:,{'ordenOrig_SR','tipo','levelStrata'});
    end
end



treatWithinStrata=sortrows(treatWithinStrata,'ordenOrig_SR');
tabla=sortrows(tabla,'ordenOrig_SR');

assert(all(treatWithinStrata.ordenOrig_SR==tabla.ordenOrig_SR))


tipo=treatWithinStrata.tipo;
levelStrata=treatWithinStrata.levelStrata;
tab(levelStrata)

% Tabs
preX=categorical(tipo);
catX=categories(preX)';
X=dummyvar(preX);

for s=1:numStrata
    %figure
    %tabflow(tabla{:,s},tipo)
    st=removecats(categorical(tabla{:,s}));
    v=tabla.Properties.VariableNames{s};
    cats=categories(st);
    for c=1:(length(cats)-1)
        %res=fitlm(X(:,1:(end-1)),double(st==cats{c}),'Intercept',true,'VarNames',[cellfun(@(x)['tipo==',x],catX(1:end-1),'UniformOutput',false),[v,'==',cats{c}]]);
       % display(res)
    end
 
end
