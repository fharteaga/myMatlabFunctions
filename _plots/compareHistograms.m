function compareHistograms(vars,varargin)
% vars can be:
% a) A numeric/categorical variable
% b) A cell of numeric variables
% c) A cell of a table and chars that represents variables in the table

axisH={};
varLabels='';
maxLabelLengthFromDescription=30;

if(not(iscell(vars)))
    vars={vars};
else
    % check if there is a table in the input:
    withTable=cellfun(@istable,vars);
    if(any(withTable))
        assert(sum(withTable)==1)
        dataAux=vars{withTable};
        vars=vars(not(withTable));
        assert(all(cellfun(@ischar,vars)))
        varLabels=cell(length(vars),1);
        for v=1:length(vars)
            if(isempty(dataAux.Properties.VariableDescriptions))
                wVarDesc=false;
            else
                wVarDesc=true;
                varLabels{v}=dataAux.Properties.VariableDescriptions{vars{v}};
            end


            if(not(wVarDesc)||isempty(varLabels{v})||length(varLabels{v})>maxLabelLengthFromDescription)
                varLabels{v}=vars{v};
            end
            vars{v}=dataAux.(vars{v});
        end
    end
end

vars=reshape(vars,[],1); % 1 column for easy append allVars=[vars{:}];
cantVars=length(vars);


% Check that is a reasonble thing to do an histogram
numericVar=true(cantVars,1);
for v=1:cantVars
    vars{v}=reshape(vars{v},[],1); % 1 column for easy append allVars=[vars{:}];
    if(iscategorical(vars{v}))
        numericVar(v)=false;
    elseif(isnumeric(vars{v}))
        numericVar(v)=true;
    elseif(islogical(vars{v}))
        numericVar(v)=true;
        vars{v}=double(vars{v});
    else
        error('Numerico o categorical pa poder plotearlo')
    end

end
assert(all(numericVar)||all(not(numericVar)))
numericVars=all(numericVar);

if(cantVars==1)
    [colors,colorsAnnotation]=linspecerGrayproof(cantVars,'dispersion',0.2);
elseif(cantVars==2)
    grey=[1 1 1]*.3;
    colors=linspecerGrayproof(cantVars-1,'dispersion',0.2);
    colors=[colors(1,:);grey;colors(2:end,:)];
else
    %     grey=[1 1 1]*.3;
    %     colors=linspecerGrayproof(cantVars-1,'dispersion',0.2);
    %     colors=[grey;colors(1:end,:)];

    colors=linspecerGrayproof(cantVars,'dispersion',0.2);


end



% First var filled (at alpha=.4) with white borders
% Others vars are transparent with non-white and thick borders. First is
% dark grey

if(cantVars<3)
    overlap=true;
    alpha=[.4;zeros(cantVars-1,1)];
    edgealpha=[.4;ones(cantVars-1,1)]; % Edge of first var has to be visible to distinguish between columns
    edgeWidth=[.1;ones(cantVars-1,1)];
else
    overlap=false;
    alpha=zeros(cantVars,1);
    edgealpha=ones(cantVars,1); % Edge of first var has to be visible to distinguish between columns
    edgeWidth=ones(cantVars,1);
end





edgeBinColor_inInput=false;

nBins=20;

posCoeffs=[.7 .7 .1 .1];
smartPosCoef=true;
withEdges=false;
addNToLegend=false;
edgeLinestyle={'-'};
normalization='probability'; % probability count

ignoreMissing=false;
withKernelDensity=false;
ksdensityFunction='pdf'; % 'pdf' or 'cdf'
withHistogram=true;
withMean=true;
withMedian=false;
withCoeff=true;
withMeanSE=true;
kernelWithDifferentAxis=false;
forceCoefPosFactor=1;
blackCoefficients=false;

withFractionInBars=false;
minPercentageToShow=.03;

alphaTest=0.05;

