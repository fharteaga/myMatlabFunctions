function showShorcut(text,varargin)

print=true;
if(~isempty(varargin))
    
    % This checks a few things, including if there is a struct called "opts"
    varargin=checkVarargin(varargin);
    
    while ~isempty(varargin)
        switch lower(varargin{1})
            case {'print'}
                print= varargin{2};
            otherwise
                error(['Unexpected option: ' varargin{1}])
        end
        varargin(1:2) = [];
    end
end

clipboard('copy',text)
if(print)
fprintf('\n%s\n',text)
end
fprintf('\nIt''s on your clipboard!\n')