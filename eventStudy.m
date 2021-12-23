function [res,regInputTable,balanceMatrix]=eventStudy(input,varargin)

% For a better understanding of event studies (and what is identified) read
% Borusyak and Jaravel - 2016
% Sun and Abraham 2020

% Relevant take-away: fully dynamic event study (unit and time fixed effect
% plus relative time fixed effect are NOT identified)

% A control group can pin down the time effects, solving the issue. 


% I follow the recomendation of Borusyak and Jaravel - 2016, p22:
% "In a balanced sample, dropping the very frst and very last leads of the 
% treatment indicator is a sensible approach because it will reduce noise."

% Don't ever use the "static" or cannonical version. It can put negative
% weights in obs to the far right of the event time. Not trivial.




% Drops one cat of every saturated control variable
% Drops first calendar dummy
% Includes constant

% "Balance Matrix" is a N x [max(treatDist),min(treatDist)] that shows the
% balance of observations


calendarTime='calTime';
eventTime='eventTime';
id='id';
ignoreRelativeTime=-1;
ignoreOthersVars=cell(0,1);
yVar='y';
ignoreMissing=false;
controlCat=cell(0,1);
control=cell(0,1);

weights=ones(height(input),1);
withWeights=false;

exportInput=false;
fileToExportInput='';

if(~isempty(varargin))
   varargin=checkVarargin(varargin);
    % Loading optional arguments
    while ~isempty(varargin)
        switch lower(varargin{1})
            case {'yvar','y','outcome'}
                yVar = varargin{2};
            case {'id'}
                id = varargin{2};
            case {'calendartime','ct'}
                calendarTime = varargin{2};
            case {'eventtime','tt'}
                eventTime = varargin{2};
            case {'ignorerelativetime'}
                ignoreRelativeTime = varargin{2};
            case {'ignoreothersvars'}
                ignoreOthersVars = varargin{2};
            case {'ignoremissing','im'}
                ignoreMissing = varargin{2};
                            case {'control'} % Generates indiviudal dummies for (n-1) cats of each variable
                control = varargin{2};
            case {'controlcat'} % Generates indiviudal dummies for (n-1) cats of each variable
                controlCat = varargin{2};
            case {'weights','w'} % This could be a var of the table or a vector 
                weights = varargin{2};
                withWeights=true;
            case {'filetoexportinput'}
                exportInput = true;
                fileToExportInput=varargin{2};
            otherwise
                error(['Unexpected option: ',varargin{1}])
                
        end
        varargin(1:2) = [];
    end
end

if(ischar(controlCat))
    controlCat={controlCat};
end
if(ischar(control))
    control={control};
end

% Check if weight input is a var of the table or a vector 
if(withWeights)
    if(ischar(weights))
        weights=input.(weights);
    elseif(isnumeric(weights))
        assert(all(size(weights)==[height(input),1]))
        
    else
        error('Wrong weights')
    end
    
end

% Categorival is needed to get "names" for reg display, and to use
% "dummyvar" command, because it generates dummies for 1:max(var)

% Event dummies
relativeTime=input.(calendarTime)-input.(eventTime);
relativeTimeUnique=unique(relativeTime,'sorted');
relativeTime_cat=categorical(relativeTime,relativeTimeUnique,'ordinal',true);
relativeTimeDummy=dummyvar(relativeTime_cat);
catRTDs=categories(relativeTime_cat);
% Omit the first one -> I OMIT IT LATER
%relativeTimeDummy=relativeTimeDummy(:,2:end);
%catRTDs=catRTDs(2:end);


% (Relative time dummies are multicolinear with the two way fixed effect)
%  Solution: exclude a second event dummy, as in Sam and Abraham (2020). 
calendar_cat=categorical(input.(calendarTime),unique(input.(calendarTime),'sorted'),'ordinal',true);
timeDummy=dummyvar(calendar_cat);
catTDs=categories(calendar_cat);
timeDummy=timeDummy(:,2:end);
catTDs=catTDs(2:end);

% Unit dummies
uniqueIDs=unique(input.(id),'sorted');
id_cat=categorical(input.(id),uniqueIDs,'ordinal',true);
idDummy=dummyvar(id_cat);
catIdDs=categories(id_cat);
idDummy=idDummy(:,2:end);
catIdDs=catIdDs(2:end);

% Control dummies for CATEGORICAL control 
cDummy=[];
catsCDs={};

if(not(isempty(controlCat)))
    for c=1:length(controlCat)
        
        c_cat=categorical(input.(controlCat{c}),'ordinal',true);
        cDummy_aux=dummyvar(c_cat);
        cDummy=[cDummy,cDummy_aux(:,2:end)]; %#ok<AGROW>
        
        catCs_aux=categories(c_cat);
        catsCDs=[catsCDs;cellfun(@(x)[controlCat{c},x],catCs_aux(2:end),'uniformoutput',false)]; %#ok<AGROW>
        
    end
end

% Input for OLS
regInputTable=array2table([table2array(input(:,control)),idDummy,relativeTimeDummy,timeDummy,cDummy,input.(yVar)],'VariableNames',[reshape(control,1,[]),catIdDs',catRTDs',catTDs',catsCDs',{yVar}]);

% Ignore 2 event dummies (and other vars)

vars=regInputTable.Properties.VariableNames;

%(default is -1)
vars=vars(not(ismember(vars,categorical(ignoreRelativeTime))));

%(default 2 is the min)
ignoreRelativeTime2=min(relativeTime);
vars=vars(not(ismember(vars,categorical(ignoreRelativeTime2))));

% Other vars:
if(not(isempty(ignoreOthersVars)))
    vars=vars(not(ismember(vars,ignoreOthersVars)));
end


regInputTable=regInputTable(:,vars);
% Run OLS
res=fitlm(regInputTable,'intercept',true,'weights',weights);

% Check that is not dropping any var:
assert(res.NumCoefficients==res.NumEstimatedCoefficients)

res=res.Coefficients;
coeffToPlot=ismember(res.Row,catRTDs(not(ismember(catRTDs,categorical([ignoreRelativeTime ignoreRelativeTime2])))));
preX=cellfun(@str2num,res.Row(coeffToPlot));
preY=res.Estimate(coeffToPlot);

scatter([preX;ignoreRelativeTime;ignoreRelativeTime2],[preY;0;0])
hold on
errorbar(preX,preY,1.96*res.SE(coeffToPlot),'.')
plot(xlim,[0 0],'color',.5*[1 1 1],'linestyle','--');
set(gca,'ygrid','on')

%% Balance Matrix - To Do!

balanceMatrix=zeros(1,length(relativeTimeUnique));

%% Export dataset for regression (last var is depvar)
if(exportInput)
    % Change variables that Stata cant read
    vars=regInputTable.Properties.VariableNames;
    for v=1:length(vars)
        pos=regexp(vars{v},'[0-9]');
        if(ismember(1,pos))
            vars{v}=['_',vars{v}];
        end
        
        vars{v}=strrep(vars{v},'-','n');
       regInputTable.Properties.VariableNames{v}=vars{v}; 
    end
    writetable(regInputTable,fileToExportInput);
end


