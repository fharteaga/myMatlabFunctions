function miss=getMissingByClass(classChar)
% get class of a variable with "class()"
% get class of variables in table with "varfun(@class,TABLA,'OutputFormat','cell')"
%
% from https://www.mathworks.com/help/matlab/ref/standardizemissing.html
switch classChar
    case {'logical'} % logical doesn't have missing. But if nan, then appending transform logical and nan into double
        miss=NaN;
    case {'double', 'single', 'duration', 'calendarDuration',}
        %miss=NaN;
        miss=missing;
    case 'datetime'
        %miss=NaT;
         miss=missing;
    case 'string'
        miss=missing;
    case 'categorical'
        %miss=categorical(NaN);
        miss=missing;
    case 'cell'
        miss={''};
    otherwise
        error('Not missing defined for class %s',classChar)
end