function exportBeamer(beamer)


% Create file
fid = fopen([beamer.dir,beamer.file,'.tex'],'wt');


% Print front
fprintf(fid,'%s\n', '\documentclass[aspectratio=169,openany,10pt]{beamer}');
fprintf(fid,'%s\n', '\input{preamble.tex}');
fprintf(fid,'%s\n', ['\title[',beamer.titleShort,']{',beamer.title,'}']);
fprintf(fid,'%s\n', ['\author[',beamer.authorShort,']{',beamer.author,'}']);
fprintf(fid,'%s\n', ['\date[',beamer.dateShort,']{',beamer.date,'}']);
fprintf(fid,'%s\n', ['\begin{document}',newline,'\frame{\titlepage}']);


% Print slides

names=fieldnames(beamer);
slides=names(startsWith(names,'slide'));

for s=1:length(slides)
    slide=beamer.(slides{s});
    if(~isempty(slide.code))
        fragile='[fragile]';
    else
        fragile='';
    end
    
    fprintf(fid,'%s\n',[newline,'\begin{frame}',fragile,'\frametitle{',slide.title,'}']);
    
    % Plot figs
    figStructs=slide.fig;
    cantFigs=length(figStructs);
    
    % Scale para el subfig:
    switch size(figStructs,2)
        case 1
            scale=.7;
        case 2
            scale=.5;
        case 3
            scale=.35;
        otherwise
            scale=1/size(figStructs,2);
    end
    
    
    
    if(cantFigs==1)
        fig=figStructs{1};
        newFig=['\begin{figure}',newline, '\centering',newline,'\includegraphics[scale=',sprintf('%.4f',fig.latexScale),']{',fig.file,'}',newline,'\caption{',fig.caption,'}',newline,'\end{figure}'];
        fprintf(fid,'%s\n',newFig);
    elseif(cantFigs>1)
        newFig=subfiguresLatex(figStructs,'scale',scale);
        fprintf(fid,'%s\n',newFig);
    end
    
    
    % Add items
    items=slide.items;
    cantI=size(items,1);
    if(cantI>0)
        if(size(items,2)==1)
            levels=ones(size(items));
        else
            levels=cell2mat(items(:,2));
            assert(all(isnumeric(levels)))
            assert(levels(1)==1);
        end
        lev_i=0;
        for i=1:cantI
            if(lev_i<levels(i))
                fprintf(fid,'%s\n','\begin{itemize}');
            end
            if(lev_i>levels(i))
                for j=1:lev_i-levels(i)
                    fprintf(fid,'%s\n','\end{itemize}');
                end
            end
            fprintf(fid,'\t\\item %s\n',items{i});
            lev_i=levels(i);
        end
        
        for j=1:lev_i
            fprintf(fid,'%s\n','\end{itemize}');
        end
    end
    
    
    % Add code 
    code=slide.code;
    codeSize=slide.codeSize; % \normalsize \small \footnotesize \ \fontsize{8}{9}\selectfont

    if(~isempty(code))
        
        fprintf(fid,'%s\n','\begin{adjustbox}{width=\textwidth,height=.43\textheight,keepaspectratio}');
        fprintf(fid,'\\begin{lstlisting}[basicstyle=%s]\n',codeSize);
        fprintf(fid,'%s\n',code);
        
        fprintf(fid,'\\end{lstlisting}\n');
        fprintf(fid,'\\end{adjustbox}\n');
    end
    
    % End frame
    fprintf(fid,'%s\n','\end{frame}');
    
end

fprintf(fid,'%s\n', '\end{document}');
fclose(fid);

end