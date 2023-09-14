function alluvialflow(data,varargin)
% Copyright 2018 The MathWorks, Inc.
%
% Plot an alluvial flow diagram.
% left_labels:  Names of categories to flow from.
% right_labels: Names of categories to flow to.
% data:         Matrix with size numel(left_labels) rows by
%               numel(right_labels) columns.
%
% Ideas for future work:
% 1. Get data from a MATLAB table, use table variable names and named rows
%    as labels.
% 2. Interface similar to the plot function, with name-value pairs, optional
%    parameters etc.

% [FELIPE] I made a many modifications over the original mFile

horizontalLabels=true;

minPercToPlot=0.05;

fontSizeCondPerc=9;

invertYAxis=true;
precisionCondPerc='%2.2f';
axisForPlot={};

withUncondPerc=true;
withUncondN=false;
fontUncondNumbers=12;

withCondN=true;
withCondPerc=true;


% (1-transparency) of flows
alphaFlow=.5;

widthCatBar=3;
colorCatBar=[1 1 1]*0.3;
spaceForUnconditionalNumbers=.06;
% In case labels don't fit well:
extraSpaceRight=0;
extraSpaceLeft=0;

leftLabels=arrayfun(@(x)sprintf('varL%i',x),1:size(data,1),'UniformOutput',false);
rightLabels=arrayfun(@(x)sprintf('varR%i',x),1:size(data,2),'UniformOutput',false);

fontValueLabels=12;

leftVarLabel='varL';
rightVarLabel='varR';
centerLabel='';

if(~isempty(varargin))
    % This checks a few things, including if there is a struct called "opts"
    varargin=checkVarargin(varargin);
    
    while ~isempty(varargin)
        switch lower(varargin{1})
            case 'horizontallabels'
                horizontalLabels = varargin{2};
            case {'leftlabels','ll'}
                leftLabels = varargin{2};
            case {'rightlabels','rl'}
                rightLabels = varargin{2};
            case {'leftvarlabel','lvl'}
                leftVarLabel = varargin{2};
            case {'rightvarlabel','rvl'}
                rightVarLabel = varargin{2};
            case {'centerlabel','cl'}
                centerLabel = varargin{2};
            case {'invertyaxis'}
                invertYAxis= varargin{2};
            case {'precisioncondperc'}
                precisionCondPerc= varargin{2};
            case {'withcondn'}
                withCondN= varargin{2};
            case {'withcondperc'}
                withCondPerc= varargin{2};
            case {'withuncondn'}
                withUncondN= varargin{2};
            case {'withuncondperc'}
                withUncondPerc= varargin{2};
            case {'minperctoplot'}
                minPercToPlot= varargin{2};
            case{'extraspaceright'}
                extraSpaceRight= varargin{2};
            case{'extraspaceleft'}
                extraSpaceLeft= varargin{2};
            case{'axisforplot'}
                axisForPlot= varargin{2};
            case{'spaceforunconditionalnumbers'}
                spaceForUnconditionalNumbers= varargin{2};
            case{'fontvaluelabels'}
                fontValueLabels= varargin{2};
			case{'fontuncondnumbers'}
				fontUncondNumbers = varargin{2};
                
            otherwise
                error(['Unexpected option: ' varargin{1}])
        end
        varargin(1:2) = [];
    end
end


maxLengthRightVar=max(cellfun(@max,rightLabels));
if(maxLengthRightVar>4)
    extraSpaceRight=max([(maxLengthRightVar-4)*.001,extraSpaceRight]);
end

minCondPercToPlot=minPercToPlot;

if(not(withUncondPerc)&&not(withUncondN))
    spaceForUnconditionalNumbers=0;
else
    widthCatBar=.5;
    colorCatBar=[1 1 1]*.5;
end

%h = gcf;
%clf
% set(h, 'WindowStyle', 'Docked'); % DBG this helps reuse desktop space
if(isempty(axisForPlot))
    axisForPlot=gca;
end
cla(axisForPlot)

% Find axis dimensions and set them
data_sum = sum(data(:));
total_gap = 0.10 * data_sum;
left_gap_size = total_gap / (size(data, 1)-1);
right_gap_size = total_gap / (size(data, 2)-1);
y_height = data_sum + total_gap;
x_left = 0-spaceForUnconditionalNumbers-extraSpaceLeft;
x_right = 1+spaceForUnconditionalNumbers+extraSpaceRight;
axis(axisForPlot,[x_left, x_right, 0, y_height]) % Set limits



if(invertYAxis)
    axis(axisForPlot,'ij')% origin is top left
