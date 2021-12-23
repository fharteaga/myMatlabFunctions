function a=openStataLog()

tempDir='/Users/felipe/Dropbox/myMatlabFunctions/_stataFromMatlab/_tempFiles/';

flog=[tempDir,'tempDoFile.log'];

if isfile(flog)
     uiopen(flog,1)
else
     fprintf('Sorry, there is no Stata Log where is should be, :(\n')
end