function [varCollapsed,idVarCollapsed,varCollapsed_cell,posMinMax]=stataCollapseArray(idVar,array,wichstats,customFunInput,array_cell,whichstats_cell)

% customFunInput must be a function handle if stat "c_" is in whichstats
% customFunInput must be a struct if stata "c_nameCustomFun" is in whichstats,
% and also nameCustomFun must the field name of a function handle.
% customFunInput fun could be whatever if non of the stats start with c_

% quantile: Quantile must be q + a number in the open interval (0,1), like q.01, q.5 or q.9999'

% position: like pos1, pos21, or pos1last, pos2last. 

assert(issorted(idVar),'idVar must be sorted')
N=size(idVar,1);
assert(size(idVar,2)==1,'idVar must be a one column vector')
assert(all(not(ismissing(idVar))),'idVar cannot contain missing values')
assert(isnumeric(idVar)); % Comparar strings o categoricales es lento. Mejor convierte el IDVAR al principio.


if(isempty(array)) % Esto es cuando solo quiero sacar min y max pos
    assert(isempty(wichstats))   
else
    assert(N==size(array,1),'idVar must be the same length as the array')
end


idVarCollapsed=unique(idVar);

cantVars=size(array,2);
varCollapsed=nan(size(idVarCollapsed,1),cantVars);

cantVars_cell=size(array_cell,2);
varCollapsed_cell=cell(size(idVarCollapsed,1),cantVars_cell);


if(nargout>3)
    returnPositions=true;
    posMinMax=nan(size(idVarCollapsed,1),2);
else
    returnPositions=false;
    posMinMax=nan;
end



if(ischar(wichstats)||length(wichstats)==1)
    if(not(iscellstr(wichstats)))
        wichstats={wichstats};
    end
    wichstats=repmat(wichstats,cantVars,1);
else
    assert(iscellstr(wichstats)&&length(wichstats)==cantVars,'Number of stats must be the same than the number of vars')
end


funC=cell(cantVars,1);
funC_cell=cell(cantVars_cell,1);

for c=1:cantVars
    currentStat=lower(wichstats{c});
    
    % QUANTILES:
    if(strcmp(currentStat(1),'q'))
        quantileNumberAux=str2double(currentStat(2:end));
        assert(not(isnan(quantileNumberAux))&&quantileNumberAux>0&&quantileNumberAux<1,'Quantile must be a number in the open interval (0,1), like q.01, q.5 or q.9999')
        funC{c}=@(x)quantile(x,quantileNumberAux);
    
        % CUSTOM FUNCTION:
    elseif(strcmp(currentStat(1:2),'c_'))
        if(length(currentStat)==2)
            customFun=customFunInput;
        else
            currentStatOrig=wichstats{c}; % No lowercase
            customFun=customFunInput.(currentStatOrig(3:end));
        end
        assert(isa(customFun,'function_handle'))
        funC{c}=customFun;
        
        % POSITION:
    elseif(strcmp(currentStat(1:2),'po'))
        assert(length(currentStat)>3&&all(currentStat(1:3)=='pos'))
        if(all(currentStat(end-3:end)=='last'))
            posAux=-str2double(currentStat(4:end-4));
            assert(not(isnan(posAux))&&(posAux<=1),'Position has to  >=1, like pos1last, pos2last')
        else
            posAux=str2double(currentStat(4:end));
            assert(not(isnan(posAux))&&(posAux>=1),'Position has to  >=1, like pos1, pos21 ')
        end
        
        funC{c}=@(x)getValueInPos(x,posAux,true);
        
        % NORMAL FUNCTIONS:
    else
        switch currentStat
            case 'sum'
                funC{c}=@sum;
            case 'nansum'
                funC{c}=@(x)sum(x,'omitnan');
            case 'prod'
                funC{c}=@prod;
            case 'min'
                funC{c}=@min;
            case 'max'
                funC{c}=@max;
            case 'mean'
                funC{c}=@mean;
            case 'nanmean'
                funC{c}=@(x)mean(x,'omitnan');
            case 'first'
                funC{c}=@(x)getValueInPos(x,1,true);
            case 'last'
                funC{c}=@(x)getValueInPos(x,-1,true);
            case 'sd'
                funC{c}=@std;
            case 'nansd'
                funC{c}=@(x)std(x,'omitnan');
            case 'count'
                funC{c}=@length;
            case 'countnotnan'
                funC{c}=@(x)sum(not(isnan(x)));
            case 'countnan'
                funC{c}=@(x)sum(isnan(x));
            case 'countunique'
                funC{c}=@(x)length(unique(x))-sum(isnan(x));
            case 'second'
                funC{c}=@(x)getValueInPos(x,2,true);
            case 'third'
                funC{c}=@(x)getValueInPos(x,3,true);
            otherwise
                error('stat not valid for numeric input')
        end
    end
end


% FUNCTION THAT APPLY ONLY TO STRINGS!
for c=1:cantVars_cell
    currentStat=lower(whichstats_cell{c});
        
        % POSITION:
    if(strcmp(currentStat(1:2),'po'))
        assert(length(currentStat)>3&&all(currentStat(1:3)=='pos'))
        if(all(currentStat(end-3:end)=='last'))
            posAux=-str2double(currentStat(4:end-4));
            assert(not(isnan(posAux))&&(posAux<=1),'Position has to  >=1, like pos1last, pos2last')
        else
            posAux=str2double(currentStat(4:end));
            assert(not(isnan(posAux))&&(posAux>=1),'Position has to  >=1, like pos1, pos21 ')
        end
        
        funC_cell{c}=@(x)getValueInPos(x,posAux,false);
        
        % NORMAL FUNCTIONS:
    else
        switch currentStat
           
            case 'first'
                funC_cell{c}=@(x)getValueInPos(x,1,false);
            case 'last'
                funC_cell{c}=@(x)getValueInPos(x,-1,false);
            case 'count'
                funC_cell{c}=@length;
            case 'second'
                funC_cell{c}=@(x)getValueInPos(x,2,false);
            case 'third'
                funC_cell{c}=@(x)getValueInPos(x,3,false);
            otherwise
                error('stat not valid for CELL input')
        end
    end
end


positions=ones(2,1);
counterUnique=1;

for i=2:N
    
    % Calculate stat if ID changes:
    if(idVar(i)~=idVar(i-1))
        
        for c=1:cantVars
            varCollapsed(counterUnique,c)=funC{c}(array(positions(1):positions(2),c));
        end
        for c=1:cantVars_cell
            varCollapsed_cell(counterUnique,c)=funC_cell{c}(array_cell(positions(1):positions(2),c));
        end
        if(returnPositions)
            posMinMax(counterUnique,:)=positions;
        end
        positions(1)=i;
        counterUnique=counterUnique+1;
    end
    
    positions(2)=i;
end



for c=1:cantVars
    varCollapsed(counterUnique,c)=funC{c}(array(positions(1):positions(2),c));
end

for c=1:cantVars_cell
    varCollapsed_cell(counterUnique,c)=funC_cell{c}(array_cell(positions(1):positions(2),c));
end
if(returnPositions)
    posMinMax(counterUnique,:)=positions;
end

assert(counterUnique==size(varCollapsed,1));

assert(positions(2)==N);

end


function value=getValueInPos(miniArray,pos,numericV)
lengthArray=length(miniArray);
if(lengthArray>=abs(pos)&&not(pos==0))
    if(pos>0)
        value=miniArray(pos);
    elseif(pos<0)
        value=miniArray(lengthArray+pos+1);
    end
else
    if(numericV)
        value=nan;
    else
        value={};
    end
end
end


