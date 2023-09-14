function data=readQualtricsExport(xlsxfile,varargin)
%
% This function does a lot of things:
% (1) read the data from XLSX export of qualtrics
% (2) export an XLS to rename, re-describe and drop variables
%       -> Uses it to rename, re-describe and drop variables the final
%       dataset
% (3) export an XLS to translate the alternatives
%       -> Uses it to translate the alternatives
% (4) export an XLS to give format in order to export the questionnaire into latex
%       -> Uses it to create a latex file with the questionnaire
%
%   *(2) and (4) create different variable descriptions: first one for the
% matlab table (used in plots), second one for the latex version of the
% survey
%   *(3) generates alternative to label values on matlab table and on the
% latex version of the survey
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FOR EXPORTING THE DATA FROM QUALTRICS.
%   TSV y CSV are complicated beacuse there are "commas" and "tabs" in
%   questions and answers. Use XLSX!
%   Check the "advance option" to export select multiple answeres into
%   multiple columns
%
%   Warning: sometimes qualtrics export two variables with the same name.
%   On those cases matlab put the original name on the description, so
%   actual descriptions do not appear in the table.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FOR THE XLS of (2):
%   First row is ID
%   Second row is actual question
%   Third row and beyond are data
% Exports a file that allows change of var name and var description.
% This file must be saved with the "_filled" sufijo (or input the name
% otherwise)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FOR THE XLS of (4):
% - Fill "Ommit" colum (leave empty if not-ommiting)
% 
% - For questions with more than alternative or subquestion: create an empty
% row on top of it, fill the "type" and "question" box. Erase the
% "question" for the options, check that que question are ok.
% 
% 
% - For questions with no alternatives or subquestion: do not create an empty
% row on top of it
% 
% 
% type column:
% Select multiple 
% Select one 
% Slider X to X
% Open text 
% Text


originalQuestionNames=false;
originalQuestionDescriptions=false;

deleteAnonymousSurveys=true;
doNotConvertToCat={};
dropVars={};
printLatex=false;
useSubsetOfDict=false;
addVars=cell(0,2);% Rows are independent vars. Column 1 is name. Column 2 is the value (same for each obs!)


% Elije si quiere traducir opciones de "select one" questions
translateSelectOne=true;
dirWorkingSheets=xlsxfile(1:find(xlsxfile=='/',1,'last'));

% Raw files with questionnaire for Latex and alternatives from "Select one" questions
rawFileQuestTable=[dirWorkingSheets,'/questionsForTableVariablesAndDesc.xls'];
rawFileQuestLatex=[dirWorkingSheets,'/questionsForLatex.xls'];
rawFileSelectOne=[dirWorkingSheets,'/selectOneOptions.xls'];

% Worked files with questionnaire for Latex and alternatives for "Select one" quesitons
workedFileQuestTable=[rawFileQuestTable(1:end-4),'_worked.xls'];
workedFileQuestLatex=[rawFileQuestLatex(1:end-4),'_worked.xls'];
workedSheetQuestLatex='Translation'; % 'Sheet1', 'Translation'
workedFileSelectOne=[rawFileSelectOne(1:end-4),'_worked.xls'];
workedSheetSelectOne='Sheet1'; % 'Sheet1', 'Translation'

selectOneFileInput=false;


% Where to save the latex code (without preample) [leave blank if no
% saving]
latexOutput=[dirWorkingSheets,'/survey.tex'];

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
                workedFileQuestTable= varargin{2};
            case {'filetranslationselectone'}
                workedFileSelectOne= varargin{2};
                selectOneFileInput=true;
            case {'donotconverttocat'}
                doNotConvertToCat= varargin{2};
            case {'printlatex'}
                printLatex= varargin{2};
            case {'dropvars'}
                dropVars= varargin{2};
            case {'addvars'}
                addVars= varargin{2};
            case {'usesubsetofdict'}
                useSubsetOfDict= varargin{2};


            otherwise
                error(['Unexpected option: ' varargin{1}])
        end
        varargin(1:2) = [];
    end
end

if(exist(xlsxfile, 'file') == 2)

    data=readtable(xlsxfile,'FileType','spreadsheet','VariableNamesRange',1,'VariableDescriptionsRange',2,'DataRange','A3','VariableNamingRule', 'preserve');
else

    error('\nNo se encontro el archivo:\n\n %s\n\nPor favor ingrese otro, gracias!',xlsxfile)

end



%% Clean anonymus:

