function out=cumfunction(in,fun)

% Ej: cummedian(x) -> cumfunction(x,@(x)quantile(x,.5))
assert(sum(size(in)>1)<=1);
out=nan(size(in));
for l=1:length(in)
    out(l)=fun(in(1:l));
end

end