function p=binsreg(x,y,varargin)
% BINSREG plot mean of y conditional on x
%   P = BINSREG(x,y,varargin) 
%   
%
%% Inputs:
%   x: (numeric) dep variable
%   y: (numeric) running variable variable
% 
%% Output:
%   p: (plot?) 
%
%% Optional inputs:
%   binStrategy ('quantile-spaced'): (text) defines how to construct the bins
%        'equally-spaced' 'saturated' 'quantile-spaced' 'custom'
%
%% Examples:
%  binsref(x,y)
%
%  See also PLOTRD
%
%   F. Arteaga (fharteaga 'at' gmail)

nBins=10;
markerSize=50;
removeNans=true;
binStrategy='quantile-spaced'; % 'equally-spaced' 'saturated' 'quantile-spaced' 'custom'
% 'binStrategy', 'equally-spaced'

if(not(isa(x,'double')))
    x=double(x);
end
if(not(isa(y,'double')))
    y=double(y);
end

withScatter=true;
withHistogram=false;
withErrorBars=false;
withLinearFit=false;
withQuantiles=false;
withIQRange=false;
quantileInf=.25;
quantileSup=.75;
modifyXTicks=true;



posCoeffFit=[.60 .80 .1 .1];
markerEdgeColor=linspecer(1);
fitColor=linspecer(1);
areaColor=linspecer(1);
alphaEdgeArea=.4;
marker='o';
xlab='';
ylab='';
yLims=[-2 4]; % nan if do not set
yLims=nan;
w=ones(size(y));

preB=nan; % This is the bin id for the "custom" binStrategy

assert(length(x)==length(y),'Vectors must have the same size')

if(~isempty(varargin))
    assert(mod(length(varargin),2)==0,'Si agregai opciones, ponle el tipo!')
    
    
    % Check that there is no duplicate option:
    assert(length(unique(varargin(1:2:end)))==length(varargin(1:2:end)),'There is one option duplicated in varargin')
    % Loading optional arguments
    while ~isempty(varargin)
        switch lower(varargin{1})
            case {'w','weight'}
                w = varargin{2};
            case {'bs','binstrategy'}
                binStrategy = varargin{2};
            case {'nb','numberbins'}
                nBins = varargin{2};
            case {'marker'}
                marker = varargin{2};
            case {'markersize'}
                markerSize = varargin{2};
            case {'markeredgecolor'}
                markerEdgeColor = varargin{2};
            case {'fitcolor'}
                fitColor = varargin{2};
            case {'areacolor'}
                areaColor = varargin{2};
            case {'colorall'}
                markerEdgeColor = varargin{2};
                fitColor = varargin{2};
                areaColor = varargin{2};
            case {'modifyxticks'}
                modifyXTicks = varargin{2};
            case {'wh','withhistogram'}
                withHistogram = varargin{2};
            case {'we','witherrorbars'}
                withErrorBars = varargin{2};
            case {'wlf','withlinearfit'}
                withLinearFit = varargin{2};
            case {'wiq','withinterquartilerange'}
                withIQRange=varargin{2};
            case {'plotquantiles','withquantiles'}
                withQuantiles=varargin{2};
            case {'quantiles'} % This in case you are reporting an estimate from different bandwidht that the plot (that usually is full bandwidth)
              
                assert(isnumeric(varargin{2}))
                assert(numel(varargin{2})==2)
                assert(all(varargin{2}>=0&varargin{2}<=1))
                if(varargin{2}(1)<varargin{2}(2))
                    quantileInf=varargin{2}(1);
                    quantileSup=varargin{2}(2);
                elseif(varargin{2}(1)>varargin{2}(2))
                    quantileInf=varargin{2}(2);
                    quantileSup=varargin{2}(1);
                else
                    error('One quantile has to be strictly greater than the other one')
                end 
            case {'ws','withscatter'}
                withScatter = varargin{2};
            case {'poscoefffit'}
                posCoeffFit = varargin{2};
            case {'preb'}
                preB = varargin{2};
            otherwise
                error(['Unexpected option: ',varargin{1}])
        end
        varargin(1:2) = [];
    end
end


assert(not(withIQRange)||not(withQuantiles),'You cannot plot inter-quartile-range and quantiles at the same time, sorry!')
if(withIQRange)
    withQuantiles=true;
    quantileInf=.25;
    quantileSup=.75;
end


p=struct;
if(removeNans)
    remove=any(isnan([x,y]),2);
    if(any(remove))
        cprintf('*systemcommand','[binsreg.m Unofficial Warning] ')
        cprintf('systemcommand','%.2f %% of obervations (%i of %i) are used in estimation\n',(1-mean(remove))*100,sum(not(remove)),length(remove))
        x=x(not(remove),:);
        y=y(not(remove),:);
        w=w(not(remove),:);
        assert(all(not(isnan(w))))
    end
