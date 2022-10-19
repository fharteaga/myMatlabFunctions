function p=binsreg(x,y,varargin)
% BINSREG plot mean of y conditional on x(:,1) residualized by x(:,2:end)
%   P = BINSREG(x,y,varargin)
%
%
%% Inputs:
%   x: (numeric) indep variable(s). Can be NxJ, column 1 is plotted in the
%       horizontal axis. Columns 2 to J are used to
%       residualized the dep var (ie. as controls). Included controls are
%       de-meaned prior estimation. Results are for an "average"
%       observation in term of the controls.
%
%   y: (numeric) dep variable
%% Output:
%   p: (struct) inlcudes many objects used to construct the plot
%
%% Optional inputs:
%   binStrategy ('quantile-spaced'): (text) defines how to construct the bins
%       'equally-spaced' 'saturated' 'quantile-spaced' 'custom'
%
%   absorvedControls: (numeric): dep variables that are not included in the
%       regressions. x and y are residualized before estimation (FWL). SEs
%       are corrected to reflect the real degree of freedom.
%% Examples:
%  binsreg(x,y)
%
%  See also PLOTRD
%
%   F. Arteaga (fharteaga 'at' gmail)



nBins=10;
markerSize=50; % Actual size varies depending on number of obs per bin. But this parametere sets the "scale"
removeNans=true;
binStrategy='quantile-spaced'; % 'equally-spaced' 'saturated' 'quantile-spaced' 'custom'



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
modifyXTicks=false; % Put the values of the quantiles if is set to true.

absorvedControls=nan(1,0); % must have 0 columns if there are no absorved controls


posCoeffFit=[.60 .80];
markerEdgeColor=linspecer(1);
markerFaceColor=linspecer(1);
markerFaceAlpha=.1;
fitColor=linspecer(1);
areaColor=linspecer(1);
alphaEdgeArea=.4;
marker='o';
xlab='';
ylab='';
yLims=nan;
w=ones(size(y));

preB=nan; % This is the bin id for the "custom" binStrategy

assert(size(x,1)==size(y,1),'Inputs must have the same size')
assert(size(y,2)==1,'y must be a column vector')

if(~isempty(varargin))

    % This checks a few things, including if there is a struct called "opts"
    varargin=checkVarargin(varargin);
    while ~isempty(varargin)
        switch lower(varargin{1})
            case {'w','weight'}
                w = varargin{2};
            case {'bs','binstrategy'}
                binStrategy = varargin{2};
            case {'nb','numberbins','nbins'}
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
                markerFaceColor=varargin{2};
                fitColor = varargin{2};
                areaColor = varargin{2};
            case {'modifyxticks'}
                modifyXTicks = varargin{2};
            case {'wh','withhistogram'}
                withHistogram = varargin{2};
            case {'we','web','witherrorbars'}
                withErrorBars = varargin{2};
            case {'wlf','withlinearfit'}
                withLinearFit = varargin{2};
            case {'wiq','withinterquartilerange'}
                withIQRange=varargin{2};
            case {'plotquantiles','withquantiles'}
                withQuantiles=varargin{2};
            case {'quantiles'}
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
            case {'absorvedcontrols','ac'}
                absorvedControls = varargin{2};
            otherwise
                error(['Unexpected option: ',varargin{1}])
        end
        varargin(1:2) = [];
    end
end

if(not(isempty(absorvedControls)))

    assert(size(absorvedControls,1)==size(y,1),'Inputs must have the same size')

    if(not(isa(absorvedControls,'double')))
        absorvedControls=double(absorvedControls);
    end
    withAbsorvedControls=true;
else
    withAbsorvedControls=false;
end

assert(not(withIQRange)||not(withQuantiles),'You cannot plot inter-quartile-range and quantiles at the same time, sorry!')
if(withIQRange)
    withQuantiles=true;
    quantileInf=.25;
    quantileSup=.75;
end

p=struct;
if(removeNans)
    remove=any(isnan([x,y,absorvedControls]),2);
    if(any(remove))
        cprintf('*systemcommand','[binsreg.m Unofficial Warning] ')
        cprintf('systemcommand','%.2f %% of obervations (%i of %i) are used in estimation\n',(1-mean(remove))*100,sum(not(remove)),length(remove))
        x=x(not(remove),:);
        y=y(not(remove),:);
        w=w(not(remove),:);
        if(withAbsorvedControls)
            absorvedControls=absorvedControls(not(remove),:);
        end
        assert(all(not(isnan(w))))
    end
