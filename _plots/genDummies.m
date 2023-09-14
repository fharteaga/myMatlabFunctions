function [dummies,dummyLabels]=genDummies(x,varargin)
% GENDUMMIES generate dummies from the Nx1 vector x. Based on procedure of
% BINREG


nBins=10;
omitMissings=true; % Para las obs que son NaN llena los dummies con NaN tb.
withMissingWarningMessage=true;
binStrategy='quantile-spaced'; % 'equally-spaced' 'saturated' 'quantile-spaced' 'custom'
omitOneDummy=false;
posOmit=1; % Position of dummy to omit. If negative is from right to left.
printBins=true;
tabla={}; % In case it adds de dummies to the table.
dummyLabelPrefix='d_';
sparseDummies=false; % This is very helpful for large datasets
logicalDummies=false; % Only possible if there are not nans.
if(not(isa(x,'double')))
    x=double(x);
end


preB=nan; % This is the bin id for the "custom" binStrategy


if(~isempty(varargin))

    % This checks a few things, including if there is a struct called "opts"
    varargin=checkVarargin(varargin);
    while ~isempty(varargin)
        switch lower(varargin{1})
            case {'bs','binstrategy'}
                binStrategy = varargin{2};
            case {'nb','numberbins','nbins'}
                nBins = varargin{2};
            case {'preb'}
                preB = varargin{2};
            case{'omitone'}
                omitOneDummy= varargin{2};
            case{'withmissingwarningmessage'}
                withMissingWarningMessage= varargin{2};
            case{'posomit'}
                posOmit= varargin{2};
            case{'omitnans','omitmissings'}
                omitMissings=varargin{2};
            case{'printbins'}
                printBins=varargin{2};
            case{'table'}
                tabla=varargin{2};
            case{'dummylabelprefix'}
                dummyLabelPrefix=varargin{2};
            case{'sparsedummies','sparse'}
				sparseDummies = varargin{2};
			case{'logicaldummies','logical'}
				logicalDummies = varargin{2};

            otherwise
                error(['Unexpected option: ',varargin{1}])
        end
        varargin(1:2) = [];
    end
end



remove=any(ismissing(x),2);
if(any(remove))
    if(omitMissings)
        assert(not(logicalDummies),'If there are missings, output cannot be logical under "omitMissings" option')

        if(withMissingWarningMessage)
            cprintf('*systemcommand','[genDummies.m Unofficial Warning] ')
            cprintf('systemcommand','%.2f %% of observations (%i of %i) contain non-missing values \n',(1-mean(remove))*100,sum(not(remove)),length(remove))
        end
        x=x(not(remove),:);

    else
        error('%.2f %% of observations (%i of %i) contain missing values \n',(mean(remove))*100,sum((remove)),length(remove))
    end
end

nBinsOrig=nBins;


%% Bins

% For every column of x, I generate a preB (number asociated to a bin)

cantVars=size(x,2);
preBMatrix=nan(size(x,1),cantVars);
initalPreBNan=isnan(preB);
for v=1:cantVars


    x_=x(:,v);

    uniqueX=unique(x_);
    if(not(ismember(binStrategy,{'saturated','custom'}))&&length(uniqueX)<nBins)
        cprintf('*systemcommand','[binsreg.m Unofficial Warning] ')
        cprintf('systemcommand','Not enough dispertion in x to get %i bins (%i unique values). saturated strategy is used instead!\n',nBins,length(uniqueX))
        binStrategy='saturated';
    end


    switch binStrategy
        case 'quantile-spaced'
            assert(isnan(preB))
            qs=quantile(x_,nBins-1);

            %Check that there are enough dispertion on "x" to build "nBins" bins.
            while(length(unique(qs))<length(qs)&&nBins>2)
                nBins=nBins-1;
                qs=quantile(x_,nBins-1);
            end



            edges=[min(x_),qs,max(x_)];
            if(qs(1)==min(x_))
                preB=discretize(x_,edges,'includedEdge','right');

                if(qs(end)==max(x_))
                    edges=[min(x_),qs];
                    nBins=nBins-1;
                end
            else
                preB=discretize(x_,edges,'includedEdge','left');
            end

            if(nBins<nBinsOrig)

                cprintf('*systemcommand','[binsreg.m Unofficial Warning] ')
                cprintf('systemcommand','Not enough dispertion in x to get %i bins. %i bins are used instead!\n',nBinsOrig,nBins)
            end

        case 'equally-spaced'
            assert(isnan(preB))

            edges=linspace(min(x_),max(x_),nBins+1);
            preB=discretize(x_,edges,'includedEdge','left');



        case 'saturated'
            assert(isnan(preB))


            if(length(uniqueX)>max(nBins,30))
                warning('Estay seguro de generar más de 30 dummies??');
            end

            preB=nan(size(x_));
            for i=1:length(uniqueX)
                preB(x_==uniqueX(i))=i;
            end

            if(nargout>1||not(isempty(tabla)))
                dummyLabels=uniqueX;

                if(all(mod(dummyLabels,1)==0))
                    dummyLabels=cellfun(@(x)[dummyLabelPrefix,x],mat2cellstr(uniqueX,'wts',0),'UniformOutput',false);
                end
            end

        case 'custom'

            if(any(remove))
                preB=preB(not(remove));
            end
            assert(all(not(isnan(preB))))
            assert(all(size(preB)==size(x)))

            if(nargout>1||not(isempty(tabla)))
                dummyLabels=unique(preB);

                if(all(mod(dummyLabels,1)==0))
                    dummyLabels=cellfun(@(x)[dummyLabelPrefix,x],mat2cellstr(dummyLabels,'wts',0),'UniformOutput',false);
                end
            end

        otherwise
            error('There is not a bin strategy called "%s"',binStrategy)

    end


    preBMatrix(:,v)=preB;
    if(initalPreBNan)
        preB=nan;
    end