end



nBinsOrig=nBins;
assert(size(y,1)==size(x,1))


controls=x(:,2:end); % If no controls, this still works.
x=x(:,1);

% This follows Catteneo 2019, "On binscatter" (eq 3.2, page 20)

%% Bins
uniqueX=unique(x);
if(not(strcmp(binStrategy,'saturated'))&&length(uniqueX)<nBins)
    cprintf('*systemcommand','[binsreg.m Unofficial Warning] ')
    cprintf('systemcommand','Not enough dispertion in x to get %i bins. saturated strategy is used instead!\n',nBinsOrig,nBins)
end


switch binStrategy
    case 'quantile-spaced'
        assert(isnan(preB))
        qs=quantile(x,nBins-1);
        withEdges=true;
        %Check that there are enough dispertion on "x" to build "nBins" bins.
        while(length(unique(qs))<length(qs)&&nBins>2)
            nBins=nBins-1;
            qs=quantile(x,nBins-1);
        end
        %         cantUniqueX=length(unique(x));
        %         if(cantUniqueX<nBins)
        %             nBins=cantUniqueX;
        %             qs=quantile(x,nBins-1);
        %         end
        
        
        leftEdgeIncluded=true;
        edges=[min(x),qs,max(x)];
        if(qs(1)==min(x))
            preB=discretize(x,edges,'includedEdge','right');
            leftEdgeIncluded=false;
            if(qs(end)==max(x))
                edges=[min(x),qs];
                nBins=nBins-1;
            end
        else
            preB=discretize(x,edges,'includedEdge','left');
        end
        
        if(nBins<nBinsOrig)
            
            cprintf('*systemcommand','[binsreg.m Unofficial Warning] ')
            cprintf('systemcommand','Not enough dispertion in x to get %i bins. %i bins are used instead!\n',nBinsOrig,nBins)
        end
        
    case 'equally-spaced'
        assert(isnan(preB))
        leftEdgeIncluded=true;
        edges=linspace(min(x),max(x),nBins+1);
        preB=discretize(x,edges,'includedEdge','left');
        nBins=length(unique(preB));
        withEdges=true;
        
    case 'saturated'
        assert(isnan(preB))
        leftEdgeIncluded=true;
        
        if(length(uniqueX)>max(nBins,30))
            error('Estay seguro que queri plotear más de 30 obs?');
        end
        
        preB=nan(size(x));
        for i=1:length(uniqueX)
            preB(x==uniqueX(i))=i;
        end
        
        nBins=length(unique(preB));
        withEdges=false;
        
    case 'custom'
        
        if(any(remove))
            preB=preB(not(remove));
        end
        assert(all(not(isnan(preB))))
        
        assert(all(size(preB)==size(y)))
        uniquePreB=unique(preB);
        nBins=length(uniquePreB);
        assert(all(uniquePreB==(1:nBins)'))
        withEdges=false;
        
end

%% Non-parametric E[Y|x]
b=nan(size(x,1),nBins);
for i=1:nBins
    b(:,i)=preB==i;
end
binsWithObs=sum(b,1)>0;
% Non paremetric regression (binscatter)
b_withObs=b(:,binsWithObs);
preU=fitlm([b_withObs,controls],y,'intercept',false,'weights',w);

se=preU.Coefficients.SE(1:nBins);
u=preU.Coefficients.Estimate(1:nBins); % The rest are the estimates for the controls;
p.yvalues=u;

if(size(controls,2)==0)
    p.quantileInf=nan(nBins,1);
    p.quantileSup=nan(nBins,1);

    for j=1:nBins
        
        p.quantileInf(j)=quantile(y(b_withObs(:,j)==1),quantileInf);
        p.quantileSup(j)=quantile(y(b_withObs(:,j)==1),quantileSup);
        
    end
    
end



% Paremetric regression (linear fit)

parReg=fitlm([ones(size(x,1),1),x,controls],y,'intercept',false,'weights',w);
alpha=parReg.Coefficients.Estimate(1);
beta=parReg.Coefficients.Estimate(2);
betaSE=parReg.Coefficients.SE(2);



%% Binscatter

if(withHistogram)
    tiledlayout(4,1,'TileSpacing','compact','Padding','compact');
    p.pBin=nexttile([3 1]);
end

%binscatter(x,y)
hold on
% Plot non-parametric

% Center of bin:
%xBins=edges(1:end-1)*.5+edges(2:end)*.5;
% Weighted center of bin:
xBins=x'*b(:,binsWithObs)./sum(b(:,binsWithObs),1);

if(withErrorBars)
    errorbar(xBins,u,1.96*se,'.')
end
p.xvalues=xBins;
if(withScatter)
    p.scatter=scatter(xBins,u,markerSize,marker,'MarkerEdgeColor',markerEdgeColor);
end
if(withLinearFit)
    % Plot parametric:
    p.linearFitPlot=fplot(@(x)alpha+beta*x,[min(x) max(x)],'--','color',fitColor);
    annotation('textbox',posCoeffFit,'String',sprintf('$\\beta: %.3f\\quad(%.3f)$',beta,betaSE),'FitBoxToText','on','Interpreter','latex','edgecolor','none','color',fitColor)
end

if(withQuantiles)
    p.quantileArea=patch('xdata',[p.xvalues,p.xvalues(end:-1:1)],'ydata',[p.quantileInf;p.quantileSup(end:-1:1)],'facecolor',areaColor,'facealpha',.1,'edgecolor','none');
    
    plot(p.xvalues,p.quantileInf,'LineStyle',':','Color',areaColor*alphaEdgeArea+[1 1 1]*(1-alphaEdgeArea));
    plot(p.xvalues,p.quantileSup,'LineStyle',':','Color',areaColor*alphaEdgeArea+[1 1 1]*(1-alphaEdgeArea));
end

if(withEdges)
p.binEdges=edges;
end

set(gca,'ygrid','on')
hold off

xlims=[min(x),max(x)];
xlims=xlims+[-1 1]*0.02*diff(xlims);
xlim(xlims)

p.xlims=xlims;

if(nBins<20&&modifyXTicks)
    xticks(xBins)
    xticklabels(gca,mat2cellstr(xBins,'precisionDecimal','%.2f'))
end
if(not(isempty(ylab)))
    ylabel(ylab)
end
if(all(size(yLims)==[1 2])&&not(any(isnan(yLims))))
    ylim(yLims);
end



%% Histogram
if(withHistogram)
    histogramColor=[196	222	241	]/256;
    histogramAlpha=.5;
    p.pHist=nexttile;
    
    if(strcmp(binStrategy,'saturated'))
        
        barWidth=diff(xlims)/200;
        
        freq=sum(b);
        bar(uniqueX,freq,barWidth,'faceColor',histogramColor,'FaceAlpha',1);
        
        if(modifyXTicks)
            xticks(uniqueX)
            xticklabels(gca,mat2cellstr(uniqueX,'precisionDecimal','%.1f'))
        end
        
    else
        % Check if unque values are only a few:
        
        
        if(length(uniqueX)<=20)
            freq=nan(length(uniqueX),1);
            
            for i=1:length(uniqueX)
                freq(i)=sum(x==uniqueX(i));
            end
            barWidth=diff(xlims)/200;
            
            bar(uniqueX,freq,barWidth,'faceColor',histogramColor,'FaceAlpha',1);
            
            
            % plot bin limits:
            edgesSep=edges;
            if(leftEdgeIncluded)
                edgesSep(1:end-1)=edgesSep(1:end-1)-barWidth;
                edgesSep(end)=edgesSep(end)+barWidth;
            else
                edgesSep(1)=edgesSep(1)-barWidth;
                edgesSep(2:end)=edgesSep(2:end)+barWidth;
            end
            
            
            
            hold on
            % limits of bins:
            for i=1:length(edges)
                plot([edgesSep(i),edgesSep(i)],[0,max(freq)*1.1],'--r')
            end
            hold off
            
            if(modifyXTicks)
                xticks(uniqueX)
                xticklabels(gca,mat2cellstr(uniqueX,'precisionDecimal','%.1f'))
            end
        else
            freq=sum(b,1);
            for i=1:nBins
                subx=x(preB==i);
                left=min(subx);
                right=max(subx);
                if(left==right)
                    left=left-diff(xlims)*.01;
                    right=right+diff(xlims)*.01;
                end
                rectangle('position',[left,0,right-left,freq(i)],'facecolor',[histogramColor,histogramAlpha]);
                
            end
            
            if(modifyXTicks)
                xticks(xBins)
                xticklabels(gca,mat2cellstr(xBins,'precisionDecimal','%.2f'))
            end
            
        end
    end
    xlim(xlims)
    ylim([0,max(freq)*1.1]);
    
    ylabel('Freq.')
    
    yticks(max(freq))
    
end
if(not(isempty(xlab)))
    xlabel(xlab)
end
hold off


