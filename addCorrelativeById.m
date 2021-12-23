function tabla=addCorrelativeById(idVarName,tabla,varargin)
correlativeVarName='correlative';

if(ischar(idVarName))
    idVarName={idVarName};
end
if(~isempty(varargin))
    
    % This checks a few things, including if there is a struct called "opts"
    varargin=checkVarargin(varargin);
    
    while ~isempty(varargin)
        switch lower(varargin{1})
            case {'correlativevarname'}
                correlativeVarName= varargin{2};
                
            otherwise
                error(['Unexpected option: ' varargin{1}])
        end
        varargin(1:2) = [];
    end
end

vars=(tabla.Properties.VariableNames);
assert(not(any(ismember({'order__','correlative__','correlative___min',correlativeVarName},vars))));

tabla.order__=(1:height(tabla))';
tabla=sortrows(tabla,[idVarName,'order__']);
tabla.correlative__=(1:height(tabla))';


tabla=stataCollapse(idVarName,tabla,'correlative__','min','mergeWithOriginal',true);
tabla.(correlativeVarName)=tabla.correlative__-tabla.correlative___min+1;




tabla=sortrows(tabla,'order__');
tabla.order__=[];
tabla.correlative__=[];
tabla.correlative___min=[];