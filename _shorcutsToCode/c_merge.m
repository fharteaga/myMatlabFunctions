function c_merge(varargin)

if(nargin>0)
text='table=outerjoin(table1,table2,''leftkeys'',{''''},''rightkeys'',{''''},''mergeKeys'',false,''type'',''left'',''rightVariables'',{''''});';
else
text='table=outerjoin(table1,table2,''keys'',{''''},''mergeKeys'',true,''type'',''left'',''rightVariables'',{''''});';
end
showShorcut(text,'print',false)