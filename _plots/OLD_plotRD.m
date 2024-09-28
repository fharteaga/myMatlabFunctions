function res=plotRD(res_i,data,varargin)

% res_i comes from the output of the rdrobust Stata command

color=linspecer(1);
colorFit=nan;
colorBinsreg=nan;
widthRDFit=1;
shiftPointEstimate=0;
withNewXlim=false; % This makes a zooms w/respect to the original data in scatter of subpop.
newXlim=nan;
modifyPlotLims=true;
posBetaInput=nan; % Defined later depending on position of data
withPosBeta=false;
posBetaHorzInput=.13; % Defined later depending on position of data
withPosBetaHorz=false;
numberOfBins=50;
marker='o';
withStars=true;
res_i_pointEstimate=res_i;
parameterLabel='\beta_{RD}';

quantiles=[.25,.75];
plotQuantiles=false;


withPointEstimate=1;
withBinsreg=1;
withLeftScatter=true;
withRightScatter=true;
withRDFit=true;
withLeftRDFit=true;
withRightRDFit=true;

withCutoffVerticalLine=1;

subpop=true(height(data),1);

if(~isempty(varargin))
    varargin=checkVarargin(varargin);
    % Loading optional arguments
    while ~isempty(varargin)
        switch lower(varargin{1})
            case {'color'}
                color = varargin{2};
            case {'subpop'}
                subpop = varargin{2};
            case {'colorfit'}
                colorFit = varargin{2};
            case {'colorbinsreg'}
                colorBinsreg = varargin{2};
            case {'widthlocalfit','widthrdfit'}
                widthRDFit = varargin{2};
            case 'withpointestimate'
                withPointEstimate = varargin{2};
            case 'shiftpointestimate'
                shiftPointEstimate = varargin{2};
            case 'newxlim'
                withNewXlim=1;
                newXlim= varargin{2};
            case 'modifyplotlims'
                modifyPlotLims= varargin{2};
            case 'withbinsreg'
                withBinsreg= varargin{2};
            case 'withleftscatter'
                withLeftScatter= varargin{2};
            case 'withrightscatter'
                withRightScatter= varargin{2};
            case 'withleftrdfit'
                withLeftRDFit= varargin{2};
            case 'withrightrdfit'
                withRightRDFit= varargin{2};
            case 'withcutoffverticalline'
                withCutoffVerticalLine= varargin{2};
            case 'withstars'
                withStars= varargin{2};
            case 'posbeta'
                withPosBeta=true;
                posBetaInput= varargin{2};
            case 'posbetahorz'
                withPosBetaHorz=true;
                posBetaHorzInput= varargin{2};
            case 'marker'
                marker=varargin{2};
            case 'parameterlabel'
                parameterLabel=varargin{2};
            case {'numberofbins','nb'}
                numberOfBins= varargin{2};
            case {'otherpointestimate'} % This in case you are reporting an estimate from different bandwidht that the plot (that usually is full bandwidth)
                res_i_pointEstimate= varargin{2};
            case {'quantiles'}
                assert(numel(varargin{2})==2)
            case {'plotquantiles'}
                plotQuantiles= varargin{2};
            otherwise
                error(['Unexpected option: ',varargin{1}])

        end
        varargin(1:2) = [];
    end
end

if(isnan(colorBinsreg))
    colorBinsreg=color;
end
if(isnan(colorFit))
    colorFit=color;
end
if(withPosBeta&&shiftPointEstimate>0)
    warning('"shiftPointEstimate" is not going to affect the position, since you are giving the vertical position with "posBeta"!')
end
% res is a struct with potentially many stuff
% For now I add the result of fplot to relate with a legend expost
res=struct;
depvar=res_i.depvar;
runningvar=res_i.runningvar;
cutoff=res_i.c;
plotsub=subpop;

%% Binsreg
if(withBinsreg)
    [bl,br]=binsregCutoff(data.(runningvar)(plotsub),data.(depvar)(plotsub),'cutoff',cutoff,'nb',numberOfBins,'color',colorBinsreg,'markerSize',30,'marker',marker,'plotQuantiles',plotQuantiles,'quantiles',quantiles,'plotLeft',withLeftScatter,'plotRight',withRightScatter);
