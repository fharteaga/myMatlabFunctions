function barmultipleBinaria(tabla,vars,value,yTickLabel,varargin)
% "value" defines the value to count as binary (Ex: 1, or 'Yes')

assert(allunique(vars))
%yTickLabel='';
withNBar=false;

horizontal=false;
thresholdAnnotation=0.01;
[colorBar,colorAnnotation]=linspecerGrayproof(1,'dispersion',0);
withSuppliedColorAnotation=false;
withSuppliedColorBar=false;

% Loading optional arguments
while ~isempty(varargin)
    switch lower(varargin{1})
        case 'horizontal'
            horizontal = varargin{2};
        case 'colorbar'
            withSuppliedColorBar=true;
            colorBar=varargin{2};
        case 'colorannotation'
            withSuppliedColorAnotation=true;
            colorAnnotation=varargin{2};
        otherwise
            error(['Unexpected option: ' varargin{1}])
    end
    varargin(1:2) = [];
end


if(not(withSuppliedColorAnotation)&&withSuppliedColorBar)
    if(mean(rgb2gray(colorBar),2)>.5)
        colorAnnotation=0*[1 1 1];
    else
        colorAnnotation=1*[1 1 1];
    end
end

cantVars=length(vars);
cantObs=nan(cantVars,1);
percs=nan(cantVars,1);

for i=1:cantVars
    notMissing=not(ismissing(tabla.(vars{i})));
    cantObs(i)=sum(notMissing);
    if(iscellstr(tabla.(vars{i}))) %#ok<ISCLSTR>
        percs(i)=mean(strcmp(tabla.(vars{i})(notMissing),value));
    else
        percs(i)=mean(tabla.(vars{i})(notMissing)==value);
    end
    
end


if(not(isempty(tabla.Properties.VariableDescriptions)))
    labelVars=tabla.Properties.VariableDescriptions(vars);
    for v=1:cantVars
        if(isempty(labelVars{v}))
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
    colorPerc=1*[1 1 1];
    b.EdgeColor=colorHist;
    ylabel('N')
    
    for i=1:cantVars
        annotation2('textbox',[i,cantObs(i)],'S','String',mat2cellstr(cantObs(i),'rc',true),'FitBoxToText','on','Interpreter','latex','edgecolor','none','color',colorHist);
    end
    
    box off
    nexttile(2,[4 1])
end


if(horizontal)
    barh(xsBar,percs, 'FaceColor',colorBar,'FaceAlpha',1,'edgeColor','none');
else
    bar(xsBar,percs, 'FaceColor',colorBar,'FaceAlpha',1,'edgeColor','none');
end



for i=1:cantVars
    if(percs(i)>=thresholdAnnotation)
        if(horizontal)
            posAnnot=[percs(i)/2,i];
        else
            posAnnot=[i,percs(i)/2];
        end
        annotation2('textbox',posAnnot,'o','String',sprintf('%2.0f$\\%%$',percs(i)*100),'Interpreter','latex','edgecolor','none','color',colorAnnotation);
    end
    
end




%xlabel('var x')

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
%
% textLegend=categorical(bart.value(end:-1:1));
% maxLength=max(cellfun(@length,categories(textLegend)));
% if(maxLength<20)
%     locLegend='eastoutside';
%     locLegend='southoutside';
% else
%     locLegend='southoutside';
% end
%
% lgd=legend(br(end:-1:1),textLegend,'location',locLegend);
% %title(lgd,labelVarY)