end

if(cantVars>1)
    tablePreB=combineDiscreteVars(preBMatrix,{},'output','table');
    preB=tablePreB.combined;
    uniqueX=unique(preB);
else
    preB=preBMatrix;
end

uniquePreB=unique(preB);
nBins=length(uniquePreB);

if(sparseDummies)

    indices1=cell(nBins,1);
    indices2=cell(nBins,1);
    for i=1:nBins
        indices1{i}=find(preB==uniquePreB(i));
        indices2{i}=repmat(i,length(indices1{i}),1);

    end
    indices1=vertcat(indices1{:});
    indices2=vertcat(indices2{:});

    if(logicalDummies)
        values=true(length(indices1),1);
    else
        values=ones(length(indices1),1);
        
    end
    b=sparse(indices1,indices2,values,size(x,1),nBins);
else

    if(logicalDummies)
        b=false(size(x,1),nBins);
    else
        b=nan(size(x,1),nBins);
    end

    for i=1:nBins
        b(:,i)=preB==uniquePreB(i);
    end
end
binsWithObs=sum(b,1)>0;

if(any(not(binsWithObs)))
    warning('%i de los %i bins no tiene observaciones',sum(not(binsWithObs)),length(binsWithObs))
end

b_withObs=b(:,binsWithObs);


if(any(remove))

    if(sparseDummies)
        error('Not implemented yet!')
    end
    b_withObsAux=nan(size(remove,1),size(b_withObs,2));
    b_withObsAux(not(remove),:)=b_withObs;
    b_withObs=b_withObsAux;
end

dummies=b_withObs;

if(omitOneDummy)
    assert(abs(posOmit)<=size(dummies,2)&&abs(posOmit)>=1);
    if(posOmit>0)
        dummies(:,posOmit)=[];
        if(nargout>1||not(isempty(tabla)))
            dummyLabels(posOmit)=[];
        end
    else
        dummies(:,end+posOmit+1)=[];
        if(nargout>1||not(isempty(tabla)))
            dummyLabels(end+posOmit+1)=[];
        end
    end

end
if(nargout>1||not(isempty(tabla)))
    assert(length(dummyLabels)==size(dummies,2))
    if(not(isempty(tabla)))

        for d=1:length(dummyLabels)
            tabla.(dummyLabels{d})=dummies(:,d);
        end
        dummies=tabla;
    end
end
% Describe strategy
if(printBins)
    fprintf('\nStrategy performed: %s. \nNBins: %i\n',binStrategy,nBins)
    switch binStrategy
        case {'quantile-spaced','equally-spaced'}
            fprintf('Edges:\t[ ')
            fprintf('%7.2f ',edges)
            fprintf(']\n')
            fprintf('N:\t[     ')
            fprintf('%7i ',sum(b,1))
            fprintf('    ]\n\n ')

        case 'saturated'

            fprintf('Edges:\t[ ')
            if(iscategorical(uniqueX))
                fprintf('%9s ',uniqueX)
            else
                fprintf('%9.2f ',uniqueX)
            end
            fprintf(']\n')
            fprintf('N:\t[')
            fprintf('%9i ',sum(b,1))
            fprintf(' ]\n\n ')
    end
end