else
    bl={};
    br={};
end

%% Fit
%(this comes from the RD Robust, not from binscatter)
% Plots with the same bandwidth used in the RD.
if(withRDFit)
    hold on;
    if(withLeftRDFit)
        res.functionLine=fplot(@(x)polyfun(x-cutoff,res_i.beta_p_l),[cutoff-res_i.h_l,cutoff],'color',colorFit,'linewidth',widthRDFit);
    end
    if(withRightRDFit)
        res.functionLine=fplot(@(x)polyfun(x-cutoff,res_i.beta_p_r),[cutoff,cutoff+res_i.h_r],'color',colorFit,'linewidth',widthRDFit);
    end
    hold off
end



%% Point estimate
if(withPointEstimate)
    % Point estimate

    if(withBinsreg&&not(withPosBeta))
        if(mean(br.yvalues)<mean(bl.yvalues))
            posBeta=.2+shiftPointEstimate;
        else
            posBeta=.8-shiftPointEstimate;
        end
    elseif(not(withPosBeta))
        posBeta=.2+shiftPointEstimate;
    else
        posBeta=posBetaInput;
    end

    % "se_tau_rb" is the standard error of the "bias corrected estimate"
    % Conventional estimate is still the "optimal" point estimator in a MSE
    % sense (or whatever is picked), but the inference should be done
    % centered in the bias-corrected estimate and using se_tau_rb as the
    % standard error, that considers that we are estimating the bias (ie:
    % is larger than the conventional se)
    % Tutorial by Cattaneo:
    % https://www.chamberlainseminar.org/past-seminars/autumn-2020#h.41tsl12q6tcb
    se=res_i_pointEstimate.se_tau_cl;

    if(withStars)
        textParam=sprintf('$%s: %.3f^{%s}$\n$\\quad\\quad(%.3f)$',parameterLabel,res_i_pointEstimate.tau_cl,getStars(res_i_pointEstimate.tau_cl,se),se);
    else
        textParam=sprintf('$%s: %.3f$\n$\\quad\\quad(%.3f)$',parameterLabel,res_i_pointEstimate.tau_cl,se);
    end
    annotation('textbox',[posBetaHorzInput posBeta .1 .1],'String',textParam,'FitBoxToText','on','Interpreter','latex','edgecolor','none','color',colorFit)
    res.posBeta=posBeta;
end


%% Labels
if(not(isempty(data.Properties.VariableDescriptions)))
    dicX=data.Properties.VariableDescriptions{runningvar};
    if(isempty(dicX))
        dicX=runningvar;
    end

    dicY=data.Properties.VariableDescriptions{depvar};
    if(isempty(dicY))
        dicY=depvar;
    end
else
    dicX=runningvar;
    dicY=depvar;
end

xlabel(dicX)
ylabel(dicY)


%% X and Y lims
if(modifyPlotLims&&withBinsreg)
    if(withNewXlim)
        brlim=br.xvalues<newXlim(2);
        bllim=bl.xvalues>newXlim(1);
        xlim(newXlim);
    else
        brlim=true(size(br.xvalues));
        bllim=true(size(bl.xvalues));
    end

    lowerY=min([br.yvalues(brlim);bl.yvalues(bllim)]);
    higherY=max([br.yvalues(brlim);bl.yvalues(bllim)]);
    adjust=.2;

    if(plotQuantiles)
        adjust=.02;
        lowerY=min([lowerY;br.quantileInf(brlim);bl.quantileInf(bllim)]);
        higherY=max([higherY;br.quantileSup(brlim);bl.quantileSup(bllim)]);
    end




    deltaY=higherY-lowerY;
    ylim([lowerY-adjust*deltaY higherY+adjust*deltaY]);


end
%% Cutoff
if(withCutoffVerticalLine)
    hold on;plot(cutoff*[1 1],ylim,'--','color',.5*[1 1 1]);hold off
end


res.binscatter_l=bl;
res.binscatter_r=br;
hold off
hold off
