function printLoopProgress(i,I,varargin)

% Give datetimeStart (beginning of the loop) if you want absolute time
% since start
% 'datetimeStart',datetimeStart

%{
datetimeStart=datetime('now');
for i=1:I

    printLoopProgress(i,I,'datetimeStart',datetimeStart,'interval',round(I/10));

end
%}

datetimeStart=NaT;
interval=round(I/10);

if(~isempty(varargin))

    % This checks a few things, including if there is a struct called "opts"
    varargin=checkVarargin(varargin);

    while ~isempty(varargin)
        switch lower(varargin{1})
            case {'datetimestart'}
                datetimeStart= varargin{2};
			case{'interval'}
				interval = varargin{2};
            otherwise
                error(['Unexpected option: ' varargin{1}])
        end
        varargin(1:2) = [];
    end
end


if(mod(i+1,interval)==0||i==I)
    message='Starting iteration';
    datetimeNow=datetime('now');
    datetimeNowString=string(datetimeNow);


    if((not(isnat(datetimeStart)))&&i>1)
        elapsedTime=time(between(datetimeStart,datetimeNow));
        meanTimePerIter=elapsedTime/(i-1);
        estimatedDuration=meanTimePerIter*I;
        estimatedEnd=datetimeStart+estimatedDuration;
        stringTimeSinceStart=sprintf('- %s of ~%s - %s average per iter - estimated end: %s',string(elapsedTime,"hh:mm:ss"),string(estimatedDuration,"hh:mm:ss"),string(meanTimePerIter,"hh:mm:ss"),string(estimatedEnd));

    else
        stringTimeSinceStart='';
    end





    fprintf('[%s] %s %i of %i  %s\n',datetimeNowString,message,i,I,stringTimeSinceStart)
end