function text=subfiguresLatex(d,varargin)

% Warning!: Latex does not have permission to write in parent directories,
% so generating a .tex to \include{} in the document in a higher directory
% will not work, because latex has to generate a ".aux". So keep it in the
% same or deeper directory than the main.tex


% If you want to use more space than textwidht, play with "docWidth" and
% "scale"
caption='';
noteFigure='';
label='';
file='';
export=false;
scale=.5;
docWidth=.9;
includeExternalRelativePath=false;
includeExternalRelativePathSubfigs=false;
externalRelativePath='';
externalRelativePathSubfigs='';
withExtraWidth=true;
copyToClipboard=false; % Don't set it to true, because from terminal it generates a problem

if(nargin==0)
    d=[1,1];
elseif(numel(d)==1)
    d=[1,d];
end

if(~isempty(varargin))

    % This checks a few things, including if there is a struct called "opts"
    varargin=checkVarargin(varargin);
    % Loading optional arguments
    while ~isempty(varargin)
        switch lower(varargin{1})
            case 'caption'
                caption=varargin{2};
            case 'note'
                noteFigure=varargin{2};
            case 'label'
                label=varargin{2};
            case 'file'
                file=varargin{2};
                export=true;
            case 'scale'
                scale=varargin{2};
            case 'docwidth'
                docWidth=varargin{2};
            case {'copytoclipboard','c'}
                copyToClipboard=varargin{2};
            case {'externalrelativepath','erp'}
                externalRelativePath=varargin{2};
                if(~isempty(externalRelativePath))
                    includeExternalRelativePath=true;
                end
            case {'externalrelativepathfigures','erpf'}
                externalRelativePathSubfigs=varargin{2};
                if(~isempty(externalRelativePathSubfigs))
                    includeExternalRelativePathSubfigs=true;
                end
            otherwise
                error(['Unexpected option: ' varargin{1}])
        end
        varargin(1:2) = [];
    end

end

withInput=false;
if(iscell(d))
    assert(all(cellfun(@(x)isstruct(x)||isempty(x),d),'all'))
    withInput=true;
    input=d;
    d=size(input);
end

width=docWidth/d(2);

% First column is the in, second is the out:
matSpecial={...
    '$','\$';...
    '[','$[$';...
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
    noteFigure=strrep(noteFigure,matSpecial{i,1},matSpecial{i,2});
    caption=strrep(caption,matSpecial{i,1},matSpecial{i,2});
end

newtab=sprintf('\t');
newtab2=sprintf('\t\t');

if(withExtraWidth)
    extraWidth1='\makebox[\textwidth][c]{%';
    extraWidth2='} % End of \makebox';
else
    extraWidth1='%\makebox[\textwidth][c]{%';
    extraWidth2='%} % End of \makebox';
end

if(isempty(caption))
    preCaption='%';
else
    preCaption='';
end
text=horzcat(newline,'\begin{figure}[H]',newline,'\centering',newline,preCaption,'\caption{ ',caption,'}',newline,'\label{',label,'}');

if(includeExternalRelativePathSubfigs)
    if(not(endsWith(externalRelativePathSubfigs,'/')))
        externalRelativePathSubfigs= sprintf('%s/',externalRelativePathSubfigs);
    end
end

for i=1:d(1)
    text=horzcat(text,newline,extraWidth1);
    for j=1:d(2)

        if(withInput&&not(isempty(input{i,j})))
            info=input{i,j};
            fileSub=info.file;
            captionSub=info.caption;
            %             ESTO NO FUNCIONA:
            %             if(not(isempty(info.note))&&includeNotes)
            %                 note=['\floatfoot{\scriptsize \textit{Notes:} ',info.note,'}'];
            %             else
            %                 note='%\floatfoot{\scriptsize \textit{Notes:} }';
            %             end
            if(not(isempty(info.label)))
                label=['\label{',info.label,'}'];
            else
                label='%\label{ }';
            end
        elseif(not(withInput))
            fileSub='';
            captionSub='';
            %note='%\floatfoot{\scriptsize \textit{Notes:}}';
            label='%\label{ }';
        end

        if(not(withInput)||not(isempty(input{i,j})))
            if(isempty(captionSub))
                preCaption='%';
            else
                preCaption='';
            end
            text=horzcat(text,newline,newtab,'%',sprintf('[%i,%i]',i,j),newline,newtab,'\begin{subfigure}[b]{',sprintf('%.3f',width),'\textwidth}',newline,newtab2,'\centering',newline,newtab2,preCaption,'\caption{\centering ',captionSub,'}',newline,newtab2,label,newline,newtab2,'\includegraphics[scale=',sprintf('%.3f',scale),']{',externalRelativePathSubfigs,fileSub,'}',newline,newtab,'\end{subfigure}');
        end
    end
    if(i<d(1))
        text=[text,newline,extraWidth2,newline,sprintf('\t\\vspace{.02cm}'),newline];
    end
end

if(isempty(noteFigure))
    noteFigure=horzcat(newline,'%\floatfoot{\scriptsize \textit{Notes:} ',noteFigure,'}',newline);
else
    noteFigure=horzcat(newline,'\floatfoot{\scriptsize \textit{Notes:} ',noteFigure,'}',newline);
end


text=[text,newline,newtab,extraWidth2,noteFigure,'\end{figure}',newline];




if(export)
    if(~contains(file,'.tex'));file=[file,'.tex'];end

    fid = fopen(file,'wt');
    fprintf(fid, '%s', text);
    fclose(fid);

    % Imprime el codigo pa meter al tex:

    posTex=strfind(file,'.tex');
    if(~isempty(posTex));file=file(1:posTex(end)-1);end % Texpad alega si tiene .tex!

    pos=strfind(file,'/');
    if(~isempty(pos))

        file1=file(pos(end)+1:end);
        fprintf('\n\\include{%s}\n\n',file1);

        if(includeExternalRelativePath)

            if(not(endsWith(externalRelativePath,'/')))
                externalRelativePath= sprintf('%s/',externalRelativePath);
            end
            fprintf('\\include{%s}\n\n',[externalRelativePath,file1]);
        end

        newPos=pos(pos<(pos(end)-1)); % Ve si hay otro "/" (q no está pegado al anterior)
        if(~isempty(newPos))
            file2=file(newPos(end)+1:end);
            fprintf('\\include{%s}\n\n',file2);

        end
    end
end

if(copyToClipboard)
    showShorcut(text);
end

