function br=barmean(tabla,nameVarX,nameVarY,varargin)

horz=false;
colorPerc=1*[1 1 1];
minPercentageToShow=.1; % Percentage relative to the highest bar.
includeAll=true;
alphaTest=0.05;
testDifferencesInMean=true;
plotPValDifferences=true;
plotSEMean=true;
plotEmptyBox=false;
heightEmptyBox=1;
minPValForPlottingDifference=0.05;
colors=linspecer(2);
colorSE=colors(2,:);
colorBar=colors(1,:);
colorDiffBars=.3*[1 1 1];
dummyPrecision='%3.1f$\\%%$';
english=true;

if(~isempty(varargin))
    
    % This checks a few things, including if there is a struct called "opts"
    varargin=checkVarargin(varargin);
    % Loading optional arguments
    while ~isempty(varargin)
        switch lower(varargin{1})
            case 'horizontal'
                horz = varargin{2};
            case {'includeall','all'}
                includeAll = varargin{2};
            case {'minpercentagetoshow','mps'}
                minPercentageToShow = varargin{2};
            case {'plotpvaldifferences','pdiff'}
                plotPValDifferences = varargin{2};
            case {'plotsemean','pse'}
                plotSEMean = varargin{2};
            case {'plotemptybox','pse'}
                plotEmptyBox = varargin{2};
            case {'testdifferencesinmean','tdiff'}
                testDifferencesInMean = varargin{2};
                case {'minpvalforplottingdifference'}
                minPValForPlottingDifference= varargin{2};
            case 'dummyprecision'
                dummyPrecision=varargin{2};
            case 'english'
                english=varargin{2};
            otherwise
                error(['Unexpected option: ' varargin{1}])
        end
        varargin(1:2) = [];
    end
end

% Check if there is more than one x:
if(iscellstr(nameVarX))

    if(length(nameVarX)==1)
        nameVarX=nameVarX{1};
    else
        [tabla,varNameCombined]=combineDiscreteVars(tabla,nameVarX);
        nameVarX=varNameCombined;
    end
end


assert(istable(tabla))
assert(ischar(nameVarX))
assert(ischar(nameVarY))

if(not(testDifferencesInMean))
    plotPValDifferences=false;
end

if(english)
    allString='All';
else
    allString='Todos';
end

varY=tabla.(nameVarY);
varX=tabla.(nameVarX);




notMissY=not(ismissing(varY));
notMissX=not(ismissing(varX));

varY=varY(notMissY&notMissX);
varX=varX(notMissY&notMissX);

isDummy=all(varY==1|varY==0);
if(not(isDummy))
    medy=median(varY);
    if(medy<1)
        precision='%.2f';
    elseif(medy<10)
        precision='%.1f';
    elseif(medy<100)
        precision='%.1f';
    else
        precision='%.0f';
    end
    
end


% This is imporant for plotting and dummy creation
varX=categorical(varX);
% Remove any unused category
varX=removecats(varX);

% This is important: dummy var will create dummies in the same order as
% this guy:
xs=categories(varX);

cantXs=length(xs);
assert(cantXs<25,sprintf('Too many unique values for X variable %s',nameVarX));

% Dummies for each value of X:
xDummies=dummyvar(varX);

