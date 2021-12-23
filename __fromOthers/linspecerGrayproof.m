function [colors,colorsAnnotation]=linspecerGrayproof(numberOfColors,varargin)

% dispersion=0 means no extra dispersion between colors (extra dispersion makes
% grays differ more)

dispersion=.20;
sortByGreyness=true;


if(~isempty(varargin))
    
    % This checks a few things, including if there is a struct called "opts"
    varargin=checkVarargin(varargin);
    
    while ~isempty(varargin)
        switch lower(varargin{1})
            case {'dispersion'}
                dispersion= varargin{2};
            case {'sortbygreyness'}
                sortByGreyness= varargin{2};
                
            otherwise
                error(['Unexpected option: ' varargin{1}])
        end
        varargin(1:2) = [];
    end
end


assert(dispersion>=0&&dispersion<=1)

colors=linspecer(numberOfColors);

if(sortByGreyness)
    % Sort colors on how dark they are:
    colorsGrey=rgb2gray(colors);
    [~,b]=sort(mean(colorsGrey,2));
    colors=colors(b,:);
end

% Make grey differ more
colors=(1-dispersion)*colors+dispersion*repmat((0:1/(numberOfColors-1):1)',1,3);

%colors=rgb2gray(colors);
colorsAnnotation=nan(size(colors));
for i=1:numberOfColors
    color=rgb2gray(colors(i,:));
    if(color(1)>.5)
        colorsAnnotation(i,:)=[0 0 0];
    else
        colorsAnnotation(i,:)=[1 1 1];
    end
end
