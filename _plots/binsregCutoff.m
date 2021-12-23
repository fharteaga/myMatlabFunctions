function [brl,brr]=binsregCutoff(x,y,varargin)

binStrategy='quantile-spaced';
cutoff=nan;
color=[0.6350 0.0780 0.1840]; % BLue: [0 0.4470 0.7410] Red: [0.6350 0.0780 0.1840]       
marker='o';
markerSize=50;
quantiles=[.25 .75];
plotQuantiles=false;
plotLeft=true;
plotRight=true;

if(islogical(y))
    y=double(y);
end
if(islogical(x))
    y=double(x);
end


if(~isempty(varargin))
    varargin=checkVarargin(varargin);
    while ~isempty(varargin)
        switch lower(varargin{1})
            case {'bs','binstrategy'}
                binStrategy = varargin{2};
            case {'nb','numberbins'}
                nBins = varargin{2};
            case {'c','cutoff'}
                cutoff = varargin{2};
            case {'color'}
                color = varargin{2};
            case {'markersize'}
                markerSize = varargin{2};
            case {'marker'}
                marker = varargin{2};
            case {'plotquantiles'}
                plotQuantiles = varargin{2};
            case {'quantiles'} % This in case you are reporting an estimate from different bandwidht that the plot (that usually is full bandwidth)
                assert(isnumeric(varargin{2}))
                assert(numel(varargin{2})==2)
                quantiles= varargin{2};
            case {'plotleft'}
                plotLeft=varargin{2};
            case {'plotright'}
                plotRight=varargin{2};
                
            otherwise
                error(['Unexpected option: ',varargin{1}])
        end
        varargin(1:2) = [];
    end
end
assert(not(isnan(cutoff)))



% Check how to divide the nBins:
nBinl=round(nBins*mean(x<=cutoff));
nBinr=round(nBins*mean(x>cutoff));
% plot left of cutoff
if(plotLeft)
brl=binsreg(x(x<cutoff),y(x<cutoff),'bs',binStrategy,'nb',nBinl,'modifyXTicks',false,'marker',marker,'markerEdgeColor',color,'areaColor',color,'markerSize',markerSize,'plotQuantiles',plotQuantiles,'quantiles',quantiles); hold on
else
    brl={};
end
% plot right of cutoff
if(plotRight)
brr=binsreg(x(x>cutoff),y(x>cutoff),'bs',binStrategy,'nb',nBinr,'modifyXTicks',false,'marker',marker,'markerEdgeColor',color,'areaColor',color,'markerSize',markerSize,'plotQuantiles',plotQuantiles,'quantiles',quantiles); hold off
else
    brr={};
end
if(plotLeft&&plotRight)
xlim([min([brl.xlims brr.xlims]) max([brl.xlims brr.xlims])])
end

if(plotQuantiles)
    
    ylim([min([brl.xlims brr.xlims]) max([brl.xlims brr.xlims])])
end