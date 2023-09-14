function labels=genEdgesLabels(edges,varargin)

nBins=length(edges)-1;
labels=cell(nBins,1);
formatLabel='';

if(~isempty(varargin))
    
    % This checks a few things, including if there is a struct called "opts"
    varargin=checkVarargin(varargin);
    
    while ~isempty(varargin)
        switch lower(varargin{1})
            case {'format','formatlabel'}
                formatLabel= varargin{2};
            otherwise
                error(['Unexpected option: ' varargin{1}])
        end
        varargin(1:2) = [];
    end
end

if(isempty(formatLabel))
    if(any(mod(edges,1)>0))
        d=2;
        formatLabel=sprintf('%%.%if',d);
    else

        formatLabel='%i';
    end
end

% Follows how "discretize.m" creates the bins (open to the right, but the
% last bin)
for b=1:nBins
if(b<nBins)
labels{b}=sprintf(['[',formatLabel,' - ',formatLabel,')'],edges(b),edges(b+1));
else
labels{b}=sprintf(['[',formatLabel,' - ',formatLabel,']'],edges(b),edges(b+1));
end

end