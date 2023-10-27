function  summ(vector,varargin)

precision='.3f';
details=false;

if(~isempty(varargin))

    % This checks a few things, including if there is a struct called "opts"
    varargin=checkVarargin(varargin);

    while ~isempty(varargin)
        switch lower(varargin{1})
            case {'precision'}
                precision= varargin{2};
            case {'details','d'}
                details= varargin{2};

            otherwise
                error(['Unexpected option: ' varargin{1}])
        end
        varargin(1:2) = [];
    end
end

vector=reshape(full(double(vector)),1,numel(vector));



fprintf(['\nMin:\t%',precision,'\nMedian:\t%',precision,'\nMax:\t%',precision,'\nMean:\t%',precision,'\nAbsM:\t%',precision,'\nStd:\t%',precision,'\n\n'],min(vector),median(vector),max(vector),mean(vector),meanabs(vector),std(vector));

if(details)
    quants=[.1 .25 .5 .75 .9];
    for q=1:length(quants)
        fprintf('q %.2f:\t%.3g\n',quants(q),quantile(vector,quants(q)));

    end
    fprintf('\nNaNs:\t%s',mat2cellstr(sum(isnan(vector)),'rc',true));
    fprintf('\nN:\t%s\n\n',mat2cellstr(numel(vector),'rc',true));
end

