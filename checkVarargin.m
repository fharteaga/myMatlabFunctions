function newVarargin=checkVarargin(cellVarargin)
% Check that number is even ( optionName, optionValue)
% Checks if one of the options is a struct called
% Check that is no duplicated option
% Check that all optionName are Strings

% Check that comes in row shape
assert(size(cellVarargin,1)==1)


% Check that number is even ( optionName, optionValue)
assert(mod(length(cellVarargin),2)==0,'Si agregai opciones, ponle el tipo!')

% Checks if one of the options is a struct called "opts"
[is,pos]=ismember('opts',cellVarargin(1:2:end));
if(any(is))
    
    assert(sum(is)==1);
    pos=(pos-1)*2+1;
    opts=cellVarargin{pos+1};
    assert(isstruct(opts));
    cellVarargin([pos,pos+1])=[];
    fields=fieldnames(opts)';
    values=struct2cell(opts)';
    newVarargin=cell(1,length(values)*2);
    newVarargin(1:2:end)=fields;
    newVarargin(2:2:end)=values;
    newVarargin=[cellVarargin,newVarargin];
    
else
    newVarargin=cellVarargin;
end
% Check that there is no duplicate option:
assert(length(unique(newVarargin(1:2:end)))==length(newVarargin(1:2:end)),'There is one option duplicated in cellVarargin')

% Check that all optionName are Strings
assert(iscellstr(newVarargin(1:2:end)))