end

% grid minor % DBG

hold(axisForPlot,'on')
%patch([0 0 1 1], [0 y_height y_height 0], 'w');

% Plot left categories - one per row
left_category_sizes = sum(data, 2)';

% These are the top points for each left category,
% with gaps added.
left_category_points = [0 cumsum(left_category_sizes)] + ...
    (0:numel(left_category_sizes)) .* left_gap_size;
left_category_points(end) = [];
if(isnan(left_category_points))
    left_category_points=0;
end

% plot left category bars
plot(axisForPlot,zeros(2, numel(left_category_points)), [left_category_points; (left_category_points + left_category_sizes)], 'color',colorCatBar, 'LineWidth',widthCatBar);

% DBG plot left ticks
%left_category_tick_starts = zeros(size(left_category_points)) - 0.01;
%left_category_tick_ends = left_category_tick_starts + 0.02;
%plot([left_category_tick_starts; left_category_tick_ends], ...
%     [left_category_points; left_category_points], 'b-');

% Plot right categories - one per column
right_category_sizes = sum(data, 1);

% These are the top points for each right category,
% with gaps added.
right_category_points = [0 cumsum(right_category_sizes)] + ...
    (0:numel(right_category_sizes)) .* right_gap_size;
right_category_points(end) = [];
if(isnan(right_category_points))
    right_category_points=0;
end

% plot right category bars
plot(axisForPlot,ones(2, numel(right_category_points)), [right_category_points; (right_category_points + right_category_sizes)], 'color',colorCatBar, 'LineWidth',widthCatBar);

if(withUncondPerc||withUncondN)


    % Outer-sides
    plot(axisForPlot,ones(2, numel(left_category_points))*(0-spaceForUnconditionalNumbers), [left_category_points; (left_category_points + left_category_sizes)], 'color',colorCatBar, 'LineWidth',widthCatBar);
    plot(axisForPlot,ones(2, numel(right_category_points))*(1+spaceForUnconditionalNumbers), [right_category_points; (right_category_points + right_category_sizes)], 'color',colorCatBar, 'LineWidth',widthCatBar);


    % Top and bottom
    leftYCorners=[left_category_points; (left_category_points + left_category_sizes)];
    rightYCorners=[right_category_points; (right_category_points + right_category_sizes)];

    plot(axisForPlot,[ones(1, 2*numel(left_category_points))*(0-spaceForUnconditionalNumbers);ones(1, 2*numel(left_category_points))*(0)], repmat(reshape(leftYCorners,1,[]),2,1), 'color',colorCatBar, 'LineWidth',widthCatBar);
    plot(axisForPlot,[ones(1, 2*numel(right_category_points))*(1+spaceForUnconditionalNumbers);ones(1, 2*numel(right_category_points))*(1)], repmat(reshape(rightYCorners,1,[]),2,1), 'color',colorCatBar, 'LineWidth',widthCatBar);



end


%     DBG plot right ticks
%     right_category_tick_ends = ones(size(right_category_points)) + 0.01;
%     right_category_tick_starts = right_category_tick_ends - 0.02;
%     plot([right_category_tick_starts; right_category_tick_ends], ...
%         [right_category_points; right_category_points], 'b-');

%
% Draw the patches, an entire left category at a time
%

% Color selection

patch_colors=linspecer(size(data,1));
num_colors = size(patch_colors, 1);

right_columns_so_far = right_category_points(1:end); % Start at the beginning of each right category and stack as we go.
patches_per_left_category = size(data, 2);
for k_left = 1:size(data, 1) % for each row
    color = patch_colors(mod(k_left,num_colors)+1, :);

    %
    % Calculate the coordinates for all the patches split by the
    % current left category
    %

    % Split the left category
    left_patch_points = [0 cumsum(data(k_left, :))] + left_category_points(k_left);
    patch_top_lefts = left_patch_points(1:end-1);
    patch_bottom_lefts = left_patch_points(2:end);

    % Compute and stack up slice of each right category
    patch_top_rights = right_columns_so_far;
    patch_bottom_rights = patch_top_rights + data(k_left, :);
    right_columns_so_far = patch_bottom_rights;

    %
    % Plot the patches
    %

    % X coordinates of patch corners
    [bottom_curves_x, bottom_curves_y] = get_curves(0.1, patch_bottom_lefts, 0.9, patch_bottom_rights);
    [top_curves_x,    top_curves_y]    = get_curves(0.9, patch_top_rights,   0.1, patch_top_lefts);
    X = [ ...
        repmat([0; 0], 1, patches_per_left_category); % Top left, bottom left
        bottom_curves_x;
        repmat([1; 1], 1, patches_per_left_category); % Bottom right, top right
        top_curves_x
        ];


    % Y coordinates of patch corners
    Y = [ ...
        patch_top_lefts;
        patch_bottom_lefts;
        bottom_curves_y;
        patch_bottom_rights;
        patch_top_rights;
        top_curves_y
        ];

    patch(axisForPlot,'XData', X, 'YData', Y, 'FaceColor', color, 'FaceAlpha', alphaFlow, 'EdgeColor', 'none');
