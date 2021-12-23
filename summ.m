function  summ(vector,varargin)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

    vector=reshape(full(double(vector)),1,numel(vector));
    

    
    fprintf('\nMin:\t%.3f\nMedian:\t%.3f\nMax:\t%.3f\nMean:\t%.3f\nAbsM:\t%.3f\nStd:\t%.3f\n\n',min(vector),median(vector),max(vector),mean(vector),meanabs(vector),std(vector));
    
   if(nargin>1)
       quants=[.1 .25 .5 .75 .9];
       for q=1:length(quants)
           fprintf('q %.2f:\t%.3g\n',quants(q),quantile(vector,quants(q)));
           
       end
       fprintf('\nNaNs:\t%s',mat2cellstr(sum(isnan(vector)),'rc',true));
       fprintf('\nN:\t%s\n\n',mat2cellstr(numel(vector),'rc',true));
end

