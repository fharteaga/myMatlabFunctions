function [pickedAlternatives,pickedByCat,subCatOrderPick,foundTotalPerCat,totalPicked]=picker(alternatives,catAlternatives,picksPerCat,tieBreakerCats,randomTieBreakerCats,totalPicks,fillingCat)
% PICKER picks alternatives within a set 
%   [...] = PICKER(alternatives,catAlternatives,picksPerCat,tieBreakerCats,randomTieBreakerCats,totalPicks,fillingCat)
%   
%   It chooses "picksPerCat" options between the "alternatives" who are
%   classified in "catAlternatives". If there is more options per category
%   than the desierd ones, it picks the one with lowest value on
%   "tieBreakerCats". In case of ties, it chooses the one with lower value 
%   on "randomTieBreakerCats". Once it picked enough options for every
%   category, it checks if it has at least "totalPicks". If the number is
%   not reached, then it keeps drawing from the "fillingCat" (as long as
%   there is any available) to reach the desired quantity of options.
%
%% Inputs:
%   alternatives: (any) array with the id of each alternative size(alternatives)=N;
%   picksPerCat: (double) quantity of choices of that category, size(cantPerCat)=[Cx1];
%   catAlternatives: (logical) matrix of dummies of alternative "i" belongs ot
%           category "j" , size(cantPerCat)=[NxC];
%   tieBreakerCats: (double) if there are more than one, pick the alternative with the
%               lowest value here. Each obs has a different tieBrekear for
%               each categorie. size(tieBreakerCats)=[NxC];
%   randomTieBreakerCats: (double) same se the last one, but is random to choose
%           between alternatives of the same value in tieBreakers (as distance, that
%           might be tie-breaker, but also might be equal)
%   totalPicks: number of desired total picks. Only if picking according
%       "picksPerCat" results on less picks, then tries to look for more
%       alternatives of the category defined by "fillingCat"
%   fillingCat: (double<=C) With category uses to reach the desired picks.
%
%% Output:
%   pickedAlternatives: (any) alternatives chosen, defined by the id that
%           comes in "alternatives"
%
%% Optional inputs:
%   [none]
%
%% Examples:
%
%
%   F. Arteaga (fharteaga 'at' gmail)
% alternatives: 
% 

 


C=length(picksPerCat);
picksPerCat=reshape(picksPerCat,[],C);
N=length(alternatives);
assert(all(size(alternatives)==[N,1]))
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
