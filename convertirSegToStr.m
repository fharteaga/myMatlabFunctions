function tiempoStr=convertirSegToStr(tiempoSeg,varargin)
% convertirSegToStr(toc,'print',true,'intro','Time elapsed on')

assert(isnumeric(tiempoSeg))

% Default values

print=false;
intro='';

if(nargin>1)
varargin=checkVarargin(varargin);

% Loading optional arguments
while ~isempty(varargin)
    switch lower(varargin{1})
        
        case 'intro'
            intro=varargin{2};
            print=true;
        case 'print'
            print = varargin{2};
        otherwise
            error(['Unexpected option: ' varargin{1}])
    end
    varargin(1:2) = [];
end
end

if(tiempoSeg<60)
    tiempoStr=sprintf('%i seg.',round(tiempoSeg));
elseif(tiempoSeg<(60*60))
    tiempoMin=floor(tiempoSeg/60);
    tiempoStr=sprintf('%i min. %i seg.',tiempoMin,round(tiempoSeg-tiempoMin*60));
else
    tiempoHr=floor(tiempoSeg/(60*60));
    tiempoMin=floor((tiempoSeg-tiempoHr*60*60)/60);
    tiempoStr=sprintf('%i hr. %i min. %i seg.',tiempoHr,tiempoMin,round(tiempoSeg-tiempoMin*60-tiempoHr*60*60));
end

if(print)
    if(~isempty(intro))
        fprintf('%s\n',intro)
    end
    fprintf('\t%s\n\n',tiempoStr)
end