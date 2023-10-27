function [frec,unicos,tabla]=tab(vector,varargin)

% unicos es string pq es el label de "crosstab.m".
%% Reviso el input
% Default values

withPrintedOutput=true;
withBarGraph=false;
forcePrint=false;
includeMissing=true;
sortByFreq=false;
withWeights=false;
maxPrint=30; % if forcePrint==false


if(~isempty(varargin))
    varargin=checkVarargin(varargin);
    % Loading optional arguments
    while ~isempty(varargin)
        switch lower(varargin{1})
            case {'weights','w'}
                weights= varargin{2};
                withWeights=true;
            case {'withprintedoutput'}
                withPrintedOutput = varargin{2};
            case {'withbargraph','wb'}
                withBarGraph=varargin{2};
            case {'includemissing','im','m'}
                includeMissing=varargin{2};
            case {'sortbyfreq','sbf'}
                sortByFreq=varargin{2};
            case {'forceprint','fp'}
                forcePrint=varargin{2};
            case {'ommitnan','ommitmissing','on','om'}
                includeMissing=not(varargin{2});
            otherwise
                error(['Unexpected option: ' varargin{1}])
        end
        varargin(1:2) = [];
    end
end

if(withWeights)
    assert(all(weights-floor(weights)==0),'Weights must be frequency weights (i.e. integers)')
    vector=repelem(vector,weights);

end

isLogical=islogical(vector);
isNumeric=isnumeric(vector);
isCategorical=iscategorical(vector);
isCellstr=iscellstr(vector);
isString=isstring(vector);
isDatetime=isdatetime(vector);

classVector=class(vector);

if(isNumeric||isLogical)
    vector=reshape(full(double(vector)),numel(vector),1);
elseif(isCategorical||isCellstr||isString||isDatetime)
    vector=reshape(vector,numel(vector),1);
    % Saca categorias no usadas
    if(isCategorical)
        vector=removecats(vector);
    end
else
    error('What type is the vector????')
end


missings=ismissing(vector);
cantMissing=sum(missings);
anyNotMissing=any(not(missings));

if(anyNotMissing)
    vectorSinMissing=vector(not(missings));
    t=table;

    [preT1,~,~,preT2]=crosstab(vectorSinMissing);
    if(isNumeric)
        % Not doing that anymore. Displaying doubles as strings is way
        % better because it never converts to scientific notation.
        %preT2= str2double(preT2);
    elseif(isLogical)
        % No importa, pq no pueden haber NaNs en un logical
    end
    t.value=preT2;
    t.freq=preT1;

end

if(cantMissing>0&&includeMissing)
    tm=table;

    if(isNumeric)
        %tm.value=nan;
        tm.value={'NaN'};
    elseif(isCategorical)
        tm.value=categorical(1,0); % undefined!
        catsAux=categories(vector);
        tm.value=categorical(0,1:length(catsAux),catsAux,'ordinal',isordinal(vector)); % undefined!
        clearvars catsAux
    elseif(isCellstr)
        tm.value={''};
    elseif(isString)
        tm.value={''};
    elseif(isDatetime)
        tm.value={'NaT'};
    end

    tm.freq=cantMissing;
    if(anyNotMissing)
        t=[t;tm];
    else
        t=tm;
    end
end

if(includeMissing)
    N=length(vector);
else
    if(anyNotMissing)
        N=length(vectorSinMissing);
    else
        N=0;
    end
end

if(N>0)
    t.perc=t.freq/N;

    if(nargout>0)
        frec=t.freq;
    end
    if(nargout>1)
        unicos=t.value;
    end
    if(nargout>2)
        tabla=t;
    end

    if(withBarGraph)

        bar(categorical(t.value),t.freq)
    end


    if(withPrintedOutput)


        % Chequea q no sean muchos:
        cantUnique=height(t);

        if(cantUnique>maxPrint&&not(forcePrint))
            fprintf('\n')

            t_print=sortrows(t,{'freq','value'},{'descend','ascend'});
            t_print=t_print(t_print.freq>t_print.freq(31),:);
            %t_print=sortrows(t_print,'value');

            N_print=sum(t_print.freq);

            message=sprintf('Showing only %i out of %i unique values (%.1f%% obs, %s of %s)',height(t_print),cantUnique,sum(t_print.perc)*100,mat2cellstr(N_print,'rc',true),mat2cellstr(N,'rc',true));
            cprintf('[.8 0 0]','------------------------------------\n');
            cprintf('*[.8 0 0]','%s\n',message);

        else
            if(sortByFreq)
                t_print=sortrows(t,{'freq','value'},{'descend','ascend'});
            else
                t_print=t;
            end
        end

        t_print.cumPerc=cumsum(t_print.perc);
        t_print.perc=char(mat2cellstr(t_print.perc*100,'precision','%5.1f','sufijo','%'));
        t_print.cumPerc=char(mat2cellstr(t_print.cumPerc*100,'precision','%5.1f','sufijo','%'));
        maxLength=length(num2str(max(t_print.freq)));
        t_print.freq=char(mat2cellstr(t_print.freq,'precision',sprintf('%%%ii',1+maxLength)));
        fprintf('\n')
        disp(t_print)



        if(cantMissing>0&&not(includeMissing))
            fprintf('   Unique values: %s \t(+missing not included)\n',mat2cellstr(height(t),'rc',true));
            fprintf('               N: %s \t(+%s missings not included)\n\n',mat2cellstr(N,'rc',true),mat2cellstr(cantMissing,'rc',true));
        else
            fprintf('            Type: %s  \n',classVector);
            fprintf('   Unique values: %s  \n',mat2cellstr(height(t),'rc',true));
            fprintf('               N: %s\n\n',mat2cellstr(N,'rc',true));
        end

        if(cantUnique>maxPrint&&not(forcePrint))
            cprintf('*[.8 0 0]','%s\n',message);
            cprintf('[.8 0 0]','------------------------------------\n\n');
        end

    end
else
    if(nargout>0)
        frec=nan;
    end
    if(nargout>1)
        unicos=nan;
    end
    if(nargout>2)
        tabla=table;
    end
    fprintf('\n               N: 0 obs\n');
end

end






