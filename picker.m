function [pickedAlternatives,pickedByCat,subCatOrderPick,foundTotalPerCat,totalPicked]=picker(alternatives,catAlternatives,picksPerCat,tieBreakerCats,randomTieBreakerCats,totalPicks,fillingCat)

% alternatives: array with the id of each alternative length(set)=N;
% picksPerCat: quantity of choices of that category, size(cantPerCat)=C;
% catAlternatives: matrix of dummies of alternative "i" belongs ot category "j" 
% tieBreakerCats: if there are more than one, pick the alternative with the
% lowest value here.
% randomTieBreakerCats: same se the last one, but is random to choose
% between alternatives of the same value in tieBreakers (as distance, that
% might be tie-breaker, but also might be equal)
% totalPicks: number of desired total picks. If only picking according
% "picksPerCat" the resutls is less, then tries to look for more
% alternatives of the category defined by fillingCat

C=length(picksPerCat);
picksPerCat=reshape(picksPerCat,[],C);
N=length(alternatives);
assert(all(size(tieBreakerCats)==[N,C]))
assert(all(size(catAlternatives)==[N,C]))
assert(all(size(randomTieBreakerCats)==[N,C]))
assert(numel(totalPicks)==1)
assert(fillingCat>0&&fillingCat<=C)
assert(islogical(catAlternatives))

pickedByCat=false(N,C);
subCatOrderPick=nan(N,C);


for c=1:C
    if(picksPerCat(c)>0)
        fromCat=find(catAlternatives(:,c));
        
        cantPickAux=picksPerCat(c);
        if(length(fromCat)<cantPickAux)
            cantPickAux=length(fromCat);
        end
        
        [~,pos]=sortrows([tieBreakerCats(fromCat,c),randomTieBreakerCats(fromCat,c)],'ascend');
        subCatOrderPick(fromCat(pos(1:cantPickAux)),c)=1:cantPickAux;
    end
    
end

pickedByCat(not(isnan(subCatOrderPick)))=true;
picked=any(pickedByCat,2);
totalPicked=sum(picked);
foundTotalPerCat=sum(pickedByCat)==picksPerCat;

%% If total hasn't been achieved, then pick more form "filling" category:

if(totalPicked<totalPicks)

    c=fillingCat;

    % From the set of the filling category, but that has not been picked
        fromCat=find(catAlternatives(:,c)&not(picked));
        
        cantPickAux=totalPicks-totalPicked;
        if(length(fromCat)<cantPickAux)
            cantPickAux=length(fromCat);
        end
        
        [~,pos]=sortrows([tieBreakerCats(fromCat,c),randomTieBreakerCats(fromCat,c)],'ascend');
        subCatOrderPick(fromCat(pos(1:cantPickAux)),c)=(1:cantPickAux)+sum(pickedByCat(:,c));

        pickedByCat(not(isnan(subCatOrderPick)))=true;
        picked=any(pickedByCat,2);
        totalPicked=sum(picked);
end

% Keep info only in alternatives picked:

pickedByCat=pickedByCat(picked,:);
subCatOrderPick=subCatOrderPick(picked,:);



pickedAlternatives=alternatives(picked);
