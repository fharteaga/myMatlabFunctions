function barOut=barmultiple(tabla,vars,varargin)

assert(istable(tabla))
assert(allunique(vars))
withNBar=false;
yTickLabel='';
thresholdAnnotation=.01;
horizontal=false;
ignoreMissings=true;
maxLabelXValue=20;

dispersionBarColors=.2;
sortByGreynessBarColors=true;

legendLocation='southoutside';

if(~isempty(varargin))
    % This checks a few things, including if there is a struct called "opts"
    varargin=checkVarargin(varargin);
    % Loading optional arguments
    while ~isempty(varargin)
        switch lower(varargin{1})
            case {'withnbar','wnb'}
                withNBar=varargin{2};
            case 'horizontal'
                horizontal = varargin{2};
            case 'thresholdannotation'
                thresholdAnnotation = varargin{2};
            case {'dispersion'}
                dispersionBarColors= varargin{2};
            case {'sortbygreyness'}
                sortByGreynessBarColors= varargin{2};
            case {'legendlocation'}
                legendLocation= varargin{2};
                
            otherwise
                error(['Unexpected option: ',varargin{1}])
        end
        varargin(1:2) = [];
    end
end

if(ignoreMissings)
% Check missings
ignore=any(ismissing(tabla(:,vars)),2);
    if(any(ignore))
        cprintf('*systemcommand','[barmultiple.m Unofficial Warning] ')
        cprintf('systemcommand','%.2f %% of obervations (%i of %i) are used in the plot\n',(1-mean(ignore))*100,sum(not(ignore)),length(ignore))
        tabla=tabla(not(ignore),:);
  
    end
end


cantVars=length(vars);
cantObs=nan(cantVars,1);
[~,~,bart]=tab(tabla.(vars{1}),'withprintedoutput',0,'m',0);
bart.Properties.VariableNames{'perc'}=sprintf('perc%i',1);
cantObs(1)=sum(bart.freq);
bart.freq=[];

for i=2:cantVars
    [~,~,bart_aux]=tab(tabla.(vars{i}),'withprintedoutput',0,'m',0);
    bart_aux.Properties.VariableNames{'perc'}=sprintf('perc%i',i);
    cantObs(i)=sum(bart_aux.freq);
    bart_aux.freq=[];
    bart=outerjoin(bart,bart_aux,'keys','value','mergekeys',true);
    
end

if(isnumeric(tabla.(vars{1})))
    bart.auxOrder=str2double(bart.value);
    bart=sortrows(bart,'auxOrder');
    bart.auxOrder=[];
end
if(iscategorical(tabla.(vars{1})))
    bart.auxOrder=categorical(bart.value,categories(tabla.(vars{1})),'ordinal',true); % Uses the order produces by "categories()" use "reordercats()" to get a new order
    bart=sortrows(bart,'auxOrder');
    bart.auxOrder=[];
end


if(not(isempty(tabla.Properties.VariableDescriptions)))
    labelVars=tabla.Properties.VariableDescriptions(vars);
    for v=1:cantVars
        if(isempty(labelVars{v})||length(labelVars{v})>maxLabelXValue)
            
            
            if(length(labelVars{v})>maxLabelXValue)
                cprintf('*systemcommand','[barmultiple.m Unofficial Warning] ')
                cprintf('systemcommand','The label for variable %s is too long (longer than %i: maxLableXValue)\n%s\n',vars{v},maxLabelXValue,labelVars{v})
            end
            labelVars{v}=replace(vars{v},'_',' ');
            
        end
        

    end
    
else
    labelVars=vars;
end


% Necessary multiple "vars" to keep the order.
xsBar=categorical(vars,vars,labelVars);

if(withNBar)
    tiledlayout(5,1);
    nexttile
    
    
    b=bar(xsBar,cantObs);
    set(gca,'xTick',[]);
    set(gca,'yTick',[]);
    b.FaceColor='none';
    colorHist=.3*[1 1 1];
    
    b.EdgeColor=colorHist;
    ylabel('N')
    for i=1:cantVars
        annotation2('textbox',[i,cantObs(i)],'S','String',mat2cellstr(cantObs(i),'rc',true),'FitBoxToText','on','Interpreter','latex','edgecolor','none','color',colorHist);
    end
    
    box off
    nexttile(2,[4 1])
end

if(horizontal)
    br=barh(xsBar,table2array(bart(:,2:end))','stacked', 'FaceColor','flat','FaceAlpha',0.9,'edgeColor','none');
else
    br=bar(xsBar,table2array(bart(:,2:end))','stacked', 'FaceColor','flat','FaceAlpha',0.9,'edgeColor','none');
end


[colorsBar,colorsAnnotation]=linspecerGrayproof(height(bart),'dispersion',dispersionBarColors,'sortByGreyness',sortByGreynessBarColors);
%colorsBar=rgb2gray(colorsBar);
for i=1:height(bart)
    br(i).CData = colorsBar(i,:);

end



for j=2:width(bart)
    percY=bart{:,j};
    for i=1:length(percY)
        
        if(percY(i)>thresholdAnnotation)
            if(horizontal)
                posAnnot=[sum(percY(1:(i-1)),'omitnan')+percY(i)/2,j-1];
            else
                posAnnot=[j-1,sum(percY(1:(i-1)),'omitnan')+percY(i)/2];
            end
            
            annotation2('textbox',posAnnot,'o','String',sprintf('%2.0f$\\%%$',percY(i)*100),'Interpreter','latex','edgecolor','none','color',colorsAnnotation(i,:));
        end
    end
    
end



if(isempty(yTickLabel))
    if(horizontal)
        xlabel('Fraction')
        set(gca,'xTick',[]);
        xlabel(yTickLabel);
        
    else
        ylabel('Fraction')
        set(gca,'yTick',[]);
        ylabel(yTickLabel);
    end
else
    if(horizontal)
        set(gca,'xTick',[]);
        xlabel(yTickLabel);
        
    else
        set(gca,'yTick',[]);
        ylabel(yTickLabel);
    end
end

textLegend=categorical(bart.value(end:-1:1));

lgd=legend(br(end:-1:1),textLegend,'location',legendLocation);

if(nargout>0)
    barOut=struct;
    barOut.colors=colorsBar;
    barOut.colorsAnnotation=colorsAnnotation;
end


%title(lgd,labelVarY)