if(not(testDifferencesInMean))
    height=((xDummies'*xDummies)\xDummies'*double(varY));
    se=sqrt(diag(inv(xDummies'*xDummies)*var(double(varY)-xDummies*height))/(length(varY)-1)*length(varY)); %#ok<MINV>
    df=length(varY)-size(xDummies,2);
    
else
    reg=compact(fitlm(xDummies,double(varY),'Intercept',false));
    %disp(reg)
    height=reg.Coefficients.Estimate;
    se=reg.Coefficients.SE;
    df=reg.DFE;
    
    % Test H_0: \beta_{j}==\beta_{k}, \forall j,k \in \{1:cantXs\}, j\neq k
    pvalsEquality=nan(cantXs,cantXs);
    for j=1:(cantXs-1)
        for k=(j+1):cantXs
            H0=zeros(1,cantXs);
            H0(k)=1;
            H0(j)=-1;
            pvalsEquality(j,k)=coefTest(reg,H0);
        end
    end
    
    
    
    testTable=array2table(categorical(mat2cellstr(pvalsEquality,'decimalPrecision','%.3f','nanReplacement','-')),'RowNames',xs,'VariableNames',xs);
    fprintf('\nP-value H0 \\beta_{k}==\\beta_{j}:\n');
    disp(testTable(1:(end-1),2:end));
end

radioInterval=se*tinv((1-alphaTest/2),df);

if(includeAll)
    reg=compact(fitlm(ones(length(varY),1),double(varY),'Intercept',false));
    height(cantXs+1)=reg.Coefficients.Estimate;
    radioInterval(cantXs+1)=reg.Coefficients.SE*tinv((1-alphaTest/2),reg.DFE);
    xs=[xs;allString];
end




if(includeAll)
    xticksPos=1:(length(xs)-1);
    xticksPos=[xticksPos,max(xticksPos)+1.4];
else
    xticksPos=1:length(xs);
end

if(plotEmptyBox)

bar(xticksPos,ones(size(xticksPos))*heightEmptyBox, 'FaceColor','none','EdgeColor',.5*[1 1 1],'LineStyle','--','horizontal',horz);
hold on
end

bar(xticksPos,height, 'FaceColor',colorBar,'FaceAlpha',1,'edgeColor',[1 1 1],'horizontal',horz);
if(plotEmptyBox)
    hold off
end
if(plotSEMean)
hold on
errorbar(xticksPos,height,radioInterval,'lineStyle','none','color',colorSE)
hold off
end



minPercentageToShow=minPercentageToShow*max(abs(height));


for i=1:(cantXs+includeAll)
    
    if(abs(height(i))>minPercentageToShow)
        if(isDummy)
            annotation2('textbox',[xticksPos(i),height(i)/2],'o','String',sprintf(dummyPrecision,height(i)*100),'Interpreter','latex','edgecolor','none','color',colorPerc);
        else
            annotation2('textbox',[xticksPos(i),height(i)/2],'o','String',sprintf(precision,height(i)),'Interpreter','latex','edgecolor','none','color',colorPerc);
            
        end
    end
    
end

%% Add pval of H0 \beta_1==\beta_2
% if(cantXs==2)
%
%     annotation('textbox',[.55 .8 .1 .1],'String',['$H_0$: $\mu_1=\mu_2$ p-value: ',sprintf('%.3f',pvalsEquality(1,2))],'FitBoxToText','on','Interpreter','latex','edgecolor','none','color',.3*[1 1 1])
%
% end

%% Add differences
if(plotPValDifferences)
    
    plotDiffs=false(cantXs);
    
    %Plot horizontal
    
    for i=1:(cantXs-1)
        for j=(i+1):cantXs
            plotDiffs(i,j)=pvalsEquality(i,j)<=minPValForPlottingDifference;
        end
    end
    
    
    heightBar=.02*diff(ylim);
    anyOfLevel=false(cantXs-1,1);
    extra=0;
    horizontalSpaceUsed=zeros(1,cantXs);
    for l=1:cantXs-1
        
        for i=1:(cantXs-l)
            j=i+l;
            if(plotDiffs(i,j))
                horizontalSpaceUsed(i:j)=horizontalSpaceUsed(i:j)+1;
                if(any((horizontalSpaceUsed(1:end-1)>1)&(horizontalSpaceUsed(2:end)>1)))
                    extra=extra+1;
                    horizontalSpaceUsed=zeros(1,cantXs);
                    horizontalSpaceUsed(i:j)=horizontalSpaceUsed(i:j)+1;
                end
                text=sprintf('p: %.3f',pvalsEquality(i,j));
                
                anyOfLevel(l)=true;
                hold on
                %plotDiffBar(i,j,max(height+radioInterval)+3*heightBar+(5*(sum(anyOfLevel)+extra-1)*heightBar),heightBar,text,colorDiffBars)
                plotDiffBar(i,j,max(height+radioInterval)+3*heightBar+(5*(extra)*heightBar),heightBar,text,colorDiffBars)
                hold off
            end
            
        end
    end
    
    % Si no, al exportarlo el pvalue queda fuera del frame
    if(any(anyOfLevel)||plotEmptyBox)
        ylim(ylim+[0 .1*diff(ylim)])
    end
    
else
    if(plotEmptyBox)
        ylim(ylim+[0 .05*diff(ylim)])
    end

end


%% Other details


%legend(br,categorical(bart.value))
if(not(isempty(tabla.Properties.VariableDescriptions)))
    labelVarX=tabla.Properties.VariableDescriptions{nameVarX};
    if(isempty(labelVarX))
        labelVarX=nameVarX;
    end
    labelVarY=tabla.Properties.VariableDescriptions{nameVarY};
    if(isempty(labelVarY))
        labelVarY=nameVarY;
    end
else
    labelVarX=nameVarX;
    labelVarY=nameVarY;
end
if(horz)
    yticks(xticksPos)
    yticklabels(xs)
    
    ylabel(labelVarX)
    xlabel('Fraction')
    set(gca,'xTick',[]);
else
    xticks(xticksPos)
    xticklabels(xs)
    if(any(cellfun(@(x)length(x)>5,xs)))
        xtickangle(25)
    end
    
    
    xlabel(labelVarX)
    ylabel(['Mean of ',labelVarY])
    set(gca,'yTick',[]);
end

if(nargout>0)
    br=struct;
    br.height=height;
    br.radioInterval=radioInterval;
end
end
function plotDiffBar(x1,x2,y,alto,text,color)
plot([x1,x2],[y,y],'color',color)
plot([x1,x1],[y-alto,y],'color',color)
plot([x2,x2],[y-alto,y],'color',color)
annotation2('textbox',[mean([x1,x2]),y],'n','String',text);


end