data=renamevars(data,"Duration (in seconds)",'durationInSec');
%[data.Properties.VariableNames',data.Properties.VariableDescriptions']

% Check if any come from anonymus link:
if(deleteAnonymousSurveys)
    anon=strcmp(data.DistributionChannel,'anonymous');
    if(any(anon))
        data=data(not(anon),:);
        cprintf('*systemcommand','[readQualtricsExport.m Unofficial Warning] ')
        cprintf('systemcommand','%.2f %% of obervations (%i of %i) are from "Anonymous link", which are dropped \n',(mean(anon))*100,sum((anon)),length(anon))

    end
end

% Drop vars:
for v=1:length(dropVars)
data.(dropVars{v})=[];
end

% Add vars:
for v=1:size(addVars,1)
    assert(not(ismember(addVars{v,1},data.Properties.VariableNames)))
    data.(addVars{v,1})=scalarForTable(addVars{v,2},data);
end

%% Variable dropping and name changing:

% Export varnames and questions to manually create newVarnames
auxT=table;
auxT.varNames=data.Properties.VariableNames';
auxT.newVarNames=scalarForTable({''},auxT);
auxT.drop=scalarForTable(0,auxT);
auxT.desc=data.Properties.VariableDescriptions';
auxT.newDesc=scalarForTable({''},auxT);

writetable(auxT,rawFileQuestTable);

fileNameFilled=workedFileQuestTable;
assert(exist(fileNameFilled, 'file') == 2,sprintf('\nNo se encontro el archivo:\n\n %s\n\nPor favor ingrese otro, gracias!',fileNameFilled))


% Import
if(exist(fileNameFilled, 'file') == 2)

    varNames=readtable(fileNameFilled);
    if(useSubsetOfDict)
            varNames=varNames(ismember(varNames.varNames,auxT.varNames),:);
            varNames=sortrows(varNames,'varNames');
            auxT=sortrows(auxT,'varNames');
    end

    allIn1=ismember(auxT.varNames,varNames.varNames);
    if(any(not(allIn1)))
        fprintf('There are vars in the data that are not in the dictionary. Fix the dictionary (or pre-drop the vars with opt dropVars)\n')
        varsAux=auxT.varNames(not(allIn1));
        fprintf('\t%s\n',varsAux{:})
        error('Se message above')
    end
    allIn2=ismember(varNames.varNames,auxT.varNames);
    if(any(not(allIn2)))
                fprintf('There are vars in the dictionary that are not in the data. Maybe try opt  ''useSubsetOfDict'',true\n')

        varsAux=varNames.varNames(not(allIn2));
        fprintf('\t%s\n',varsAux{:})
               error('Se message above')
    end
    
    assert(all(strcmp(varNames.varNames,auxT.varNames)))
    
    assert(allunique(varNames.newVarNames(not(ismissing(varNames.newVarNames)))))
    assert(allunique(varNames.varNames))


    if(not(iscellstr(varNames.newDesc)))
        varNames.newDesc=mat2cellstr(varNames.newDesc,'wts',0);
    end
    if(not(iscellstr(varNames.newVarNames)))
        varNames.newVarNames=mat2cellstr(varNames.newVarNames,'wts',0);
    end

    for i=1:height(varNames)
        if(varNames.drop(i)==1)
            data.(varNames.varNames{i})=[];
        else
            if(not(isempty(varNames.newDesc{i}))&&not(originalQuestionDescriptions))
                data.Properties.VariableDescriptions{varNames.varNames{i}}=varNames.newDesc{i};
            end
            if(not(isempty(varNames.newVarNames{i}))&&not(originalQuestionNames))
                data=renamevars(data,varNames.varNames{i},varNames.newVarNames{i});
            end
        end
    end
end

