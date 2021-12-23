function res=rdrobust(y_varName,runningVar_varName,data,varargin)
% RDROBUST run rdrobust command in stata 
%   R = RDROBUST(y_varName,runningVar_varName,data,varargin) 
%   
%   Loads the table "data" into Stata, and runs rdrobust in stata:
%   rdrobust  y_varName runningVar_varName if subpop==1,c(cutoff) <opts>
%   Then it plots the RD in Matlab
%
%% Inputs:
%   y_varName: (text) dep variable
%   runningVar_varName: (text) running variable variable
% 
%% Output:
%   res: (struct) output from stata "ereturn" (and also plot related stuff
%       if plot exist)
%
%% Optional inputs:
%   cutoff (0): (numeric) defines the cutoff for the RD
%   subpop (trues): (vector with some 1s) only uses obs with subpop==1
%                   I want this because sometimes de RD is calculated with
%                   a selected sample, while the binsreg can have different
%                   support. 
%   rdrobustOpts (''): (char) options that will literally put on
%                   the stata command rdrobust
%   plotOpts (): (struct) options for my function plotRD
%
%% Examples:
%  rdrobust('yvar','run_var',data)
%  rdrobust('yvar','run_var',data,'subpop',subpop,'cutoff',0.3,'rdrobustOpts','h(.28 .68) p(2)')
%
%  See also PLOTRD
%
%   F. Arteaga (fharteaga 'at' gmail)

withPlot=true;
withPlotOpts=false;
subpop=true(height(data),1);
cutoff=0;
rdrobustOpts='';

if(~isempty(varargin))
    % This checks a few things, including if there is a struct called "opts"
    varargin=checkVarargin(varargin);
 
    % Loading optional arguments
    while ~isempty(varargin)
        switch lower(varargin{1})
            case {'withplot'}
                withPlot=varargin{2};
            case {'subpop'}
                subpop=varargin{2};
            case {'cutoff'}
                cutoff=varargin{2};
            case {'rdrobustopts'}
                rdrobustOpts=varargin{2};
            case {'plotopts'} % Esto es un struct con opciones para plotRD.m
                withPlotOpts=true;
                plotOpts=varargin{2};
                
            otherwise
                error(['Unexpected option: ',varargin{1}])
                
        end
        varargin(1:2) = [];
    end
end

dataVars=data.Properties.VariableNames;
assert(ismember(y_varName,dataVars),sprintf('%s is not in the table!',y_varName));
assert(ismember(runningVar_varName,dataVars),sprintf('%s is not in the table!',runningVar_varName));
assert(not(ismember('subpop__',dataVars)));

data.subpop__=subpop;
command=sprintf('rdrobust %s %s if subpop__==1,c(%.6f) %s',y_varName,runningVar_varName,cutoff,rdrobustOpts);
res=stataCommand(command,data,'selectColumns',true,'displayLog',true);

if(withPlot)
   
    
    if(withPlotOpts)
        resP=plotRD(res,data,'subpop',subpop,'opts',plotOpts);
    else
        resP=plotRD(res,data,subpop);
    end
    if(nargout>0)
        mergestructs = @(x,y) cell2struct([struct2cell(x);struct2cell(y)],[fieldnames(x);fieldnames(y)]);
        res=mergestructs(res,resP);
    end
    
end

