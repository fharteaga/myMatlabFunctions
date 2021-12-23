
% panel color
barcolors=linspecer(6);

% flow color
c = [.7 .7 .7];

% Panel width
w = 5; 

for j=1:13
    if j>1
        ymax=max(ymax,sankey_yheight(matrixStocks(:,j-1)',matrixStocks(:,j)'));
        
    else
        y1_category_points=[];
        ymax=sankey_yheight(matrixStocks(:,j)',matrixStocks(:,j+1)');
    end
    y1_category_points=sankey_alluvialflow(matrixStocks(:,j)', matrixStocks(:,j+1)', matrixTransitions(:,:,j), j-1,j, y1_category_points,ymax,barcolors,barcolors,w,c);
end
        