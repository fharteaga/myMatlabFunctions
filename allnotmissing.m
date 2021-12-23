function notanymissing=allnotmissing(var)

anymissing=any(ismissing(var));
notanymissing=not(anymissing);