maxUniqueAnswers=20;
% Convert strings to categorical (if doesnt end on _text, and not is in
% cell doNotConvertToCat
vars=data.Properties.VariableNames;
charNotToCategorical=false(size(vars));
convertedToCategorical=false(size(vars));
for v=1:width(data)
    var=data{:,v};
    if(iscellstr(var))
        % Check if has only numbers
        numOrEmpty=not(contains(var,lettersPattern))|cellfun(@isempty,var);
        if(all(numOrEmpty))
            data.(vars{v})=str2double(var);
        elseif(not(ismember(vars{v},doNotConvertToCat)))
            % Check if has less than maxUniqueAnswers unique values:
            var=categorical(var);
            if(length(categories(var))<=maxUniqueAnswers)
                data.(vars{v})=var;
                convertedToCategorical(v)=true;
            else
                charNotToCategorical(v)=true;

            end
        end
    end
end

categoricalVars=vars(convertedToCategorical);

if(any(charNotToCategorical))

    fprintf('%i vars were not converted in categorical because they have more than %i different answers:\n',sum(charNotToCategorical),maxUniqueAnswers);
    for v=1:width(data)
        if(charNotToCategorical(v))
            fprintf('\t %s\n',vars{v})
        end
    end
end


%% Alternative translation and classification of type of question for latex


originalNameVars=varNames.varNames;
newNameVars=varNames.newVarNames;
questions=varNames.desc;

originalNameVars=reshape(originalNameVars,length(originalNameVars),1);
newNameVars=reshape(newNameVars,length(newNameVars),1);


subQ=cell(size(questions));
mainQ=cell(size(questions));

% Distinguish between select multiple and select one.

for v=1:length(originalNameVars)
    isQuestion=startsWith(originalNameVars{v},'Q');
    if(isQuestion)
        posGuion=strfind(questions{v},' - ');
        if(not(isempty(posGuion)))

            subQ{v}=questions{v}(1:posGuion(end)-1);
            mainQ{v}=questions{v}(posGuion(end)+3:end);
        else

            mainQ{v}=questions{v};
        end

    end
end


blank=repmat({''},length(originalNameVars),1);
writecell([{'Ommit','originalVarName','newVarName','type','options','question'};[num2cell(varNames.drop) originalNameVars newNameVars blank mainQ subQ]],rawFileQuestLatex)

% Work on the "rawFile"! See instructions in the top. Then save the "workedFile"

if(exist(workedFileQuestLatex,'file')>0)
    qClassification=readtable(workedFileQuestLatex,'Sheet',workedSheetQuestLatex,'FileType','spreadsheet','VariableNamesRange','A1','DataRange','A2');
    qClassification=qClassification(not(qClassification.Ommit==1),:);
    withQClassification=true;
else

    withQClassification=false;
end


if(translateSelectOne)
    % Exporta las alternativas, dos caminos:
    % 1) Si hiciste la pega de clasificar las preguntas entre select one y
    % eso, entonces usa esa info
    % 2) Si no hiciste la pega, clasifica como select one si hay a los mas
    % veinte respuestas unicas

    alternativas=cell(0,1);


    if(withQClassification)
        % Alternativa (1)
        for i=1:height(qClassification)
            type=qClassification.type{i};
            if(not(isempty(type)))
                if(strcmpi(type,'Select one'))
                    % Get the options
                    alternatives=unique(data.(qClassification.varName{i}));
                    alternatives=alternatives(not(ismissing(alternatives)));
                    if(iscategorical(alternatives))
                        alternativas=[alternativas;categories(alternatives)];

                    else
                        error('Es select one, pero no tiene alternativas como "categorical"')

                    end
                end
            end
        end

    else
        % Alternativa (2)
        for i=1:length(categoricalVars)


            % Get the options
            alternativesVar=unique(data.(categoricalVars{i}));
            alternativesVar=alternativesVar(not(ismissing(alternativesVar)));
            if(iscategorical(alternativesVar))
                alternativas=[alternativas;categories(alternativesVar)];

            else
                error('Es select one, pero no tiene alternativas como "categorical"')

            end


        end

    end


    [alternativas]=unique(alternativas,'stable');


    blank=repmat({''},length(alternativas),1);
    writecell([{'options','translation'};[alternativas blank]],rawFileSelectOne)
    % Lee las traducciones

    if(selectOneFileInput)
        assert(exist(workedFileSelectOne, 'file') == 2,sprintf('\nNo se encontro el archivo:\n\n %s\n\nPor favor ingrese otro, gracias!',workedFileSelectOne))
        withAlternativeTranslation=true;
    elseif(exist(workedFileSelectOne,'file')==2)

        withAlternativeTranslation=true;
    else
        withAlternativeTranslation=false;

    end
end

