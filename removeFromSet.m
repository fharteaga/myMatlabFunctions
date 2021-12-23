function newSet=removeFromSet(set,remove)

    newSet=set(not(ismember(set,remove)));
    