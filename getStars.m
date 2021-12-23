function stars=getStars(estimate,se,df)

% se: standard error
% df: degrees of freedom

% "Stars" for null H0 estimate=0. 

assert(all(size(estimate)==size(se)))

t=abs(estimate./se);
if(nargin==2)
    pv=(1-normcdf(t))*2;
    warning('assuming normality on distribution of statistic (set degrees of freedom to use T-stat insted of Z-stat)')
else
    pv=(1-tcdf(t,df))*2;
end

if(all(size(estimate)==1))
    stars=getStarsAux(pv);
else
    stars=arrayfun(@getStarsAux,pv,'UniformOutput',false);
end

function stars=getStarsAux(pv)
if(pv<.01)
    stars='***';
elseif(pv<.05)
    stars='**';
elseif(pv<.1)
    stars='*';
else
    stars='';
end
