

alternatives=[100,200,300,400]';

catAlternatives=[1 1 1;0 0 1;0 0 1;1 1 1]==1;
picksPerCat=[2 2 2]';
tieBreakerCats=rand(4,3);
randomTieBreakerCats=rand(4,3);
totalPicks=10;
fillingCat=3;


clc
[pickedAlternatives,pickedByCat,subCatOrderPick,foundTotalPerCat,totalPicked]=picker(alternatives,catAlternatives,picksPerCat,tieBreakerCats,randomTieBreakerCats,totalPicks,fillingCat)