end % for each row



if(horizontalLabels)
    rotation=0;
    horizontalAll_L='right';
    horizontalAll_R='left';
    verticalAll_R='middle';
    verticalAll_L='middle';
else
    rotation=90;
    horizontalAll_L='center';
    horizontalAll_R='center';
    verticalAll_R='top';
    verticalAll_L='bottom';
end

% Place left labels
spaceGraphLabels=0.03;

xL=zeros(1, size(data, 1));
yL=left_category_points + left_category_sizes./2;
text(axisForPlot,xL-spaceGraphLabels-spaceForUnconditionalNumbers, ...
    yL, ...
    leftLabels, 'FontSize', fontValueLabels, 'HorizontalAlignment', horizontalAll_L, 'VerticalAlignment', verticalAll_L, 'Rotation', rotation);

% Place right labels
xR=ones(1, size(data, 2));
yR=right_category_points + right_category_sizes./2;
text(axisForPlot,xR+spaceGraphLabels+spaceForUnconditionalNumbers, ...
    yR,...
    rightLabels, 'FontSize', fontValueLabels, 'HorizontalAlignment', horizontalAll_R, 'VerticalAlignment', verticalAll_R, 'Rotation', rotation);

if(withUncondPerc||withUncondN)
    percLNumOrig=sum(data,2)./sum(data,'all');
    valueL=sum(data,2);
    percLNum=percLNumOrig;
    omitL=percLNum<minPercToPlot;
    percLNum(omitL)=nan;
    

    percRNumOrig=sum(data,1)./sum(data,'all');
    valueR=sum(data,1);
    percRNum=percRNumOrig;
    omitR=percRNum<minPercToPlot;
    percRNum(omitR)=nan;
if(withUncondPerc&&withUncondN)
    numL=cellfun(@(x,y)sprintf('%2.2f\t[N: %i]',x,y),num2cell(percLNum),num2cell(valueL),'UniformOutput',false);
    numR=cellfun(@(x,y)sprintf('%2.2f\t[N: %i]',x,y),num2cell(percRNum),num2cell(valueR),'UniformOutput',false);
    numL=cellfun(@removeZeroFromLeft,numL,'UniformOutput',false);
    numR=cellfun(@removeZeroFromLeft,numR,'UniformOutput',false);
elseif(withUncondPerc)
    numL=mat2cellstr(percLNum,'precision','%2.2f');
    numR=mat2cellstr(percRNum,'precision','%2.2f');
    numL=cellfun(@removeZeroFromLeft,numL,'UniformOutput',false);
    numR=cellfun(@removeZeroFromLeft,numR,'UniformOutput',false);
elseif(withUncondN)
        numL=mat2cellstr(valueL,'precision','%i');
    numR=mat2cellstr(valueR,'precision','%i');

end

    %     percL=mat2cellstr(sum(data,2)./sum(data,'all')*100,'precision','%.0f','sufijo','%');
    %     percR=mat2cellstr(sum(data,1)./sum(data,'all')*100,'precision','%.0f','sufijo','%');

    % Unconditional percentages, LEFT:



    text(axisForPlot,xL-spaceForUnconditionalNumbers/2, ...
        yL, ...
        numL, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'Rotation', 0,'color',[1 1 1]*.3,'fontsize',fontUncondNumbers);


    text(axisForPlot,xR+spaceForUnconditionalNumbers/2, ...
        yR,...
        numR, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'Rotation', 0,'color',[1 1 1]*.3,'fontsize',fontUncondNumbers);
