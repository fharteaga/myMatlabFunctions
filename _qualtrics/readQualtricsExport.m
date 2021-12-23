function data=readQualtricsExport(xlsxfile,varargin)

% First row is ID
% Second row is actual question
% Third row and beyond are data

% TSV y CSV are complicated beacuse there are "commas" and "tabs" in
% questions and answers.

% Exports a file that allows change of var name and var description.
% This file must be saved with the "_filled" sufijo.

%xlsxfile='/Users/felipe/Downloads/MatriculaDigital+-+Peru+-+Encuesta+Pre-resultados_March+17,+2021_19.12.xlsx';

originalQuestionNames=false;
originalQuestionDescriptions=false;
fileDictionary='';
deleteAnonymousSurveys=true;

if(~isempty(varargin))
    
    % This checks a few things, including if there is a struct called "opts"
    varargin=checkVarargin(varargin);
    
    while ~isempty(varargin)
        switch lower(varargin{1})
            case {'originalquestionnames'}
                originalQuestionNames= varargin{2};
            case {'originalquestiondescriptions'}
                originalQuestionDescriptions= varargin{2};
            case {'filedictionary'}
                fileDictionary= varargin{2};
                
            otherwise
                error(['Unexpected option: ' varargin{1}])
        end
        varargin(1:2) = [];
    end
end

if(exist(xlsxfile, 'file') == 2)
    
    data=readtable(xlsxfile,'FileType','spreadsheet','VariableNamesRange','A1','VariableDescriptionsRange','A2','DataRange','A3','VariableNamingRule', 'preserve');
    data=renamevars(data,"Duration (in seconds)",'durationInSec');
    
    % Check if any come from anonymus link:
    if(deleteAnonymousSurveys)
    anon=strcmp(data.DistributionChannel,'anonymous');
    if(any(anon))
        data=data(not(anon),:);
        cprintf('*systemcommand','[readQualtricsExport.m Unofficial Warning] ')
        cprintf('systemcommand','%.2f %% of obervations (%i of %i) are from "Anonymous link", which are dropped \n',(mean(anon))*100,sum((anon)),length(anon))

    end
    end
    % Export varnames and questions to manually create newVarnames
    auxT=table;
    auxT.varNames=data.Properties.VariableNames';
    auxT.newVarNames=scalarForTable({''},auxT);
    auxT.drop=scalarForTable(0,auxT);
    auxT.desc=data.Properties.VariableDescriptions';
    auxT.newDesc=scalarForTable({''},auxT);
    posExt=strfind(xlsxfile,'.xlsx');
    fileNameEmpty=[xlsxfile(1:posExt-1),'_renameVars.xls'];
    
    writetable(auxT,fileNameEmpty);
    
    if(isempty(fileDictionary))
        fileNameFilled=[xlsxfile(1:posExt-1),'_renameVars_filled.xls'];
    else
        fileNameFilled=fileDictionary;
        assert(exist(fileNameFilled, 'file') == 2,sprintf('\nNo se encontro el archivo:\n\n %s\n\nPor favor ingrese otro, gracias!',fileNameFilled))
    end
    
    % Import
    if(exist(fileNameFilled, 'file') == 2)
        newNames=readtable(fileNameFilled);
        assert(all(strcmp(newNames.varNames,auxT.varNames)))
        if(not(iscellstr(newNames.newDesc)))
        newNames.newDesc=mat2cellstr(newNames.newDesc,'wts',0);
        end
        
        for i=1:height(newNames)
            if(newNames.drop(i)==1)
                data.(newNames.varNames{i})=[];
            else
                if(not(isempty(newNames.newDesc{i}))&&not(originalQuestionDescriptions))
                    data.Properties.VariableDescriptions{newNames.varNames{i}}=newNames.newDesc{i};
                end
                if(not(isempty(newNames.newVarNames{i}))&&not(originalQuestionNames))
                    data=renamevars(data,newNames.varNames{i},newNames.newVarNames{i});
                end
            end
        end
    end
    
    maxUniqueAnswers=20;
    % Convert strings to categorical (if doesnt end on _text)
    vars=data.Properties.VariableNames;
    charNotToCategorical=false(size(vars));
    for v=1:width(data)
        var=data{:,v};
        if(iscellstr(var))
            % Check if has only numbers
            numOrEmpty=not(contains(var,lettersPattern))|cellfun(@isempty,var);
            if(all(numOrEmpty))
                data.(vars{v})=str2double(var);
            else
                % Check if has less than maxUniqueAnswers unique values:
                var=categorical(var);
                if(length(categories(var))<=maxUniqueAnswers)
                    data.(vars{v})=var;
                else
                    charNotToCategorical(v)=true;
                    
                end
            end
        end
    end
    
    if(any(charNotToCategorical))
        
        fprintf('%i vars were not converted in categorical because they have more than %i different answers:\n',sum(charNotToCategorical),maxUniqueAnswers);
        for v=1:width(data)
            if(charNotToCategorical(v))
                fprintf('\t %s\n',vars{v})
            end
        end
    end
    
else
    
    error('\nNo se encontro el archivo:\n\n %s\n\nPor favor ingrese otro, gracias!',xlsxfile)
    
end




