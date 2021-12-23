function [varCollapsed,idVarCollapsed]=stataCollapseArray(idVar,array,wichstats,varargin)

assert(issorted(idVar),'idVar must be sorted')
N=size(idVar,1);
assert(size(idVar,2)==1,'idVar must be a one column vector')

assert(N==size(array,1),'idVar must be the same length as the array')

assert(all(not(ismissing(idVar))),'idVar cannot contain missing values')

assert(isnumeric(idVar)); % Comparar strings o categoricales es lento. Mejor convierte el IDVAR al principio.

idVarCollapsed=unique(idVar);
cantVars=size(array,2);
varCollapsed=nan(size(idVarCollapsed,1),cantVars);





%% Capabilities so far:
%sum
%prod
%min
%max
%mean
%quantile

if(ischar(wichstats)||length(wichstats)==1)
    if(not(iscellstr(wichstats)))
        wichstats={wichstats};
    end
    wichstats=repmat(wichstats,cantVars,1);
else
    assert(iscellstr(wichstats)&&length(wichstats)==cantVars,'Number of stats must be the same than the number of vars')
end



sumStat=false(cantVars,1);
nansumStat=false(cantVars,1);
prodStat=false(cantVars,1);
minStat=false(cantVars,1);
maxStat=false(cantVars,1);
meanStat=false(cantVars,1);
nanmeanStat=false(cantVars,1);
lastStat=false(cantVars,1);
firstStat=false(cantVars,1);
secondStat=false(cantVars,1);
thirdStat=false(cantVars,1);
quantileStat=false(cantVars,1);
customStat=false(cantVars,1);
customFun=cell(cantVars,1);
quantileNumber=nan(cantVars,1);
sdStat=false(cantVars,1);
countStat=false(cantVars,1);
countnotnanStat=false(cantVars,1);
countnanStat=false(cantVars,1);
countuniqueStat=false(cantVars,1);
relativeSizeStat=false(cantVars,1);



value=zeros(cantVars,1);
valueAux=ones(cantVars,1); %for counting in the case of mean
counterAux=ones(cantVars,1); %for counting in the case of second or third
positions=nan(2,1); % for initial position and final position for the "special" stats
counterUnique=0;

anySpecial=false;

for c=1:cantVars
    currentStat=lower(wichstats{c});
    if(strcmp(currentStat(1),'q'))
        quantileNumberAux=str2double(currentStat(2:end));
        assert(not(isnan(quantileNumberAux))&&quantileNumberAux>0&&quantileNumberAux<1,'Quantile must be a number in the open interval (0,1), like q.01, q.5 or q.9999')
        currentStat='quantile';
        quantileNumber(c)=quantileNumberAux;
        
    elseif(strcmp(currentStat(1:2),'c_'))
        if(length(currentStat)==2)
            customFun{c}=varargin{1};
        else
            currentStatOrig=wichstats{c}; % No lowercase
            customFun{c}=varargin{1}.(currentStatOrig(3:end));
        end
        assert(isa(customFun{c},'function_handle'))
        currentStat='customfun';
    end
    
    switch currentStat
        case 'sum'
            sumStat(c)=true;
        case 'nansum'
            nansumStat(c)=true;
        case 'prod'
            prodStat(c)=true;
        case 'min'
            minStat(c)=true;
        case 'max'
            maxStat(c)=true;
        case 'mean'
            meanStat(c)=true;
        case 'nanmean'
            nanmeanStat(c)=true;
        case 'first'
            firstStat(c)=true;
        case 'last'
            lastStat(c)=true;
        case 'quantile'
            quantileStat(c)=true;
            anySpecial=true;
        case 'customfun'
            customStat(c)=true;
            anySpecial=true;
        case 'sd'
            sdStat(c)=true;
            anySpecial=true;
        case 'count'
            countStat(c)=true;
        case 'countnotnan'
            countnotnanStat(c)=true;
        case 'countnan'
            countnanStat(c)=true;
        case 'countunique'
            countuniqueStat(c)=true;
            anySpecial=true;
        case 'second'
            secondStat(c)=true;
        case 'third'
            thirdStat(c)=true;
        case 'relativesize'
            relativeSizeStat(c)=true;
            valueAux(c)=N;
        otherwise
            error('stat not valid')
    end
end




