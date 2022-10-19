function [dummies]=genDummies(x,varargin)
% GENDUMMIES generate dummies from the Nx1 vector x. Based on procedure of
% BINREG


nBins=10;
ommitNans=true; % Para las obs que son NaN llena los dummies con NaN tb.
binStrategy='quantile-spaced'; % 'equally-spaced' 'saturated' 'quantile-spaced' 'custom'
ommitOneDummy=false;


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
            case{'ommitone'}
                ommitOneDummy= varargin{2};
            case{'ommitnans'}
                ommitNans=varargin{2};
            otherwise
                error(['Unexpected option: ',varargin{1}])
        end
        varargin(1:2) = [];
    end
end




remove=any(ismissing(x),2);
if(any(remove))
    if(ommitNans)


        cprintf('*systemcommand','[binsreg.m Unofficial Warning] ')
        cprintf('systemcommand','%.2f %% of obervations (%i of %i) contain non-missing values \n',(1-mean(remove))*100,sum(not(remove)),length(remove))
        x=x(not(remove),:);

    else
        error('%.2f %% of obervations (%i of %i) contain missing values \n',(mean(remove))*100,sum((remove)),length(remove))
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
    if(not(strcmp(binStrategy,'saturated'))&&length(uniqueX)<nBins)
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
                error('Estay seguro que queri plotear más de 30 obs?');
            end

            preB=nan(size(x_));
            for i=1:length(uniqueX)
                preB(x_==uniqueX(i))=i;
            end



        case 'custom'

            if(any(remove))
                preB=preB(not(remove));
            end
            assert(all(not(isnan(preB))))
            assert(all(size(preB)==size(y)))


        otherwise
            error('There is not a bin strategy called "%s"',binStrategy)

    end


    preBMatrix(:,v)=preB;
    if(initalPreBNan)
        preB=nan;
    end
end

if(cantVars>1)
    tablePreB=combineDiscreteVars(preBMatrix);
    preB=tablePreB.combined;
    uniqueX=unique(preB);
else
    preB=preBMatrix;
end

uniquePreB=unique(preB);
nBins=length(uniquePreB);

b=nan(size(x,1),nBins);
for i=1:nBins
    b(:,i)=preB==uniquePreB(i);
end
binsWithObs=sum(b,1)>0;

if(any(not(binsWithObs)))
    warning('%i de los %i bins no tiene observaciones',sum(not(binsWithObs)),length(binsWithObs))
end

b_withObs=b(:,binsWithObs);


if(any(remove))

    b_withObsAux=nan(size(remove,1),size(b_withObs,2));
    b_withObsAux(not(remove),:)=b_withObs;
    b_withObs=b_withObsAux;
end

if(ommitOneDummy)
    dummies=b_withObs(:,2:end);

else
    dummies=b_withObs;
end

% Describe strategy

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



