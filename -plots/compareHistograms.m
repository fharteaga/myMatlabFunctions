function compareHistograms(vars,varargin)
% vars can be:
% a) A numeric/categorical variable
% b) A cell of numeric variables
% c) A cell of a table and chars that represents variables in the table


varLabels='';
maxLabelLengthFromDescription=20;

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
            varLabels{v}=dataAux.Properties.VariableDescriptions{vars{v}};
            if(isempty(varLabels{v})||length(varLabels{v})>maxLabelLengthFromDescription)
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
    colors=linspecerGrayproof(cantVars,'dispersion',0.2);
else
    grey=[1 1 1]*.3;
    colors=linspecerGrayproof(cantVars-1,'dispersion',0.2);
    colors=[colors(1,:);grey;colors(2:end,:)];
end



% First var filled (at alpha=.4) with white borders
% Others vars are transparent with non-white and thick borders. First is
% dark grey

alpha=[.4;zeros(cantVars-1,1)];
edgealpha=[.4;ones(cantVars-1,1)]; % Edge of first var has to be visible to distinguish between columns

edgeWidth=[.1;ones(cantVars-1,1)];


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
withHistogram=true;
withMean=true;
kernelWithDifferentAxis=false;
forceCoefPosFactor=1;
blackCoefficients=false;

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
            case {'withhistogram','wh'}
                withHistogram=varargin{2};
            case {'withmean','wm'}
                withMean=varargin{2};
            case {'forcecoefposfactor'}
                forceCoefPosFactor=varargin{2};
            case {'blackcoefficients'}
                blackCoefficients=varargin{2};
            case {'normalization'}
                normalization=varargin{2};
            otherwise
                error(['Unexpected option: ' varargin{1}])
        end
        varargin(1:2) = [];
    end
end

if(not(numericVar))
    withKernelDensity=false;
    withHistogram=true;
    withMean=false;
end

if(not(edgeBinColor_inInput))
    edgeBinColor=[[1 1 1];colors(2:end,:)];
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
        bins=nBins;
    end
end

meanVars=nan(cantVars,1);
errorMeanVars=nan(cantVars,1);

xKernel=cell(cantVars,1);
fKernel=cell(cantVars,1);

maxValueHist=nan;
maxValueKernel=nan;

for v=1:cantVars
    var=vars{v};


    % histogram
    if(withHistogram)
        if(numericVars)
            hists{v}= histogram(var,bins,'facecolor',colors(v,:),'facealpha',alpha(v),'edgecolor',edgeBinColor(v,:),'edgealpha',edgealpha(v),'normalization',normalization,'lineWidth',edgeWidth(v),'linestyle',edgeLinestyle{v});
        else
            hists{v}= histogram(var,'facecolor',colors(v,:),'facealpha',alpha(v),'edgecolor',edgeBinColor(v,:),'edgealpha',edgealpha(v),'normalization',normalization,'lineWidth',edgeWidth(v),'linestyle',edgeLinestyle{v});

        end
        maxValueHist=max(maxValueHist,max(hists{v}.Values));
    end
    hold on

    % stats
    if(withMean)
        meanVars(v)=mean(var);
        errorMeanVars(v)=std(var)/sqrt(length(var));
    end

    % Kernel
    if(withKernelDensity)
        [fKernel{v},xKernel{v}]=ksdensity(var);
        maxValueKernel=max(maxValueKernel,max(fKernel{v}));

    end
end

% Plot kernel density
adjustFactor=1;
if(withKernelDensity)
    for v=1:cantVars
        if(withHistogram&&withKernelDensity)
            adjustFactor=maxValueHist/maxValueKernel;
        end
        if(kernelWithDifferentAxis)
            yyaxis right
        end
        plot(xKernel{v},fKernel{v}*adjustFactor,'color',colors(v,:),'linestyle','-','linewidth',1.5);
        hold on
        if(kernelWithDifferentAxis)
            yyaxis left
        end

    end
end



if(numericVars)
    % Make space to put the coefficients
    maxPlot=max(maxValueHist,maxValueKernel*adjustFactor);
    yLim=ylim;
    ylim([yLim(1) max(yLim(2),1.3*maxPlot)])
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
        leftBeta=limsX(1)+.1*(limsX(2)-limsX(1));
        rightBeta=limsX(1)+.75*(limsX(2)-limsX(1));
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

    if(withMean)
        for v=1:cantVars
            meanVar=meanVars(v);
            se=errorMeanVars(v);

            plot(meanVar*[1 1],[0 yLim(2)],'--','color',colors(v,:))
            tinvV=tinv((1-alphaTest/2),length(vars{v})-1);

            plot((meanVar+tinvV*se)*[1 1],[0 yLim(2)],':','color',colors(v,:))
            plot((meanVar-tinvV*se)*[1 1],[0 yLim(2)],':','color',colors(v,:))

            if(blackCoefficients)
                colorCoef=.1*[1 1 1];
            else
                colorCoef=colors(v,:);
            end

            annotation2('textbox',posCoeffsV(v,:),orientation{v},'String',sprintf('$\\mu$: $%.3f$\n$\\quad(%.3f)$',meanVar,se),'Interpreter','latex','edgecolor','none','color',colorCoef);


        end
    end

    if(cantVars==2)

        newVar=[vars{1};vars{2}];
        dummy=[zeros(length(vars{1}),1);ones(length(vars{2}),1)];

        parReg=fitlm(dummy,newVar,'intercept',true);
        %alpha=parReg.Coefficients.Estimate(1);
        beta=parReg.Coefficients.Estimate(2);
        betaSE=parReg.Coefficients.SE(2);


        colorCoef=.1*[1 1 1];


        annotation2('textbox',posDiff,'E','String',sprintf('$\\Delta$: $%.3f$\n$\\quad(%.3f)$',beta,betaSE),'Interpreter','latex','edgecolor','none','color',colorCoef);

    end
end
if(withHistogram)
    switch normalization
        case 'probability'
            ylabel('Fraction')
        case 'count'
            ylabel('Count')
        otherwise
            error('aca')
    end
elseif(withKernelDensity)
    ylabel('Density')
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
    legend([hists{:}],varLabels,'interpreter','latex','location',locLeg);
end

if(withKernelDensity&&kernelWithDifferentAxis)
    yyaxis right
    ylabel('Density')
end
hold off

%legend([hists{:}],legendCell,'location','best','NumColumns',min(cantVars,2),'interpreter','latex');
