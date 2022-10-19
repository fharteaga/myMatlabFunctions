function renameXTickWithCats(catVar)

assert(isordinal(catVar))

cats=categories(catVar);

set(gca,'xtick',1:length(cats))
set(gca,'xticklabels',cats)