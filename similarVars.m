function vars=similarVars(tabla,pattern,varargin)


type='all';% s: startsWith, c: contains, e: endsWith, all: s, c and e

ignoreCase=true;

if(length(varargin)==1)

    type=varargin{1};
else
    if(~isempty(varargin))

        % This checks a few things, including if there is a struct called "opts"
        varargin=checkVarargin(varargin);

        while ~isempty(varargin)
            switch lower(varargin{1})
                case {'type','t'}
                    type= varargin{2};

                otherwise
                    error(['Unexpected option: ' varargin{1}])
            end
            varargin(1:2) = [];
        end
    end
end

varsT=tabla.Properties.VariableNames';


if(ischar(type))
    if(strcmpi(type,'all'))

        types={'s','c','e'};
    else
        types={type};
    end
end

if(not(iscell(pattern))&&not(isstring(pattern)))
pattern={pattern};
end
if(isstring(pattern))
    pattern=cellstr(pattern);
end


similar=false(length(varsT),1);
for p=1:length(pattern)
for t=1:length(types)
    type=types{t};
    switch type
        case 's'
            similar=similar|(startsWith(varsT,pattern{p},'IgnoreCase',ignoreCase));

        case 'c'
            similar=similar|(contains(varsT,pattern{p},'IgnoreCase',ignoreCase));

        case 'e'
            similar=similar|(endsWith(varsT,pattern{p},'IgnoreCase',ignoreCase));

        otherwise
            error('Aca')

    end
end
end
vars=varsT(similar);
