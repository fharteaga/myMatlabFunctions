function genInputVaragin(optionName)

if(nargin==0)
    optionName = evalin('base', 'who');
else
    if(ischar(optionName))
        optionName={optionName};
    end
    if(isstring(optionName))
        optionName=cellstr(optionName);
    end
end

text='';
for s=1:length(optionName)
    text=sprintf('%s\n\t\t\tcase{''%s''}\n\t\t\t\t%s = varargin{2};',text,lower(optionName{s}),optionName{s});
end
text=sprintf('%s\n',text);
showShorcut(text,'print',true)

