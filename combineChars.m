function cellout=combineChars(cell1,cell2)

cell1=cell1(:);
cell2=cell2(:);
sep=' - ';
cellout=cell(length(cell1)*length(cell2),1);
count=0;
for c1=1:length(cell1)
    for c2=1:length(cell2)
        count=count+1;
        cellout{count}=[cell1{c1},sep,cell2{c2}];
    end
end