if(~isempty(varargin))

    % This checks a few things, including if there is a struct called "opts"
    varargin=checkVarargin(varargin);

    % Loading optional arguments
    while ~isempty(varargin)
        switch lower(varargin{1})
            case {'varlabels','vl','labels'}
                varLabels = varargin{2};
            case 'colors'
                colors = varargin{2};
            case 'overlap'
                overlap = varargin{2};
            case 'poscoeffs'
                posCoeffs=varargin{2};
            case 'smartposcoef'
                smartPosCoef=varargin{2};
            case {'binedges','edges'}
                withEdges=true;
                edges=varargin{2};
            case {'nb','nbins'}
                nBins=varargin{2};
                assert(not(withEdges))
            case {'ignoremissing','im'}
                ignoreMissing=varargin{2};
            case {'edgebincolor'}
                edgeBinColor=varargin{2};
                edgeBinColor_inInput=true;
            case {'edgelinestyle'}
                edgeLinestyle=varargin{2};
            case {'edgewidth'}
                edgeWidth=varargin{2};
            case {'kernelwithdifferentaxis'}
                kernelWithDifferentAxis=varargin{2};
            case {'withkerneldensity','wkd','wk'}
                withKernelDensity=varargin{2};
            case {'ksdensityfunction'}
                ksdensityFunction=varargin{2};
            case {'withhistogram','wh'}
                withHistogram=varargin{2};
            case {'withmean','wm','wmean'} % This is bar and coeff
                withMean=varargin{2};
            case {'withmedian'} % This is bar and coeff
                withMedian=varargin{2};
            case {'withmeanse','wmse'}
                withMeanSE=varargin{2};
            case {'withcoeff','wc'}
                withCoeff=varargin{2};
            case {'forcecoefposfactor'}
                forceCoefPosFactor=varargin{2};
            case {'blackcoefficients'}
                blackCoefficients=varargin{2};
            case {'normalization'}
                normalization=varargin{2};
            case {'withfractioninbars'}
                withFractionInBars=varargin{2};
            case {'maxlabellengthfromdescription'}
                maxLabelLengthFromDescription=varargin{2};
			case{'axish'}
				axisH = varargin{2};

                
            otherwise
                error(['Unexpected option: ' varargin{1}])
        end
        varargin(1:2) = [];
    end
end

if(isempty(axisH))
axisH=gca;
end

if(not(numericVar))
    withKernelDensity=false;
    withHistogram=true;
    withMean=false;
    withMedian=false;
end

if(not(edgeBinColor_inInput))

    if(cantVars>2)
        edgeBinColor=colors;
    else
        edgeBinColor=[[1 1 1];colors(2:end,:)];
    end
end

assert(withHistogram||withKernelDensity)

for v=1:cantVars
    missing=ismissing(vars{v});
    if(ignoreMissing)
        vars{v}=vars{v}(not(missing));
    else
        assert(all(not(missing)),sprintf('One of the vars contains missings\nSuggestion, add: ,''ignoreMissing'',true'))
    end
    assert(size(vars{v},2)==1);
end

hists=cell(cantVars,1);

if(size(edgeBinColor,1)==1)
    edgeBinColor=repmat(edgeBinColor,cantVars,1);
end
if(length(edgeWidth)==1)
    edgeWidth=repmat(edgeWidth,cantVars,1);
end
if(length(edgeLinestyle)==1)
    edgeLinestyle=repmat(edgeLinestyle,cantVars,1);
end
if(length(edgealpha)==1)
    edgealpha=repmat(edgealpha,cantVars,1);
end

if(isempty(varLabels)&&cantVars>1)
    varLabels=cell(cantVars,1);
    for v=1:cantVars
        varLabels{v}=sprintf('Var%i',v);
    end
end


if(withEdges)
    bins=edges;
elseif(numericVars)
    if(cantVars>1)
        % This gives common edges
        [~,bins]=histcounts(vertcat(vars{:}),nBins);
    else
        numUniqueValues=length(unique(vars{1}));
        bins=nBins;
    end
end

meanVars=nan(cantVars,1);
medianVars=nan(cantVars,1);
errorMeanVars=nan(cantVars,1);

xKernel=cell(cantVars,1);
fKernel=cell(cantVars,1);

maxValueHist=nan;
maxValueKernel=nan;

N=cell(cantVars,1);
catsAux=cell(cantVars,1);

for v=1:cantVars
    var=vars{v};


    % histogram
    if(withHistogram)
        if(numericVars)
            if(overlap)
                if(cantVars==1&&numUniqueValues<bins)
                    hists{v}= histogram(axisH,var,'facecolor',colors(v,:),'facealpha',alpha(v),'edgecolor',edgeBinColor(v,:),'edgealpha',edgealpha(v),'normalization',normalization,'lineWidth',edgeWidth(v),'linestyle',edgeLinestyle{v});

                else
                    hists{v}= histogram(axisH,var,bins,'facecolor',colors(v,:),'facealpha',alpha(v),'edgecolor',edgeBinColor(v,:),'edgealpha',edgealpha(v),'normalization',normalization,'lineWidth',edgeWidth(v),'linestyle',edgeLinestyle{v});
                end
            else

                


                Naux=histcounts(var,bins,'normalization',normalization);
                N{v}=Naux';

            end
        else
            if(overlap)
                hists{v}= histogram(axisH,var,'facecolor',colors(v,:),'facealpha',alpha(v),'edgecolor',edgeBinColor(v,:),'edgealpha',edgealpha(v),'normalization',normalization,'lineWidth',edgeWidth(v),'linestyle',edgeLinestyle{v});
            else
                [Naux,catsAux{v}]=histcounts(var,'normalization',normalization);
                N{v}=Naux';
            end
        end
        if(overlap)
            maxValueHist=max(maxValueHist,max(hists{v}.Values));
        else
            maxValueHist=max(maxValueHist,max([N{:}],[],'all'));
        end
    end
    hold on

    % stats
    if(withMean)
        meanVars(v)=mean(var);
        errorMeanVars(v)=std(var)/sqrt(length(var));
    end

    if(withMedian)
        medianVars(v)=median(var);
    end

    % Kernel
    if(withKernelDensity)
        [fKernel{v},xKernel{v}]=ksdensity(var,'Function',ksdensityFunction);
        maxValueKernel=max(maxValueKernel,max(fKernel{v}));

    end
