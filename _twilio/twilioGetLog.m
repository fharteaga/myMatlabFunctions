function log=twilioGetLog(iniDatenum,varargin)

%{
iniDatenum=datenum('2021-12-21 00:00','yyyy-mm-dd HH:MM');
opts.daysOfLogs=8;
opts.utcMinusLocalTime=5;
opts.fileOutput=dirBasura(sprintf('logTwilio_%s to %s.mat',datestr(iniDatenum),datestr(iniDatenum+opts.daysOfLogs)));
log=twilioGetLog(iniDatenum,'opts',opts);
%}
tic
twilioSetCredentials;
addToSystemPath('python')

fileOutput='';
numbersUsedToSendTwilio={}; % Leave empty if you don't want to filter based on this. No "+", as in the input for twilio
numbersUsedToTest={}; % Leave empty if you don't want to delete based on this. No "+", as in the input for twilio
fileInputTwilio='';% CSV, must contain column "cellphone". Leave empty if you don't want to delete based on this. No "+", as in the input for twilio
daysOfLogs=3;
utcMinusLocalTime=0; % Ecuador is GMT-5
plotHistogramOfTime=true;
exportCsv=false;

if(~isempty(varargin))

    % This checks a few things, including if there is a struct called "opts"
    varargin=checkVarargin(varargin);

    while ~isempty(varargin)
        switch lower(varargin{1})
            case {'daysoflogs'}
                daysOfLogs= varargin{2};
            case {'utcminuslocaltime'}
                utcMinusLocalTime= varargin{2};
            case {'fileoutput'}
                fileOutput= varargin{2};
            otherwise
                error(['Unexpected option: ' varargin{1}])
        end
        varargin(1:2) = [];
    end
end
iniDatenum_0=iniDatenum;
tempFileOutput=dirBasura(sprintf('logs_basura.csv'),'pl',0);
for i=1:daysOfLogs

    endDate=iniDatenum+1;


    iniStr=datestr(iniDatenum,'yyyy-mm-dd HH:MM');
    endStr=datestr(endDate,'yyyy-mm-dd HH:MM');
    fprintf('Getting log of day %i of %i (%s to %s )...\n',i,daysOfLogs,iniStr,endStr);
    
    system(sprintf('python -m cb_twilio.logger --date-sent-after "%s" --date-sent-before "%s" --output %s --all --delimiter ";"',iniStr,endStr,tempFileOutput));

    iniDatenum=endDate;
    opts = detectImportOptions(tempFileOutput);
    opts = setvartype(opts,'to',{'char'});
    opts = setvartype(opts,'from',{'char'});
    opts = setvartype(opts,'error_code',{'double'});
    opts = setvartype(opts,'error_message',{'char'});
    a=readtable(tempFileOutput,opts);
    delete(tempFileOutput);
    if(i==1)
        log=a;
    else
        log=[log;a];
    end
    %fprintf('done!\n');

    %%

end


%% Filter

% Load receipients
if(not(isempty(fileInputTwilio)))
    opts = detectImportOptions(fileInputTwilio);
    opts = setvartype(opts,'cellphone',{'char'});
    inputTwilio=readtable(fileInputTwilio,opts);
    numbersRecipients=inputTwilio.cellphone';
else
    numbersRecipients={};
end

log.newFrom=cellfun(@substrCel,log.from,'UniformOutput' ,false);
log.newTo=cellfun(@substrCel,log.to,'UniformOutput' ,false);

assert(all(not(contains([numbersUsedToSendTwilio,numbersUsedToTest,numbersRecipients],'+'))))

if(not(isempty(numbersUsedToSendTwilio)))
    filtradosTwilio=ismember(log.newFrom,numbersUsedToSendTwilio)|ismember(log.newTo,numbersUsedToSendTwilio);
    fprintf('Filtro por numbersUsedToSendTwilio: %.2f de las obs (%i de %i, %i fuera)\n',mean(filtradosTwilio),sum(filtradosTwilio),length(filtradosTwilio),sum(~filtradosTwilio));
else
    filtradosTwilio=scalarForTable(true,log);
end

if(not(isempty(numbersRecipients)))
    filtradosRecipients=ismember(log.newFrom,numbersRecipients)|ismember(log.newTo,numbersRecipients);
    fprintf('Filtro por numbersRecipients: %.2f de las obs (%i de %i, %i fuera)\n',mean(filtradosRecipients),sum(filtradosRecipients),length(filtradosRecipients),sum(~filtradosRecipients));
else
    filtradosRecipients=scalarForTable(true,log);
end

if(not(isempty(numbersUsedToTest)))
    filtradosTest=~ismember(log.newFrom,numbersUsedToTest)&~ismember(log.newTo,numbersUsedToTest);
    fprintf('Filtro por numbersUsedToTest: %.2f de las obs (%i de %i, %i fuera)\n',mean(filtradosTest),sum(filtradosTest),length(filtradosTest),sum(~filtradosTest));
else
    filtradosTest=scalarForTable(true,log);
end

log=log(filtradosTwilio&filtradosTest&filtradosRecipients,:);
% Create dates

log.datenumSent=datenum(log.date_sent,'yyyy-mm-ddTHH:MM:SS');

if(plotHistogramOfTime)
    histogram(datetime(log.datenumSent-utcMinusLocalTime/24,'ConvertFrom','datenum'))
    xlabel(sprintf('GMT-%i',utcMinusLocalTime))
end


if(not(isempty(fileOutput)))
    save(fileOutput,'log')
    if(exportCsv)
    writetable(log,[fileOutput,'.csv'])
    end
end

fprintf('FINISHED! Logs from %s to %s (time: %s)\n',datestr(iniDatenum_0),datestr(endDate),convertirSegToStr(toc))
end

function x=substrCel(input)
pos=find(input=='+',1);
if(not(isempty(pos)))
    x=input(pos+1:end);
else
    warning('%s does not contain "+" sign')
    x=input;
end
end