end
p.obsN=length(y);

nBinsOrig=nBins;

controls=x(:,2:end); % If no controls, this still works.
x=x(:,1);

% This follows Catteneo 2019, "On binscatter" (eq 3.2, page 20)

%% Bins
uniqueX=unique(x);
if(not(strcmp(binStrategy,'saturated'))&&length(uniqueX)<nBins)
    cprintf('*systemcommand','[binsreg.m Unofficial Warning] ')
    cprintf('systemcommand','Not enough dispertion in x to get %i bins (only %i unique values). saturated strategy is used instead!\n',nBins,length(uniqueX))
    binStrategy='saturated';
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


        withEdges=false;

    case 'custom'

        if(any(remove))
            preB=preB(not(remove));
        end
        assert(all(not(isnan(preB))))
        assert(all(size(preB)==size(y)))


        withEdges=false;
    otherwise
        error('There is not a bin strategy called "%s"',binStrategy)

end
uniquePreB=unique(preB);
nBins=length(uniquePreB);
p.nBins=nBins;

b=nan(size(x,1),nBins);
for i=1:nBins
    b(:,i)=preB==uniquePreB(i);
end
binsWithObs=sum(b,1)>0;
b_withObs=b(:,binsWithObs);
b_withObs_orig=b_withObs;

