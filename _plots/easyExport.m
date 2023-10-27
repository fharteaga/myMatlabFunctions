function res=easyExport(file,varargin)

% Requires:
% \usepackage[capposition=top]{floatrow} % pa las notas!

% Use scale=.9!:  includegraphics[scale=.9]{fig.png}
% Width of 15 is great for margins=4cm

%{

opts=struct;
opts.width=400;
opts.height=200;
opts.caption='';
opts.note='';
opts.label='';
opts.latexScale=.9;
opts.includeRelativePath=true;
opts.externalRelativePath='';
easyExport([dirFigures,file],'opts',opts)

%}

    
    

width=400;
height=200;
withGca=false;
withGcf=false;

noAxisChange=false; % Doesn't make sense to have if it's a subplot or tiledlayout, set it to true if that is the case
displayLatex=true;
caption='';
note='';
label='';
latexScale=.7;
updatelegend=true;
includeRelativePath=false;
includeExternalRelativePath=false;
externalRelativePath='';
changeYTickFormat=false;
yTickFormat='';
yTickThousands=false;
changeXTickFormat=false;
xTickFormat='';
xTickThousands=false;
export=true;

colorspace='rgb'; % 'rgb' or 'gray'
resolution=300;
format='png'; % eps or png



if(~isempty(varargin))
    
varargin=checkVarargin(varargin);

% Loading optional arguments
while ~isempty(varargin)
    switch lower(varargin{1})
        case {'width','w'}
            width = varargin{2};
            assert(isnumeric(varargin{2}))
        case {'height','h'}
            height=varargin{2};
            assert(isnumeric(varargin{2}))
        case 'gca'
            withGca=true;
            gca_=varargin{2};
        case 'gcf'
            withGcf=true;
            gcf_=varargin{2};
        case 'noaxischange'
            noAxisChange=varargin{2};
        case 'displaylatex'
            displayLatex=varargin{2};
        case {'caption','title'}
            caption=varargin{2};
        case 'note'
            note=varargin{2};
        case 'label'
            label=varargin{2};
        case {'includerelativepath','irp'}
            includeRelativePath=varargin{2};
        case 'latexscale'
            latexScale=varargin{2};
        case 'updatelegend'
            updatelegend=varargin{2};
        case 'ytickformat'
            changeYTickFormat=true;
            yTickFormat=varargin{2};
        case {'ytickthousands','ytickt'}
            yTickThousands=varargin{2}; 
        case 'xtickformat'
            changeXTickFormat=true;
            xTickFormat=varargin{2};
        case {'xtickthousands','xtickt'}
            xTickThousands=varargin{2};
        case {'externalrelativepath','erp'}
            externalRelativePath=varargin{2};
            if(~isempty(externalRelativePath))
                includeExternalRelativePath=true;
            end
        case {'colorspace'}
            colorspace=varargin{2};
        case {'format'}
            format=varargin{2};
        otherwise
            error(['Unexpected option: ' varargin{1}])
    end
    varargin(1:2) = [];
end
end
if(nargin==0)
    file=dirBasura;
elseif(isempty(file))
    export=false;
end

assert(not(includeExternalRelativePath)||not(includeRelativePath))

assert(not(changeYTickFormat)||not(yTickThousands))
assert(not(changeXTickFormat)||not(xTickThousands))
if(not(withGca))
    gca_=gca;
end
if(not(withGcf))
    gcf_=gcf;
end

origPos=get(gcf_,'Position');
set(gcf_,'Position',[origPos(1) origPos(2) 0 0]+[0 0 width height])
set(gcf_, 'PaperPosition', [0 0 width height]); %


if(changeYTickFormat)
    ytickformat(yTickFormat);
end
if(yTickThousands)
    gca_.YAxis.Exponent=0;  % don't use exponent
    gca_.YRuler.TickLabelFormat = '%,.0f'; % Commas to thousands
end

if(changeXTickFormat)
    xtickformat(xTickFormat);
end
if(xTickThousands)
    gca_.XAxis.Exponent=0;  % don't use exponent
    gca_.XRuler.TickLabelFormat = '%,.0f'; % Commas to thousands
