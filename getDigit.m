
function digit=getDigit(number,position)

% Return digit in position "position" counting from RIGHT to LEFT
% If postion S:F, returns the (F-S+1) first digits counting from RIGHT to
% LEFT, starting on position "S" and finishing in "F"

number=abs(number);
assert(all(position>0),'Positions must be positive numbers')
assert(all(mod(position,1)==0),'Numbers must be integers')

maxPos=max(position);
minPos=min(position);
sirven=number>=10^(maxPos-1);

assert((maxPos-minPos+1)==numel(position))
assert(all(minPos:maxPos==position))


digit=(mod(number,10^maxPos)-mod(number,10^(minPos-1)))/10^(minPos-1);



if(any(not(sirven)))
    digit(not(sirven))=nan;
end










