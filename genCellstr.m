function genCellstr(input,varargin)

vertical=false;
if(~isempty(varargin))
    
    % This checks a few things, including if there is a struct called "opts"
    varargin=checkVarargin(varargin);
    
    while ~isempty(varargin)
        switch lower(varargin{1})
            case {'vertical'}
                vertical= varargin{2};
                
            otherwise
                error(['Unexpected option: ' varargin{1}])
        end
        varargin(1:2) = [];
    end
end

if(istable(input))
    cell=input.Properties.VariableNames;
else
    assert(iscellstr(input)||(isstring(input)));
    cell=input;
end

a='';
a=sprintf('%s{',a);
for i=1:(length(cell)-1)
    if(vertical)
        a=sprintf('%s''%s'',...\n',a,cell{i});
    else
        a=sprintf('%s''%s'',',a,cell{i});
    end
end
a=sprintf('%s''%s''}',a,cell{end});
showShorcut(a);
