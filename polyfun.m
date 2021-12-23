function y=polyfun(x,coef)
pOrder=length(coef)-1;
if(pOrder==1)
    poly=@(x,coef)coef(1)+coef(2)*x;
elseif(pOrder==2)
    poly=@(x,coef)coef(1)+coef(2)*x+coef(3)*x.^2;
elseif(pOrder==3)
    poly=@(x,coef)coef(1)+coef(2)*x+coef(3)*x.^2+coef(4)*x.^3;
elseif(pOrder==4)
    poly=@(x,coef)coef(1)+coef(2)*x+coef(3)*x.^2+coef(4)*x.^3+coef(5)*x.^4;
else
    error('aca')
end
y=poly(x,coef);