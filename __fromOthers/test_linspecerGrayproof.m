close all
clc
n=2;

colorsBar=linspecerGrayproof(n,0.3);

tiledlayout(1,2)
nexttile
br=bar(ones(2,n),'stacked','FaceColor','flat');
for i=1:n
    br(i).CData = colorsBar(i,:);
end

nexttile
colorsBar=rgb2gray(colorsBar);
br2=bar(ones(2,n),'stacked','FaceColor','flat');
for i=1:n
    br2(i).CData = colorsBar(i,:);
end