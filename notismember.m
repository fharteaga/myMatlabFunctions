function notismember(A,B,varargin)

if(ismember('rows',varargin))
    disp(A(not(ismember(A,B,'rows')),:))
else
    tab(A(not(ismember(A,B))))
end