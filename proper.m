function str=proper(str)
% Simulates PROPER() MS Excel's function: upper case to first letter, lower
% case to others

if(ischar(str))
    str=lower(str);
    idx=regexp([' ' str],'(?<=\s+)\S','start')-1;
    str(idx)=upper(str(idx));
elseif(iscellstr(str)) %#ok<ISCLSTR>
    
    str=cellfun(@proper,str,'UniformOutput',false);
else
    error('Input is not char neither cellstring, please check it!')
end