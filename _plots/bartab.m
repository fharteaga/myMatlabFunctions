function bartab(tabla,nameVarX,nameVarY,varargin)

horz=false; % en progreso, not ready yet
withNBar=false;
minPercentageToShow=.1;
includeAll=true;
withLegend=true;
withLegendTitle=true;
locLegend='';
%binary=false;
%binaryValue=1;

if(~isempty(varargin))
    % This checks a few things, also if there is struct called "opts"
    varargin=checkVarargin(varargin);
    % Loading optional arguments
    while ~isempty(varargin)
        switch lower(varargin{1})
            case 'horizontal'
                horz = varargin{2};
            case {'includeall','all'}
                includeAll = varargin{2};
            case {'withlegend','wl'}
                withLegend = varargin{2};
            case {'withlegendtitle','wlt'}
                withLegendTitle = varargin{2};
            case 'loclegend'
                locLegend = varargin{2};
            case {'minpercentagetoshow','mps'}
                minPercentageToShow = varargin{2};
            otherwise
                error(['Unexpected option: ' varargin{1}])
        end
        varargin(1:2) = [];
    end
end

% Check if there is more than one x:
if(iscellstr(nameVarX))

    if(length(nameVarX)==1)
        nameVarX=nameVarX{1};
    else
        [tabla,varNameCombined]=combineDiscreteVars(tabla,nameVarX);
        nameVarX=varNameCombined;
    end
end

varY=tabla.(nameVarY);
varX=tabla.(nameVarX);
if(iscellstr(varX)) %#ok<ISCLSTR>
    varX=categorical(varX);
end
notMissY=not(ismissing(varY));
notMissX=not(ismissing(varX));

varY=varY(notMissY&notMissX);
varX=varX(notMissY&notMissX);

if(any(not(notMissY&notMissX)))
            cprintf('*systemcommand','[bartab.m Unofficial Warning] ')
        cprintf('systemcommand','%.2f %% of obervations (%i of %i) are used in estimation\n',(mean(notMissY&notMissX))*100,sum((notMissY&notMissX)),length(notMissY&notMissX))
end


xs=unique(varX);
cantXs=length(xs);
assert(cantXs<15,sprintf('Too many unique values for X variable %s',nameVarX));



[~,~,bart]=tab(varY(varX==xs(1)),'withprintedoutput',0);
bart.Properties.VariableNames{'perc'}=sprintf('perc%i',1);
bart.freq=[];

for i=2:cantXs

    [~,~,bart_aux]=tab(varY(varX==xs(i)),'withprintedoutput',0);
    bart_aux.Properties.VariableNames{'perc'}=sprintf('perc%i',i);
    bart_aux.freq=[];
    bart=outerjoin(bart,bart_aux,'keys','value','mergekeys',true);

end

if(includeAll)
    [~,~,bart_aux]=tab(varY,'withprintedoutput',0);
    bart_aux.Properties.VariableNames{'perc'}=sprintf('percAll');
    bart_aux.freq=[];
    bart=outerjoin(bart,bart_aux,'keys','value','mergekeys',true);
end

% Order bart

if(isnumeric(varY))
    bart.auxOrder=str2double(bart.value);
    bart=sortrows(bart,'auxOrder');
    bart.auxOrder=[];
end

if(iscategorical(varY))
    bart.auxOrder=categorical(bart.value,categories(varY),'ordinal',true); % Uses the order produces by "categories()" use "reordercats()" to get a new order
    bart=sortrows(bart,'auxOrder');
    bart.auxOrder=[];
end


xsBar=categorical(xs);

% Remove irrelevant categories:
categoriesAux=categories(xsBar);
xsBar = removecats(xsBar,categoriesAux(not(ismember(categoriesAux,xsBar))));
if(includeAll)
    % Add category "all":
    xsBar = addcats(xsBar,'All');
    xsBar=[xsBar;categorical({'All'})];
end

