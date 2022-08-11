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

dirBeamer=[dirBasura,'beamer/'];
dirFigures='';
dirTables='';
file='beamer';
title='Title beamer for matlab';
subtitle='';
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
                dirBeamer= varargin{2};
            case {'file'}
                file= varargin{2};
            case {'title'}
                title= varargin{2};
            case {'titleshort'}
                titleShort= varargin{2};
            case {'subtitle'}
                subtitle= varargin{2};
            case {'author'}
                author= varargin{2};
            case {'authorshort'}
                authorShort= varargin{2};
            case {'date'}
                date= varargin{2};
            case {'dateshort'}
                dateShort= varargin{2};
            otherwise
                error(['Unexpected option: ' varargin{1}])
        end
        varargin(1:2) = [];
    end
end

if(not(dirBeamer(end)=='/'))
    dirBeamer=[dirBeamer,'/'];
end

% create dir, and erase everything that was there!:
if(exist(dirBeamer,"dir"))
rmdir(dirBeamer,'s')
end


if(isempty(dirFigures))
    dirFigures=[dirBeamer,'figures/'];
elseif(not(dirFigures(end)=='/'))
    dirFigures=[dirFigures,'/'];
end
if(isempty(dirTables))
    dirTables=[dirBeamer,'tables/'];
elseif(not(dirTables(end)=='/'))
    dirTables=[dirBeamer,'/'];
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
beamer.subtitle=subtitle;
beamer.author=author;
beamer.dir=dirBeamer;
beamer.file=file;
beamer.dirFigures=dirFigures;
beamer.dirTables=dirTables;
beamer.authorShort=authorShort;
beamer.date=date;
beamer.dateShort=dateShort;

% copy preamble
copyfile('/Users/felipe/Dropbox/myMatlabFunctions/_latexFromMatlab/beamer/preamble_slidesSimple.tex',[dirBeamer,'preamble.tex']);


end