end
if(withCondN||withCondPerc)

    % Conditional percentages LEFT
    for v=1:size(data,1)

        values=(data(v,data(v,:)>0)./sum(data(v,:)));
        valuesN=data(v,data(v,:)>0);
        bordersC=[leftYCorners(1,v),leftYCorners(1,v)+cumsum(values)*diff(leftYCorners(:,v))];
        yLC=mean([bordersC(1:end-1);bordersC(2:end)],1);

        if(numel(bordersC)>2)
            plot(axisForPlot,repmat([0;0.11],1,numel(bordersC)-2),repmat(bordersC(2:end-1),2,1),'color',[1 1 1]*.5,'linestyle',':')
        end

        omit=values*percLNumOrig(v)<minCondPercToPlot;
        values(omit)=nan;
        valuesN(omit)=nan;


        if(withCondPerc)
            percL=mat2cellstr(values,'precision',precisionCondPerc);
            percL=cellfun(@removeZeroFromLeft,percL,'UniformOutput',false);
        end
        if(withCondN)
            valuesN=mat2cellstr(valuesN);
        end

        if(withCondN&&withCondPerc)
            numL=cellfun(@(x,y)sprintf('%s\t[N: %s]',x,y),percL,valuesN,'UniformOutput',false);

        elseif(withCondN)
            numL=valuesN;

        elseif(withCondPerc)
            numL=percL;

        end


        numL(omit)={''};

        text(axisForPlot,repmat(xL(1),1,numel(yLC))+0.01, ...
            yLC, ...
            numL, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle', 'Rotation', 0,'FontSize',fontSizeCondPerc,'color',[1 1 1]*.3);

    end
    % Conditional percentages RIGHT
    for v=1:size(data,2)

        values=(data(data(:,v)>0,v)./sum(data(:,v)));
        valuesN=data(data(:,v)>0,v);
        bordersC=[rightYCorners(1,v),rightYCorners(1,v)+cumsum(values')*diff(rightYCorners(:,v))];
        yRC=mean([bordersC(1:end-1);bordersC(2:end)],1);



        omit=values*percRNumOrig(v)<minCondPercToPlot;
        values(omit)=nan;
        valuesN(omit)=nan;

        if(withCondPerc)
            percR=mat2cellstr(values,'precision',precisionCondPerc);
            percR=cellfun(@removeZeroFromLeft,percR,'UniformOutput',false);
        end
        if(withCondN)
            valuesN=mat2cellstr(valuesN);
        end

        if(withCondN&&withCondPerc)
            numR=cellfun(@(x,y)sprintf('%s\t[N: %s]',x,y),percR,valuesN,'UniformOutput',false);

        elseif(withCondN)
            numR=valuesN;

        elseif(withCondPerc)
            numR=percR;

        end

        if(withCondN||withCondPerc)
            numR(omit)={''};

            text(axisForPlot,repmat(xR(1),1,numel(yRC))-0.01, ...
                yRC,...
                numR, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle', 'Rotation', 0,'FontSize',fontSizeCondPerc,'color',[1 1 1]*.3);
        end
    end
end



axis(axisForPlot,'off')

if(invertYAxis)
    ylab=y_height*1.01;
    veAlig='Top';
else
    ylab=0-y_height*.01;
    veAlig='Top';
end

text(axisForPlot,0-spaceForUnconditionalNumbers, ...
    ylab, ...
    leftVarLabel, 'HorizontalAlignment', 'left', 'VerticalAlignment', veAlig, 'Rotation', 0,'FontSize',12,'FontWeight','bold');
text(axisForPlot,1+spaceForUnconditionalNumbers, ...
    ylab, ...
    rightVarLabel, 'HorizontalAlignment', 'right', 'VerticalAlignment', veAlig, 'Rotation', 0,'FontSize',12,'FontWeight','bold');



text(axisForPlot,.5, ...
    ylab, ...
    centerLabel, 'HorizontalAlignment', 'center', 'VerticalAlignment', veAlig, 'Rotation', 0,'color',[1 1 1]*.3);

hold(axisForPlot,'off')
%title(chart_title);
end % alluvialflow

function [x, y] = get_curves(x1, y1, x2, y2)
% x1, x2: scalar x coordinates of line start, end
% y1, y2: vectors of y coordinates of line start/ends
Npoints = 30;
t = linspace(0, pi, Npoints);
c = (1-cos(t))./2; % Normalized curve

Ncurves = numel(y1);
% Starting R2016b, the following line could be written simply as:
y = y1 + (y2 - y1) .* c';
%y = repmat(y1, Npoints, 1) + repmat(y2 - y1, Npoints,1) .* repmat(c', 1, Ncurves);
x = repmat(linspace(x1, x2, Npoints)', 1, Ncurves);
end  % get_curve

function noZero=removeZeroFromLeft(input)
if(not(isempty(input)))
    if(input(1)=='0')
        noZero=input(2:end);
    elseif(strcmp(input(1:3),'1.0'))
        noZero='1.0';
    else
        error('acá!')
    end
else
    noZero=input;
end

end