% Ignore first column (I'm going to add an intercept)
b_withObs=b_withObs(:,2:end);

if(false)
    %% Check if the estimates are correct
    % Results (param ans SEs!) should be very similar to this ones:
    controls2=controls-mean(controls);
    absorvedControls2=absorvedControls-mean(absorvedControls);
    preU_old=fitlm([b_withObs_orig,controls2,absorvedControls2],y,'intercept',false,'weights',w);
    preU_old2=fitlm([ones(size(b_withObs_orig,1),1),b_withObs_orig(:,2:end),controls2,absorvedControls2],y,'intercept',false,'weights',w);
end

x_orig=x;
meanY=mean(y);
meanX=mean(x);
if(withAbsorvedControls)
    % Residualize absorved controls (so we plot for the "mean obs")
    absorvedControls=absorvedControls-mean(absorvedControls,1);
    % Residualize "y", "x" and "controls" wrt "absorved controls"
    AX=[ones(p.obsN,1) absorvedControls];
    y=y-AX*((AX'*AX)\(AX'*y)); % This is needed only to get the right S.E.
    x=x-AX*((AX'*AX)\(AX'*x));
    controls=controls-AX*((AX'*AX)\(AX'*controls));
    b_withObs=b_withObs-AX*((AX'*AX)\(AX'*b_withObs));
else
    % Residualize "y", "x", and "controls" wrt the mean
    y=y-meanY;
    x=x-meanX; % This is not necessary, but doesn't hurt.
    controls=controls-mean(controls,1);
end

%% Non-parametric E[Y|x]

%preU=fitlm([ones(size(x,1),1),b_withObs,controls],y,'intercept',false,'weights',w);
%u=M*preU.Coefficients.Estimate(1:nBins); % The rest are the estimates for the controls;
% Mean correction:
% meanXBeta=mean([b_withObs_orig(:,2:end),controls],1)*preU.Coefficients.Estimate(2:end);
% u=u+meanY-meanXBeta; % mean(yhat) is not zero when there are absorved controls.

% Trick to get the intercept right (add meanY and alpha + meanXbeta to each side, since
% those are the same!)
if(withAbsorvedControls)
preU=fitlm([ones(size(x,1),1),b_withObs+mean(b_withObs_orig(:,2:end)),controls],y+meanY,'intercept',false,'weights',w);
else
preU=fitlm([ones(size(x,1),1),b_withObs,controls],y+meanY,'intercept',false,'weights',w);
end
M=eye(nBins);
M(:,1)=1;
u=M*preU.Coefficients.Estimate(1:nBins); % The rest are the estimates for the controls;

if(withAbsorvedControls)
    % Correction for DFE
    V=preU.CoefficientCovariance(1:nBins,1:nBins)*(preU.DFE/(preU.DFE-(size(absorvedControls,2))));

else
    V=preU.CoefficientCovariance(1:nBins,1:nBins);
end

se=sqrt(diag(M*V*M'));


p.yvalues=u;
p.nonParamReg=preU;


if(size(controls,2)==0&&size(absorvedControls,2)==0)
    p.quantileInf=nan(nBins,1);
    p.quantileSup=nan(nBins,1);

    for j=1:nBins

        p.quantileInf(j)=quantile(y(b_withObs_orig(:,j)==1)+meanY,quantileInf);
        p.quantileSup(j)=quantile(y(b_withObs_orig(:,j)==1)+meanY,quantileSup);

    end

end


%% Paremetric regression (linear fit)

parReg=fitlm([ones(size(x,1),1),x+meanX,controls],y+meanY,'intercept',false,'weights',w);
%alpha=parReg.Coefficients.Estimate(1);
beta=parReg.Coefficients.Estimate(2);
alpha=parReg.Coefficients.Estimate(1);
betaSE=parReg.Coefficients.SE(2);
if(withAbsorvedControls)
    % Correction for DFE
    betaSE=betaSE*sqrt(parReg.DFE/(parReg.DFE-(size(absorvedControls,2))));

end

p.paramReg=parReg;

%% Binscatter

if(withHistogram)
    tiledlayout(4,1,'TileSpacing','compact','Padding','compact');
    p.pBin=nexttile([3 1]);
end



% Plot non-parametric

% Center of bin:
%xBins=edges(1:end-1)*.5+edges(2:end)*.5;
% Weighted center of bin:
NByBin=sum(b(:,binsWithObs),1);
xBins=x_orig'*b(:,binsWithObs)./NByBin;

if(withErrorBars)
    errorbar(xBins,u,tinv(.975,preU.DFE-size(absorvedControls,2))*se,'.')
    hold on
end
p.xvalues=xBins;
if(withScatter)
    p.scatter=scatter(xBins,u,markerSize*NByBin/mean(NByBin),marker,'filled','MarkerEdgeColor',markerEdgeColor,'MarkerFaceColor',markerFaceColor,'MarkerFaceAlpha',markerFaceAlpha);
end
if(withLinearFit)
    % Plot linear fit
    hold on

    xLF=[min(x_orig) max(x_orig)];
    yLF=alpha+beta*xLF;
    p.linearFitPlot=plot(xLF,yLF,'--','color',fitColor);
    %annotation('textbox',posCoeffFit,'String',sprintf('$\\beta: %.3f\\quad(%.3f)$',beta,betaSE),'FitBoxToText','on','Interpreter','latex','edgecolor','none','color',fitColor)

end

if(withQuantiles)
    hold on
    p.quantileArea=patch('xdata',[p.xvalues,p.xvalues(end:-1:1)],'ydata',[p.quantileInf;p.quantileSup(end:-1:1)],'facecolor',areaColor,'facealpha',.1,'edgecolor','none');
    pQInf=plot(p.xvalues,p.quantileInf,'LineStyle',':','Color',areaColor*alphaEdgeArea+[1 1 1]*(1-alphaEdgeArea));
    pQSup=plot(p.xvalues,p.quantileSup,'LineStyle',':','Color',areaColor*alphaEdgeArea+[1 1 1]*(1-alphaEdgeArea));

    %uistack(pQSup,'bottom')
    %uistack(pQInf,'bottom')
    uistack(p.quantileArea,'bottom')
end

if(withEdges)
    p.binEdges=edges;
end

set(gca,'ygrid','on')
hold off

xlims=[min(xBins),max(xBins)];
xlims=xlims+[-1 1]*0.1*diff(xlims);
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

if(withLinearFit)
    % Plotting slope parameter
    xlims=xlim;
    ylims=ylim;
    annotation2('textbox',[posCoeffFit(1)*diff(xlims)+xlims(1),posCoeffFit(2)*diff(ylims)+ylims(1)],'e','String',sprintf('$\\beta: %.3f\\quad(%.3f)$',beta,betaSE),'Interpreter','latex','color',fitColor);
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


