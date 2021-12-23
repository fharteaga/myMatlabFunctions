function beamer=addSlide(beamer,varargin)

figures={};
tables={};
title='';


 % Check if optional arguments come in struct
    [is,pos]=ismember('opts',varargin(1:2:end));
    if(any(is))
        
        assert(sum(is)==1);pos=(pos-1)*2+1;
        opts=varargin{pos+1};assert(isstruct(opts));
        varargin([pos,pos+1])=[];
        fields=fieldnames(opts)';values=struct2cell(opts)';
        newVarargin=cell(1,length(values)*2);
        newVarargin(1:2:end)=fields;newVarargin(2:2:end)=values;
        varargin=[varargin,newVarargin];
        
    end
    
    
% Loading optional arguments
    if(~isempty(varargin))
        assert(mod(length(varargin),2)==0,'Si agregai opciones, ponle el tipo!')
                % Check that there is no duplicate option:
        assert(length(unique(varargin(1:2:end)))==length(varargin(1:2:end)),'There is one option duplicated in varargin')
        while ~isempty(varargin)
            switch lower(varargin{1})
                case {'figures'}
                     figures= varargin{2};
                                     case {'title'}
                     title= varargin{2};
                otherwise
                    error(['Unexpected option: ' varargin{1}])
            end
            varargin(1:2) = [];
        end
    end

beamer.n=beamer.n+1;
slide=struct;
slide.n=beamer.n;
slide.title=title;

for f=1:length(figures)
    beamer.nFig=beamer.nFig+1;
    fig=figures{f};
    name=sprintf('fig%i.png',beamer.nFig);
    movefile(fig.fileAndPath,[beamer.dirFigures,name]);
    slide.fig='name';
end

beamer.(sprintf('s%i',slide.n))=slide;

end