end

    
if(~noAxisChange)
   
    
    %set(gca_,'fontname','times')
    
    % Look for acentos:
    out={'á','é','í','ó','ú','ñ','º'};
    in={'\''a','\''e','\''i','\''o','\''u','\~n','$^{\circ}$'};
    

    xticklabels(replace(xticklabels,[out,upper(out)],[in,upper(in)]));
    yticklabels(replace(yticklabels,[out,upper(out)],[in,upper(in)]));
    xlabel(replace(get(get(gca_,'xlabel'),'string'),[out,upper(out)],[in,upper(in)]));
    ylabel(replace(get(get(gca_,'ylabel'),'string'),[out,upper(out)],[in,upper(in)]));
    title(replace(get(get(gca_,'title'),'string'),[out,upper(out)],[in,upper(in)]));
    subtitle(replace(get(get(gca_,'subtitle'),'string'),[out,upper(out)],[in,upper(in)]));
    
    set(findall(gcf_, 'Type', 'Text'),'Interpreter', 'Latex')
    if(updatelegend)

        hLeg=findobj(gcf_,'type','legend');
        if(not(isempty(hLeg)))
            hLeg.String=replace( hLeg.String,[out,upper(out)],[in,upper(in)]);
            set(legend,'interpreter','latex')
        end
    end
    
    % Check if is TitledChartLayaout
    if(isa(get(gcf_,'Children'),'matlab.graphics.layout.TiledChartLayout'))
        axiss=get(get(gcf_,'Children'),'Children');
        for a=1:length(axiss)
            if(isprop(axiss(a),'TickLabelInterpreter'))
                set(axiss(a),'TickLabelInterpreter','latex');
            end
        end
    else
        if(isprop(gca_,'TickLabelInterpreter'))
            set(gca_,'TickLabelInterpreter','latex');
        end
    end
    %set(gca_, 'LooseInset', [0,0,0,0]);
end

if(export)
if(not(endsWith(file,['.',format])))
   file= sprintf('%s.%s',file,format);
end
if(strcmpi(format,'eps'))
contentType='vector';
else
contentType='auto';
    
end
exportgraphics(gcf_,file,'Resolution',resolution,'colorspace',colorspace,'contentType',contentType);
if(displayLatex||nargout>0)
    
    
    matSpecial={'[','$[$';...
        ']','$]$';...
        '%','\%';...
        '>=','$\geq$';...
        '<=','$\leq$';...
        '<','$<$';...
        '>','$>$';...
        '_','\_';...
        '|','$|$';...
        '..comment..','%'};
    
    for i=1:size(matSpecial,1)
        note=strrep(note,matSpecial{i,1},matSpecial{i,2});
        caption=strrep(caption,matSpecial{i,1},matSpecial{i,2});
    end
    
    
    pos=strfind(file,'/');
    
    if(~isempty(pos))
        if(includeRelativePath)
            newPos=pos(pos<(pos(end)-1)); % Ve si hay otro "/" (q no está pegado al anterior)
            if(~isempty(newPos))
                file1=file(newPos(end)+1:end);
            else
                file1=file;
            end
        else
            if(includeExternalRelativePath)
                if(not(endsWith(externalRelativePath,'/')))
                    externalRelativePath= sprintf('%s/',externalRelativePath);
                end
                file1=[externalRelativePath,file(pos(end)+1:end)];
            else
            file1=file(pos(end)+1:end);
            end
        end
    else
        if(includeExternalRelativePath)
                if(not(endsWith(externalRelativePath,'/')))
                    externalRelativePath= sprintf('%s/',externalRelativePath);
                end
                file1=[externalRelativePath,file];
        else
           file1=file; 
        end
    
    end
    
    
    if(isempty(note))
        preNote='%';
    else
        preNote='';
    end
    newtab=sprintf('\t');
  
    latexCode=horzcat(...
        newline,'\begin{figure}[H]',...
        newline,newtab,'\caption{',caption,'}',...
        newline,newtab,'\includegraphics[scale=',sprintf('%.2f',latexScale),']{',file1,'}',...
        newline,newtab,'\label{',label,'}',...
        newline,newtab,preNote,'\floatfoot{\textit{Notes: }',note,'}',...
        newline,'\end{figure}',newline);
    
    if(displayLatex)
        disp(latexCode)
    end
    
    if(nargout>0)
        res.latex=latexCode;
        res.caption=caption;
        res.file=file1;
        res.fileAndPath=file;
        res.note=note;
        res.label=label;
        res.latexScale=latexScale;
    end
end
end