end

if(not(overlap)&&withHistogram)
    if(numericVars)
        histscBar=bar(axisH,bins(1:end-1)',[N{:}],'histc');
    else
        % Check that counts are the same for each cat:
        cats=catsAux{1};
        for v=2:cantVars
            % ToDo: support for vars with different but overlaping
            % categories.
            assert(all(cellfun(@(x,y)strcmp(x,y),cats,catsAux{v})))
        end

        histscBar=bar(axisH,1:length(cats),[N{:}],'hist');
        set(axisH,'xtick',1:length(cats));
        set(axisH,'xticklabels',cats);
    end
    %numberOfXTicks=9;
    %space=max(1,round(length(bins)/numberOfXTicks));
    %set(gca,'XTick',bins(1:space:end));


    for v=1:cantVars
        histscBar(v).FaceColor=colors(v,:);
        %histscBar(v).FaceAlpha=alpha(v);
        histscBar(v).FaceAlpha=.8;
        histscBar(v).EdgeColor=edgeBinColor(v,:);
        %histscBar(v).EdgeAlpha=edgealpha(v);
        histscBar(v).EdgeAlpha=0;
        histscBar(v).LineWidth=edgeWidth(v);
        histscBar(v).LineStyle=edgeLinestyle{v};

    end
end

% Plot kernel density
adjustFactor=1;
if(withKernelDensity)
    plotK=cell(cantVars,1);
    for v=1:cantVars
        if(withHistogram&&withKernelDensity)
            adjustFactor=maxValueHist/maxValueKernel;
        end
        if(kernelWithDifferentAxis)
            yyaxis(axisH,'right')
        end
        plotK{v}=plot(axisH,xKernel{v},fKernel{v}*adjustFactor,'color',colors(v,:),'linestyle','-','linewidth',1.5);
        hold(axisH,'on')
        if(kernelWithDifferentAxis)
            yyaxis(axisH,'left')
        end

    end
end



if(numericVars)
    % Make space to put the coefficients
    maxPlot=max(maxValueHist,maxValueKernel*adjustFactor);
    yLim=ylim;
    ylim(axisH,[yLim(1) max(yLim(2),1.3*maxPlot)])
    yLim=ylim;
    limsX=xlim;

    relPosData=(mean(meanVars)-limsX(1))/(limsX(2)-limsX(1));
else
    relPosData=.5; % This is needed to decide where to put the legend
end

if(withMean)
    if(cantVars==1)
        heightBeta=maxPlot*1.09-(1-forceCoefPosFactor)*maxPlot;

    elseif(cantVars==2)
        heightBeta=maxPlot*1.09-(1-forceCoefPosFactor)*maxPlot;
        heightDiff=maxPlot*1.00-(1-forceCoefPosFactor)*maxPlot;


    else
        heightBeta=maxPlot*1.3-(1-forceCoefPosFactor)*maxPlot;
        leftBeta=limsX(1)+.18*(limsX(2)-limsX(1));
        rightBeta=limsX(1)+.72*(limsX(2)-limsX(1));
    end

    % See were the data is concentrated
    if(smartPosCoef)
        posCoeffsV=nan(cantVars,2);
        orientation=cell(cantVars,1);
        if(cantVars==1)

            posCoeffsV(1,:)=[meanVars(1)+2.5*errorMeanVars(1) heightBeta];
            orientation{1}='NE';

        elseif(cantVars==2)

            if(meanVars(1)<meanVars(2))
                posCoeffsV(1,:)=[meanVars(1)-2.5*errorMeanVars(1) heightBeta];
                orientation{1}='NW';

                posCoeffsV(2,:)=[meanVars(2)+2.5*errorMeanVars(2) heightBeta];
                orientation{2}='NE';

                posDiff=[posCoeffsV(2,1) heightDiff];
            else
                posCoeffsV(2,:)=[meanVars(2)-2.5*errorMeanVars(2) heightBeta];
                orientation{2}='NW';

                posCoeffsV(1,:)=[meanVars(1)+2.5*errorMeanVars(1) heightBeta];
                orientation{1}='NE';

                posDiff=[posCoeffsV(1,1) heightDiff];

            end

        elseif(cantVars>=3)

            posCoeffsV=nan(cantVars,2);

            if(relPosData>.5)
                posCoeffs=[leftBeta heightBeta ];
            else
                posCoeffs=[rightBeta heightBeta];
            end
            for v=1:cantVars
                posCoeffsV(v,:)=posCoeffs+[0 -.13*heightBeta*v];
                orientation{v}='E';
            end
        end
    else
        posCoeffsV=repmat(posCoeffs,cantVars,1);
        orientation=repmat({'E'},cantVars,1);
    end


    for v=1:cantVars
        meanVar=meanVars(v);
        se=errorMeanVars(v);

        plot(meanVar*[1 1],[0 yLim(2)],'--','color',colors(v,:))
        if(withMeanSE)
            tinvV=tinv((1-alphaTest/2),length(vars{v})-1);

            plot(axisH,(meanVar+tinvV*se)*[1 1],[0 yLim(2)],':','color',colors(v,:))
            plot(axisH,(meanVar-tinvV*se)*[1 1],[0 yLim(2)],':','color',colors(v,:))
        end
        if(withCoeff)
            if(blackCoefficients)
                colorCoef=.1*[1 1 1];
            else
                colorCoef=colors(v,:);
            end

            annotation2('textbox',posCoeffsV(v,:),orientation{v},'String',sprintf('$\\mu$: $%.3f$\n$\\quad(%.3f)$',meanVar,se),'Interpreter','latex','edgecolor','none','color',colorCoef,'axisPlot',axisH);
        end

    end

% Add difference between two if vars are 32
    if(cantVars==2)

        newVar=[vars{1};vars{2}];
        dummy=[zeros(length(vars{1}),1);ones(length(vars{2}),1)];

        parReg=fitlm(dummy,newVar,'intercept',true);
        %alpha=parReg.Coefficients.Estimate(1);
        beta=parReg.Coefficients.Estimate(2);
        betaSE=parReg.Coefficients.SE(2);


        colorCoef=.1*[1 1 1];


        annotation2('textbox',posDiff,'E','String',sprintf('$\\Delta$: $%.3f$\n$\\quad(%.3f)$',beta,betaSE),'Interpreter','latex','edgecolor','none','color',colorCoef,'axisPlot',axisH);

    end
end

if(withMedian)
    for v=1:cantVars
        medianVar=medianVars(v);
        plot(axisH,medianVar*[1 1],[0 yLim(2)],'--','color',colors(v,:))

    end
end

if(withHistogram)
    switch normalization
        case 'probability'
            ylabel(axisH,'Fraction')
        case 'count'
            ylabel(axisH,'Count')
        otherwise
            error('aca')
    end
elseif(withKernelDensity)
    if(strcmpi(ksdensityFunction,'cdf'))
    ylabel(axisH,'Estimated CDF')
    else
        ylabel(axisH,'Estimated PDF')
    end
end


if(addNToLegend)
    for v=1:cantVars
        varLabels{v}=[varLabels{v},sprintf(' [N: %s]',mat2cellstr(length(vars{v}),'rc',true))];
    end
end


if(not(isempty(varLabels))&&not(isempty(varLabels{1})))
    if(numericVars)
        if(relPosData>.5)
            locLeg='northwest';
        else
            locLeg='northeast';
        end
    else
        locLeg='northeast';
    end
    if(withHistogram)
    if(overlap)
        legend([hists{:}],varLabels,'interpreter','latex','location',locLeg);
    else
        legend(histscBar,varLabels,'interpreter','latex','location',locLeg);
    end
    elseif(withKernelDensity)
    legend([plotK{:}],varLabels,'interpreter','latex','location',locLeg);

    end
end

if(withFractionInBars&&cantVars==1)
        percY=hists{1}.Values;
        if(numericVars(1))
        xAnnotation=(hists{1}.BinEdges(1:end-1)+hists{1}.BinEdges(2:end))/2;
        else
        xAnnotation=1:hists{1}.NumDisplayBins;
        end
        for i=1:length(percY)
            if(percY(i)>minPercentageToShow)
             
                  
                    annotation2('textbox',[xAnnotation(i),percY(i)/2],'o','String',sprintf('%2.0f$\\%%$',percY(i)*100),'Interpreter','latex','edgecolor','none','color',colorsAnnotation(1,:),'axisPlot',axisH);
                
            end
        end
end


if(withKernelDensity&&kernelWithDifferentAxis)
    yyaxis(axisH,'right')
    ylabel(axisH,'Density')
end
hold off

%legend([hists{:}],legendCell,'location','best','NumColumns',min(cantVars,2),'interpreter','latex');
