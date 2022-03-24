function count= countunique(var,varargin)

suppressMissingWarning=false;
if(~isempty(varargin))
    
    % This checks a few things, including if there is a struct called "opts"
    varargin=checkVarargin(varargin);
    
    while ~isempty(varargin)
        switch lower(varargin{1})
            case {'suppressmissingwarning'}
                suppressMissingWarning= varargin{2};
                
            otherwise
                error(['Unexpected option: ' varargin{1}])
        end
        varargin(1:2) = [];
    end
end

missings=ismissing(var);
if(not(suppressMissingWarning))
    totalMiss=sum(missings);
    if(totalMiss>0)
        warning('There are %i missings',totalMiss)
    end
end

count=length(unique(var(not(missings))));
