function res=stataCommand(command,data,varargin)

selectColumnsWithCode=true; % Export to stata only vars referenced in the command
displayLog=false;

% This mFile has the paths related to stata
paths=pathsStata();

stataProgramsPath=paths.stataProgramsPath;
stataTempfilesPath=paths.stataTempfilesPath;

% If command is a char, it includes only de stata code
% command is a cellstr, first colum contains the id of the command
% (to recover the results) and the second the code itself.


onlyOneCommand=false;
if(iscellstr(command)) %#ok<ISCLSTR>
    assert(size(command,2)==2)
    assert(allunique(command(:,1)),'IDs for each command must be unique')
elseif(ischar(command))
    onlyOneCommand=true;
    command={'cmdID',command};
else
    error('Command must be cellstr or char')
end

% Id of command cannot contain spaces, tab or return (or points, because of
% the struct that genereates later)
assert(not(any(contains(command(:,1),' '))|any(contains(command(:,1),'\t'))|any(contains(command(:,1),'\n'))|any(contains(command(:,1),'.'))))

typeOfReturn=repmat({'ereturn'},size(command,1),1); % 'ereturn', 'return';

if(~isempty(varargin))
    
    % This checks a few things, including if there is a struct called "opts"
    varargin=checkVarargin(varargin);
    while ~isempty(varargin)
        switch lower(varargin{1})
            case {'selectcolumns','sc'}
                selectColumnsWithCode = varargin{2};
                assert(islogical(varargin{2}))
            case {'displaylog','dl'}
                displayLog=varargin{2};
            case {'typeofreturn'}
                typeOfReturn=varargin{2};
                if(ischar(typeOfReturn));typeOfReturn={typeOfReturn};end
                assert(iscellstr(typeOfReturn))
                assert(length(typeOfReturn)==size(command,1))
            otherwise
                error(['Unexpected option: ' varargin{1}])
        end
        varargin(1:2) = [];
    end
end




if(selectColumnsWithCode)
    auxCode=sprintf('%s',command{:,2});
    vars=data.Properties.VariableNames;
    nVars=size(data,2);
    relevantVar=false(nVars,1);
    for i=1:nVars
        relevantVar(i)=contains(auxCode, vars{i});
    end
    data=data(:,relevantVar);
end


%% File for eReturn
fileResStata=[stataTempfilesPath,'/tableEReturn.csv'];
warning('off','MATLAB:DELETE:FileNotFound')
delete(fileResStata);
warning('on','MATLAB:DELETE:FileNotFound')

code='';
if(any(ismember('ereturn',typeOfReturn)))
    % Add program that reads eReturn
    funCode=fileread([stataProgramsPath,'/printLocalsEReturn.do']);
    assert(~isempty(funCode));
    code=[newline,funCode];
end

if(any(ismember('return',typeOfReturn)))
    funCode=fileread([stataProgramsPath,'/printLocalsReturn.do']);
    assert(~isempty(funCode));
    code=[newline,funCode];
end

% Open file to save eReturn
code=sprintf('%s  file open tabla using "%s", write replace\n',code,fileResStata);
code=sprintf('%s  %s\n',code,'file write tabla  "id,var,scalar,macro,matrix,isScalar,isMacro,isMatrix" _n');

%% Add each command
for c=1:size(command,1)
    switch typeOfReturn{c}
        case 'return'
            printLocals='printLocalsReturn';
        case 'ereturn'
            printLocals='printLocalsEReturn';
        otherwise
            error('aca')
    end
    code=sprintf('%s\n*__inicmd_id_%s_id__\n %s\n*__endcmd_id_%s_id__\n %s %s tabla\n\n',code,command{c,1},command{c,2},command{c,1},printLocals,command{c,1});
end

% Close eReturn file
code=sprintf('\n%s  %s\n',code,'file close _all	');

% Run the code
resStata=runStata(code,data,'addprecode',true,'getLog',true);

res=readEReturn(fileResStata);
resLog=readStataLog(resStata.log,command(:,1));

fieldNamesLog=fieldnames(resLog);
fieldNamesRes=fieldnames(res);
assert(all(ismember(fieldNamesLog,fieldNamesRes))&&all(ismember(fieldNamesRes,fieldNamesLog)))

cumlog='';
separator1=sprintf('* ==================================================================================');
separator2=sprintf('* ----------------------------------------------------------------------------------');
for f=1:length(fieldNamesLog)
    
    log_f=resLog.(fieldNamesLog{f});
    
    cumlog=[cumlog,sprintf('\n%s\n*  %s: \n%s\n\n',separator1,fieldNamesLog{f},separator2),log_f]; %#ok<AGROW>
    res.(fieldNamesLog{f}).log=log_f;
end


res.cumlog=cumlog;
if(displayLog)
    cprintf('*[0.0742,0.3711,0.5625]','----- INI LOG STATA ----\n')
    cprintf('[0.0742,0.3711,0.5625]','%s',cumlog);
    cprintf('*[0.0742,0.3711,0.5625]','----- END LOG STATA ----\n')
end
if(onlyOneCommand)
    assert(length(fieldNamesRes)==1)
    res=res.(fieldNamesRes{1});
end



