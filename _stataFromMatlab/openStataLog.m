function openStataLog()

% This mFile has the paths related to stata
paths=pathsStata();

tempDir=paths.stataTempfilesPath;

flog=[tempDir,'tempDoFile.log'];

if isfile(flog)
     uiopen(flog,1)
else
     fprintf('Sorry, there is no Stata Log where is should be, :(\n')
end