if(withAlternativeTranslation)

    alternativeTranslation=readtable(workedFileSelectOne,'Sheet',workedSheetSelectOne,'FileType','spreadsheet','VariableNamesRange','A1','DataRange','A2');

     % Check that files contains all of them:
     missingOpts={};
     
    for i=1:length(categoricalVars)

        % Get the options
        alternatives=categories(data.(categoricalVars{i}));
        [esta]=ismember(alternatives,alternativeTranslation.options);
      
        if(not(all(esta)))

            fprintf('No hay traduccion para alternativas de la pregunta %s \n',categoricalVars{i})
            fprintf('\t%s\n',alternatives{:})
            fprintf('\n')
            missingOpts=[missingOpts;alternatives(not(esta))]; %#ok<AGROW> 
    
            
        end
   
    end
    if(not(isempty(missingOpts)))
        missingOpts=unique(missingOpts,'stable');
       fprintf('%s\n',missingOpts{:})
            error('Falta traducir alternativas!')
    end


    % Translate alternatives
    for i=1:length(categoricalVars)


        % Get the options
        alternatives=categories(data.(categoricalVars{i}));

        [esta,pos]=ismember(alternatives,alternativeTranslation.options);
        assert(all(esta))
        if(not(all(esta)))
            fprintf('%s\n',alternatives{not(esta)})
            error('Falta traducir alternativas!')

        end
        translatedAlternatives=alternativeTranslation.translation(pos);

        data.(categoricalVars{i})=renamecats(data.(categoricalVars{i}),alternatives,translatedAlternatives);


    end
end



%% Create inputs to print latex


if(printLatex)
    if(withQClassification)
        %% Imprime el latex
        % 1: pregunta, 2: type, 3 alternative
        preLatex=cell(height(qClassification),2);
        counter=0;



        for i=1:height(qClassification)
            type=qClassification.type{i};
            qu=qClassification.question{i};
            opt=qClassification.options{i};


            if(not(isempty(type)))
                counter=counter+1;
                preLatex{counter,1}=strrep(qu,newline,'');
                preLatex{counter,2}=1;

                counter=counter+1;
                preLatex{counter,1}=type;
                preLatex{counter,2}=2;


                if(strcmp(type,'Select one'))
                    % Get the options
                    alternatives=unique(data.(qClassification.varName{i}));
                    alternatives=alternatives(not(ismissing(alternatives)));
                    if(iscategorical(alternatives))
                        alternatives=categories(alternatives);
                        fprintf('\n%s - ',qClassification.varName{i})
                        genCellstr(alternatives)

                        %                if(translateSelectOne)
                        %
                        %                    [esta,pos]=ismember(alternatives,alternativeTranslation.options);
                        %                    assert(all(esta))
                        %                    alternatives=alternativeTranslation.translation(pos);
                        %
                        %                end

                    end
                    for j=1:length(alternatives)
                        counter=counter+1;
                        preLatex{counter,1}=alternatives{j};
                        preLatex{counter,2}=3;
                    end
                end

            elseif(not(isempty(opt)))
                counter=counter+1;
                preLatex{counter,1}=opt;
                preLatex{counter,2}=3;
            end

        end
        preLatex=preLatex(1:counter,:);

        % Make latex

        latex='\begin{enumerate}';
        nuevaPreg=true;

        for i=1:size(preLatex,1)
            type=preLatex{i,2};
            switch type
                case 1
                    if(i>1&&not(nuevaPreg))
                        latex=[latex,newline,'\end{enumerate}'];
                    end
                    latex=[latex,newline,'\item ',preLatex{i,1}];
                    nuevaPreg=true;
                case 2
                    latex=[latex,'\\ ','[\textit{',preLatex{i,1},'}]'];

                case 3
                    if(nuevaPreg)
                        latex=[latex,newline,'\begin{enumerate}'];
                    end
                    nuevaPreg=false;
                    latex=[latex,newline,sprintf('\t'),'\item ',preLatex{i,1}];
            end

        end
        if(not(nuevaPreg))
            latex=[latex,newline,'\end{enumerate}'];
        end
        latex=[latex,newline,'\end{enumerate}'];

        matSpecial={...
            '$','\$';...
            '[','$[$';...
            ']','$]$';...
            '%','\%';...
            '>=','$\geq$';...
            '<=','$\leq$';...
            '<','$<$';...
            '>','$>$';...
            '_','\_';...
            '|','$|$';...
            };

        for i=1:size(matSpecial,1)
            latex=strrep(latex,matSpecial{i,1},matSpecial{i,2});
        end


        compileLatex(latex)
        if(not(isempty(latexOutput)))
            fileID = fopen(latexOutput,'w');
            fprintf(fileID,'%s',latex);
            fclose(fileID);

        end

    else
        error('To print the latex of the questions the classification file (manual process) is needed!')
    end
end



end % End function
