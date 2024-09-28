% Test FWL

clc
close all

rng(123123)

N=100;

corr=randn(N,1)/3;
x1=2+randn(N,1)+corr>3;
x2=3+rand(N,1)+corr>4;
x1a=4+rand(N,1)+corr;
x2a=5+rand(N,1)+corr;
xd=double(randn(N,1)>.5);


e=randn(N,1);

y=10+20*x1+30*x2+40*x1a+50*x2a+e;

% De-mean controls:
t_orig=table;
t_orig.x1=x1;
t_orig.x2=x2;
t_orig.x1a=x1a;
t_orig.x2a=x2a;
t_orig.y=y;

t_orig_noDM=t_orig;
t_orig.x1a=x1a-mean(x1a);
t_orig.x2a=x2a-mean(x2a);
% t2=t_orig;
% f1=fitlm(t2)
% t2.x1=t2.x1-mean(t2.x1);
% f2=fitlm(t2)
% asd

t=t_orig;

% 
% t=t_orig;
% for v=1:(width(t)-1)
% t{:,v}=t{:,v}-mean(t{:,v});
% end




fo=fitlm(t_orig)
fo_noDM=fitlm(t_orig_noDM);
yhat_orig=fo.Fitted;
yhat_orig2=[scalarForTable(1,t_orig),t_orig{:,1:2}]*fo.Coefficients.Estimate(1:3);
yhat_orig2_noDM=[scalarForTable(1,t_orig),t_orig{:,1:2}]*fo_noDM.Coefficients.Estimate(1:3);
histogram(t_orig.y-yhat_orig)
mean(t_orig.y-yhat_orig)
%fitlm(t)

AX=[ones(height(t),1),t.x1a t.x2a];

t.y_res=y-AX*((AX'*AX)\(AX'*y));
t.x1_res=x1-AX*((AX'*AX)\(AX'*x1));
t.x2_res=x2-AX*((AX'*AX)\(AX'*x2));

f1=fitlm(t(:,{'x1_res','x2_res','y_res'}))
f2=fitlm(t(:,{'x1_res','x2_res','y'}))

% Recover \hat(y) from residualized eq:
yhat_f1=[scalarForTable(1,t_orig),t_orig{:,1:2}]*f1.Coefficients.Estimate(1:3);
yhat_f1_corr=yhat_f1+(mean(t.y)-mean(yhat_f1));

yhat_f2=[scalarForTable(1,t_orig),t_orig{:,1:2}]*f2.Coefficients.Estimate(1:3);
yhat_f2_corr=yhat_f2+(mean(t.y)-mean(yhat_f2));
nexttile
histogram(yhat_f1_corr-yhat_orig2)
nexttile
histogram(yhat_f2_corr-yhat_orig2)



corrSE=f1.Coefficients.SE*sqrt(f1.DFE/(f1.DFE-(size(AX,2)-1)))