for i=1:N
    
    if(i==1)
        sameID=false;
        
    else
        
        sameID=idVar(i)==lastID;
        
    end
    
    % Reset the value var if id is differnet
    if(not(sameID))
        if(counterUnique>0)
            varCollapsed(counterUnique,:)=value./valueAux;
            if(anySpecial)
                for c=1:cantVars
                    if(quantileStat(c))
                        varCollapsed(counterUnique,c)=quantile(array(positions(1):positions(2),c),quantileNumber(c));
                    elseif(sdStat(c))
                        varCollapsed(counterUnique,c)=std(array(positions(1):positions(2),c));
                    elseif(countuniqueStat(c))
                        varCollapsed(counterUnique,c)=length(unique(array(positions(1):positions(2),c)))-sum(isnan(array(positions(1):positions(2),c)));
                    elseif(customStat(c))
                        varCollapsed(counterUnique,c)=customFun{c}(array(positions(1):positions(2),c));
                    end
                end
            end
        end
        if(anySpecial)
            positions(1)=i;
        end
        counterUnique=counterUnique+1;
        for c=1:cantVars
            if(sumStat(c)||countStat(c)||countnotnanStat(c)||relativeSizeStat(c)||countnanStat(c))
                value(c)=0;
            elseif(nansumStat(c)||nanmeanStat(c))
                value(c)=0;
                valueAux(c)=NaN;
            elseif(prodStat(c))
                value(c)=1;
            elseif(minStat(c))
                value(c)=inf;
            elseif(maxStat(c))
                value(c)=-inf;
            elseif(meanStat(c))
                value(c)=0;
                valueAux(c)=0;
            elseif(secondStat(c)||thirdStat(c))
                value(c)=nan;
                counterAux(c)=0;
            end
        end
    end
    
    
    
    for c=1:cantVars
        if(sumStat(c))
            value(c)=value(c)+array(i,c);
        elseif(meanStat(c))
            valueAux(c)=valueAux(c)+1;
            value(c)=value(c)+array(i,c);
        elseif(nansumStat(c))
            if(~isnan(array(i,c)));valueAux(c)=1;value(c)=value(c)+array(i,c);end
        elseif(prodStat(c))
            value(c)=value(c)*array(i,c);
        elseif(minStat(c))
            if(array(i,c)<value(c));value(c)=array(i,c);elseif(isnan(array(i,c)));value(c)=nan;end
        elseif(maxStat(c))
            if(array(i,c)>value(c));value(c)=array(i,c);elseif(isnan(array(i,c)));value(c)=nan;end
        elseif(nanmeanStat(c))
            if(~isnan(array(i,c))&&isnan(valueAux(c)));valueAux(c)=1;value(c)=value(c)+array(i,c);
            elseif(~isnan(array(i,c)));valueAux(c)=valueAux(c)+1;value(c)=value(c)+array(i,c);end
        elseif(firstStat(c)&&not(sameID))
            value(c)=array(i,c);
        elseif(lastStat(c))
            value(c)=array(i,c);
        elseif(countStat(c))
            value(c)=value(c)+1;
        elseif(countnotnanStat(c))
            value(c)=value(c)+~isnan(array(i,c));
        elseif(countnanStat(c))
            value(c)=value(c)+isnan(array(i,c));
        elseif(secondStat(c))
            counterAux(c)=counterAux(c)+1;
            if(counterAux(c)==2)
                value(c)=array(i,c);
            end
        elseif(thirdStat(c))
            counterAux(c)=counterAux(c)+1;
            if(counterAux(c)==3)
                value(c)=array(i,c);
            end
        elseif(relativeSizeStat(c))
            value(c)=value(c)+1;
        end
    end
    
    if(anySpecial)
        positions(2)=i;
    end
    
    lastID=idVar(i);
    
end

assert(counterUnique==size(varCollapsed,1));
varCollapsed(counterUnique,:)=value./valueAux;
if(anySpecial)
    for c=1:cantVars
        if(quantileStat(c))
            varCollapsed(counterUnique,c)=quantile(array(positions(1):positions(2),c),quantileNumber(c));
        elseif(sdStat(c))
            varCollapsed(counterUnique,c)=std(array(positions(1):positions(2),c));
        elseif(customStat(c))
            varCollapsed(counterUnique,c)=customFun{c}(array(positions(1):positions(2),c));
        elseif(countuniqueStat(c))
            varCollapsed(counterUnique,c)=length(unique(array(positions(1):positions(2),c)))-sum(isnan(array(positions(1):positions(2),c)));
        end
    end
end



