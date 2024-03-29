function tabflow(leftvar,rightvar,varargin)

% leftvar can be a table, then rightvar must be a set of two chars that
% represent variables of the table

withWeights=false;
weights=[]; % Weights must be frequency weights (i.e. integers)
invertYAxis=true;
includeMissing=true;
leftVarLabel='varL';
rightVarLabel='varR';
precisionCondPerc='%2.2f';
withCondN=true;
minPercToPlot=0.05;
maxLabelLengthFromDescription=20;

    if(istable(leftvar))
        dataAux=leftvar;
        vars=rightvar;

        % check if there is a cell inside the cell, and combine them!
        assert(length(vars)==2)
        if(iscell(vars{1}))
            newVarName='combinedVarL';
               dataAux=combineDiscreteVars(dataAux,vars{1},'varNameCombined',newVarName);
               vars{1}=newVarName;
        end
        if(iscell(vars{2}))
            newVarName='combinedVarR';
            dataAux=combineDiscreteVars(dataAux,vars{2},'varNameCombined',newVarName);
            vars{2}=newVarName;
        end

        assert(all(cellfun(@ischar,vars)))
        

        labels=cell(2,1);
        for v=1:length(vars)
            if(~isempty(dataAux.Properties.VariableDescriptions))

           
      labels{v}=dataAux.Properties.VariableDescriptions{vars{v}};
            end
      
            if(isempty(labels{v})||length(labels{v})>maxLabelLengthFromDescription)
                labels{v}=vars{v};
            end
            leftVarLabel = labels{1};
            rightVarLabel = labels{2};
            leftvar=dataAux.(vars{1});
            rightvar=dataAux.(vars{2});
        end
    end

if(~isempty(varargin))
    varargin=checkVarargin(varargin);
    % Loading optional arguments
    while ~isempty(varargin)
        switch lower(varargin{1})
            case {'weights','w'}
                weights= varargin{2};
                withWeights=true;
            case {'invertyaxis'}
                invertYAxis= varargin{2};
            case {'leftvarlabel','lvl'}
                leftVarLabel = varargin{2};
            case {'rightvarlabel','rvl'}
                rightVarLabel = varargin{2};
            case {'labels'}
                leftVarLabel = varargin{2}{1};
                rightVarLabel = varargin{2}{2};
            case {'includemissing','im','m'}
                includeMissing=varargin{2};
            case {'ommitnan'}
                includeMissing=varargin{2};
            case {'precisioncondperc'}
                precisionCondPerc= varargin{2};
            case {'minperctoplot'}
                minPercToPlot= varargin{2};
            otherwise
                error(['Unexpected option: ' varargin{1}])
        end
        varargin(1:2) = [];
    end
end


if(withWeights)
    assert(all(weights-floor(weights)==0),'Weights must be frequency weights (i.e. integers)')
    leftvar=repelem(leftvar,weights);
    rightvar=repelem(rightvar,weights);
end



% Deal with missing (cross tab does not count missings, but categories of
% departure (arrival) includes all the non-missing values of leftvar
% (rightvar). So might exist rows (columns)-> I start (finish), but never
% finish (start).

if(includeMissing)
    % I create a missing that is not missing for matlab:
    missingLeft=ismissing(leftvar);
    missingRight=ismissing(rightvar);
    
    if(any(missingLeft))
        % Los paso a categorical, no idea como hacerlo de otra forma
        
        leftvar=categorical(leftvar);
        cats=categories(leftvar);
        assert(not(ismember('Missing',cats)))
        
        
        % Add Missing category as last category
        leftvar=addcats(leftvar,'Missing','after',cats{end});
        leftvar(missingLeft) = 'Missing';
        
    end
    if(any(missingRight))
        % Los paso a categorical, no idea como hacerlo de otra forma
        
        rightvar=categorical(rightvar);
        cats=categories(rightvar);
        assert(not(ismember('Missing',cats)))
        
        
        % Add Missing category as last category
        rightvar=addcats(rightvar,'Missing','after',cats{end});
        rightvar(missingRight) = 'Missing';
        
    end
end



[data,~,~,labels]=crosstab(leftvar,rightvar);


wInfoL=sum(data,2)>0;
wInfoR=sum(data,1)>0;

NLabel=sprintf('[ N=%s ]',mat2cellstr(length(leftvar),'rc',true));

ll=labels(not(cellfun(@isempty,labels(:,1))),1);
rl=labels(not(cellfun(@isempty,labels(:,2))),2);
ll=ll(wInfoL);
rl=rl(wInfoR);

alluvialflow(data(wInfoL,wInfoR),'ll',ll,'rl',rl,'invertYAxis',invertYAxis,'leftVarLabel',leftVarLabel,'rightVarLabel',rightVarLabel,'centerLabel',NLabel,'precisionCondPerc',precisionCondPerc,'withCondN',withCondN,'minPercToPlot',minPercToPlot);
