clc;clear;close all;fclose('all');feature('DefaultCharacterSet','UTF-8');

pcName=char(java.lang.System.getProperty('user.name'));
if(strcmp(pcName,'felipe'))

    % Directory of custom functions:
    pathExtraFunctions='/Users/felipe/Dropbox/myMatlabFunctions/';

elseif(strcmp(pcName,'ericsPcName'))

    % Directory of custom functions:
    pathExtraFunctions='....EricsPath....myMatlabFunctions/';

else
    error('The name "%s" is not in the list.\n Add  "elseif(strcmp(pcName,''%s'')"  and the right paths',pcName,pcName)
end

addpath(genpath(pathExtraFunctions));

a=table;
a.X=randn(1000,1);
a.Y=a.X*2+randn(1000,1);
a=stataCommand('reg X Y',a);

a.log