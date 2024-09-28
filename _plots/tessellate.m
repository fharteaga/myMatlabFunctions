function patchNum=tessellate(xData,yData,var,varargin)



latlon=true;
withMap=true;
tessellationType='hex'; % hex, sq, or tri
stat='count'; % Stat for stataCollapse!!
numFigures=20; % On the longer side
widthfigureMeters=nan; % This overrides numFigures. UTM distances are in meter!
showPlot=true;

if(nargin==2||isempty(var))
    var=ones(length(xData),1);
end

% Loading optional arguments
if(~isempty(varargin))
    assert(mod(length(varargin),2)==0,'Si agregai opciones, ponle el tipo!')

    while ~isempty(varargin)
        switch lower(varargin{1})
            case 'latlon'
                latlon = varargin{2};
                assert(islogical(varargin{2}))
            case 'withmap'
                withMap=varargin{2};
                assert(islogical(varargin{2}))
            case {'tessellationtype','t'}
                tessellationType=varargin{2};
            case {'stat'}
                stat=varargin{2};
            case {'numfigures','num'}
                numFigures=varargin{2};
            case {'showplot'}
                showPlot=varargin{2};
            case{'widthfiguremeters'}
				widthfigureMeters = varargin{2};

            otherwise
                error(['Unexpected option: ' varargin{1}])
        end
        varargin(1:2) = [];
    end
end


if(latlon)
   [xData,yData,utmstruct] = latLonToUTM(yData,xData);
end


dataTable=array2table([xData,yData,var],'VariableNames',{'x','y','var'});

x_i=[min(xData),max(xData)];
y_i=[min(yData),max(yData)];

if(isnan(widthfigureMeters))
    width=max(diff(x_i/numFigures),diff(y_i/numFigures));
else
    width=widthfigureMeters;
end


% Cool related stuff:
%https://www.mathworks.com/matlabcentral/answers/250353-how-to-colour-code-polygons-by-area


switch tessellationType
    case {'hex','hexagon'}
        % Adjusts:
        % (1) far limits have to be a multiple of the width
        % (2) add an extra width in every limit

        x=x_i/sin(pi/3);
        y=y_i;
        new_x=[x(1),x(1)+ceil((x(2)-x(1))/width)*width]+[-1,1]*width;
        new_y=[y(1),y(1)+round((y(2)-y(1))/width)*width]+[-1,1]*width;

        [X,Y] = meshgrid(new_x(1):width:new_x(2),new_y(1):width:new_y(2));
        X = sin(pi/3) * X;
        Y(:,2:2:end)=Y(:,2:2:end)+width/2;
        numVertices=6;
    case {'sq','square'}
        x=x_i;
        y=y_i;
        new_x=[x(1),x(1)+ceil((x(2)-x(1))/width)*width]+[-1,1]*width;
        new_y=[y(1),y(1)+round((y(2)-y(1))/width)*width]+[-1,1]*width;

        [X,Y] = meshgrid(new_x(1):width:new_x(2),new_y(1):width:new_y(2));
        numVertices=4;

    case {'tri','triangle'}
        width=width*2;
        x=x_i*2;
        y=y_i/sin(pi/3);

        new_x=[x(1),x(1)+ceil((x(2)-x(1))/width)*width]+[-1,1]*width;
        new_y=[y(1),y(1)+round((y(2)-y(1))/width)*width]+[-1,1]*width;

        [X,Y] = meshgrid(new_x(1):width:new_x(2),new_y(1):width:new_y(2));
        X=X/2;

        Y = sin(pi/3) *Y;
        auxY=repmat(2*eye(2,2)-1,ceil([size(Y,1)/2 size(Y,2)/2]));
        auxY=auxY(1:size(Y,1),1:size(Y,2))*1/2*width*(sin(pi/3)-tan(pi/6));
        Y=Y+auxY;
        numVertices=3;
end


factor=max([X(:);Y(:)]); % If not it gets "precision error"
[v,c]=voronoin([X(:),Y(:)]/factor);
posInf=find(any(v==inf,2));
relevants=cellfun(@(x)size(x,2)==numVertices&not(ismember(posInf,x)),c);
c=c(relevants); % Preserves only the relevant polygons
centX=X(relevants);
centY=Y(relevants);

%% Calculate where the points belong:


% Nearest point function:
patchNum = dsearchn([centX,centY],[xData,yData]);
if(showPlot)

    dataTable.patchNum=patchNum;
    plotValue=stataCollapse('patchNum',dataTable,'var',stat,'sortrows',true);
    plotValue.withObs=true(height(plotValue),1);
    auxTable=array2table((1:length(centX))','VariableNames',{'patchNum'});
    plotValue=outerjoin(auxTable,plotValue,'keys',{'patchNum'},'mergeKeys',true,'type','left');
    plotValue=sortrows(plotValue,'patchNum');

    assert(length(c)==height(plotValue));
    % Keep only patches withObservations
    c=c(plotValue.withObs);
    plotValue=plotValue(plotValue.withObs,:);


    if(latlon)
        % convert utm back
        [v(:,1),v(:,2)] = UTMtoLatLon(v(:,1)*factor,v(:,2)*factor,utmstruct);

    else
        v=v*factor;
        assert(not(withMap),'Cannot print map if cooridnates are not LAT LON')
    end


    patch('Faces',cell2mat(c),'Vertices',v,'FaceVertexCData',plotValue.var,'FaceColor','flat','FaceAlpha',.5,'EdgeColor',.5*[1 1 1])
    colorbar

    if(withMap)
        
        plotMap
    end
end


%%% Checks are that teselation is covering
% hold on
% scatter(centX,centY)
% daspect([1,1,1])
% realCoverX=[X(1,2),X(1,end-1)];
% realCoverY=[Y(2,1),Y(end-1,2)];
% patch([realCoverX,realCoverX(end:-1:1)],reshape([realCoverY;realCoverY],1,[]),1,'FaceColor','none')
% patch([x_i,x_i(end:-1:1)],reshape([y_i;y_i],1,[]),1,'FaceColor','none','edgecolor','r')
%xlim(x_i)
%ylim(y_i)
% hold off