if(withNBar)
    tiledlayout(5,1);
    nexttile

    if(horz)
        barh(1,ones(1,height(bart))/height(bart),'stacked', 'FaceColor','flat','FaceAlpha',1,'edgeColor','none');
        set(gca,'Visible','off')
        box off
    else
        [~,~,tableX]=tab(varX,'withprintedoutput',0);
        b=bar(xsBar,[tableX.perc;1]);
        set(gca,'xTick',[]);
        set(gca,'yTick',[]);
        b.FaceColor='none';
        b.EdgeColor=colorHist;

        percX=tableX.perc;
        for i=1:length(percX)
            annotation2('textbox',[i,percX(i)],'N','String',sprintf('%2.1f$\\%%$',percX(i)*100),'Interpreter','latex','edgecolor','none','color',colorHist);
        end

        annotation2('textbox',[i+1,1],'S','String',sprintf('N:%s ',mat2cellstr(length(varX),'rc',1)),'Interpreter','latex','edgecolor','none','color',colorHist);
        box off
    end

    nexttile(2,[4 1])

end


if(horz)
    if(includeAll)
        xticksPos=1:(length(xsBar)-1);
        xticksPos=[xticksPos,max(xticksPos)+1.4];
    else
        xticksPos=1:length(xsBar);
    end

    br=barh(xticksPos,table2array(bart(:,2:end))','stacked', 'FaceColor','flat','FaceAlpha',0.9,'edgeColor','none');
    yticks(xticksPos)
    yticklabels(xsBar)
    set(gca, 'YDir','reverse')
    set(gca, 'XDir','reverse')

else

    if(includeAll)
        xticksPos=1:(length(xsBar)-1);
        xticksPos=[xticksPos,max(xticksPos)+1.4];
    else
        xticksPos=1:length(xsBar);
    end

    br=bar(xticksPos,table2array(bart(:,2:end))','stacked', 'FaceColor','flat','FaceAlpha',0.9,'edgeColor','none');
    xticks(xticksPos)
    xticklabels(xsBar)
    % Add a line that separates total??
end

[colorsBar,colorsAnnotation]=linspecerGrayproof(height(bart),'dispersion',.2);
for i=1:height(bart)
    br(i).CData = colorsBar(i,:);
end
for j=2:width(bart)
    percY=bart{:,j};
    for i=1:length(percY)
        if(percY(i)>minPercentageToShow)
            if(horz)
        annotation2('textbox',[sum(percY(1:(i-1)))+percY(i)/2,xticksPos(j-1)],'o','String',sprintf('%2.0f$\\%%$',percY(i)*100),'Interpreter','latex','edgecolor','none','color',colorsAnnotation(i,:));
 
            else
            annotation2('textbox',[xticksPos(j-1),sum(percY(1:(i-1)))+percY(i)/2],'o','String',sprintf('%2.0f$\\%%$',percY(i)*100),'Interpreter','latex','edgecolor','none','color',colorsAnnotation(i,:));
            end
        end
    end
end



%legend(br,categorical(bart.value))
if(not(isempty(tabla.Properties.VariableDescriptions)))
    labelVarX=tabla.Properties.VariableDescriptions{nameVarX};
    if(isempty(labelVarX))
        labelVarX=nameVarX;
    end
    labelVarY=tabla.Properties.VariableDescriptions{nameVarY};
    if(isempty(labelVarY))
        labelVarY=nameVarY;
    end
else
    labelVarX=nameVarX;
    labelVarY=nameVarY;
end
if(horz)
    ylabel(labelVarX)
    xlabel('Fraction')
    set(gca,'xTick',[]);
else
    xlabel(labelVarX)
    ylabel('Fraction')
    set(gca,'yTick',[]);
end

textLegend=categorical(bart.value(end:-1:1));
maxLength=max(cellfun(@length,categories(textLegend)));

if(withLegend)
if(isempty(locLegend))
    if(maxLength<20)
        locLegend='eastoutside';
        locLegend='southoutside';
    else
        locLegend='southoutside';
    end
end

lgd=legend(br(end:-1:1),textLegend,'location',locLegend); % southoutside eastoutside
if(withLegendTitle)
title(lgd,labelVarY)
end
end



