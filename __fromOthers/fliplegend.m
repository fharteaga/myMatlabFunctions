function []=fliplegend(graphObject,legendCellStr,varargin)

legend(graphObject(end:-1:1),legendCellStr(end:-1:1),varargin{:}); % southoutside eastoutside

end