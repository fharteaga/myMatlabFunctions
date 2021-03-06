function beamer=iniBeamer(varargin)

%{
    beamerOpts.title=title;
    beamerOpts.titleShort=titleShort;
    beamerOpts.author=author;
    beamerOpts.authorShort=authorShort;
    beamerOpts.dir=dir;
    beamerOpts.date=date;
    beamerOpts.dateShort=dateShort;
    % beamerOpts.file=file; % Default "beamer"
    % beamerOpts.dirFigures=dirFigures; % Default is "figures" folder inside dir.
    % beamerOpts.dirTables=dirTables; % Default is "tables" folder inside dir.
    beamer=iniBeamer('opts',beamerOpts);
%}

dir=[dirBasura,'beamer/'];
dirFigures='';
dirTables='';
file='beamer';
title='Title beamer for matlab';
titleShort='Short title';
author='Me';
authorShort='Me';
date='Today';
dateShort='Today';


% Loading optional arguments
if(~isempty(varargin))
    % This checks a few things, also if there is struct called "opts"
    varargin=checkVarargin(varargin);
    while ~isempty(varargin)
        switch lower(varargin{1})
            case {'dir'}
                dir= varargin{2};
            case {'title'}
                title= varargin{2};
            case {'author'}
                author= varargin{2};
            otherwise
                error(['Unexpected option: ' varargin{1}])
        end
        varargin(1:2) = [];
    end
end



if(isempty(dirFigures))
    dirFigures=[dir,'/figures/'];
end
if(isempty(dirFigures))
    dirTables=[dir,'/tables/'];
end
% create dirFigures:
mkdir(dirFigures);
% create dirTables:
mkdir(dirTables);


beamer=struct;
beamer.n=0;
beamer.nFig=0;
beamer.nTable=0;
beamer.title=title;
beamer.titleShort=titleShort;
beamer.author=author;
beamer.dir=dir;
beamer.file=file;
beamer.dirFigures=dirFigures;
beamer.dirTables=dirTables;
beamer.authorShort=authorShort;
beamer.date=date;
beamer.dateShort=dateShort;

% copy preamble
copyfile('/Users/felipe/Dropbox/myMatlabFunctions/_latexFromMatlab/beamer/preamble_slidesSimple.tex',[dir,'preamble.tex']);


end


