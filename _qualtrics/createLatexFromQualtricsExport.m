%{
AUTHOR: Felipe Arteaga
DATE:  2020--
-------------------------------------------------------------------------
PROJECT:
-------------------------------------------------------------------------
DESCRIPTION: Create latex of survey (and excel "easy-to-translate") from
the qualtrics exported dataset.

It will create an intermediate file (called q.xls) that needs work:

- Fill "Ommit" colum (leave empty if not-ommiting)

- For questions with more than alternative or subquestion: create an empty
row on top of it, fill the "type" and and "question" box. Erase the
"question"
for the many options, check that que question are ok.

- For questions with no alternatives or subquestion: do not create an empty
row on top of it


type column:
Select multiple 
Select one 
Slider X to X
Open text 
Text


=========================================================================
%}

clc;clear;close all;fclose('all');feature('DefaultCharacterSet','UTF-8');

pcName=char(java.lang.System.getProperty('user.name'));
if(strcmp(pcName,'felipe'))
    % PC Felipe
    myDir='/Users/felipe/Dropbox/';
    paths=split(genpath([myDir,'/myMatlabFunctions/']),':');paths=paths(~contains(paths,{'/.','\.'}));addpath(paths{:});clearvars('paths');
    projectDir=[myDir,'/projects/cb-warnings-ecuador/'];
end

% Elije si quiere traducir opciones de "select one" questions
translateSelectOne=true;

% File with qualtrics data (raw from qualtrics platform)
fileQualtrics=[myDir,'/projects/warningsBid/surveyPreResultados/peru2022/dataRaw/MatriculaDigital+-+Peru+-+Encuesta+Pre-resultados+-+2022_March+10,+2022_17.40.xlsx'];

% Raw files with questionnaire and alternatives for "Select on" quesitons 
rawFile=[myDir,'/projects/warningsBid/surveyPreResultados/peru2022/printSurveyLatex/q.xls'];
rawFileSelectOne=[myDir,'/projects/warningsBid/surveyPreResultados/peru2022/printSurveyLatex/qSelectOne.xls'];

% Worked files with questionnaire and alternatives for "Select on" quesitons 
workedFile=[myDir,'/projects/warningsBid/surveyPreResultados/peru2022/printSurveyLatex/q_worked.xlsx'];
workedSheet='Translation'; % 'Sheet1', 'Translation'

workedFileSelectOne=[myDir,'/projects/warningsBid/surveyPreResultados/peru2022/printSurveyLatex/qSelectOne_worked.xls'];
workedSheetSelectOne='Sheet1'; % 'Sheet1', 'Translation'


% Where to save the latex code (without preample) [leave blank if no
% saving]
fileOutput=[myDir,'/projects/warningsBid/surveyPreResultados/peru2022/printSurveyLatex/survey.tex'];


%% Load data

data=readQualtricsExport(fileQualtrics,'originalQuestionNames',true,'originalQuestionDescriptions',true);
vars=data.Properties.VariableNames;
questions=data.Properties.VariableDescriptions;

subQ=cell(size(questions));
mainQ=cell(size(questions));

% Distinguish between select multiple and select one.

for v=1:length(vars)
    isQuestion=startsWith(vars{v},'Q');
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


blank=repmat({''},length(vars),1);
writecell([{'Ommit','varName','type','options','question'};[blank vars' blank mainQ' subQ']],rawFile)

% Work on the "rawFile"! See instructions in the top. Then save the "workedFile"

a=readtable(workedFile,'Sheet',workedSheet,'FileType','spreadsheet','VariableNamesRange','A1','DataRange','A2');
a=a(not(a.Ommit==1),:);


if(translateSelectOne)

    % Exporta las alternativas

    alternativas=cell(0,1);
for i=1:height(a)
    type=a.type{i};
    if(not(isempty(type)))
        if(strcmp(type,'Select one'))
            % Get the options
            alternatives=unique(data.(a.varName{i}));
            alternatives=alternatives(not(ismissing(alternatives)));
            if(iscategorical(alternatives))
                alternativas=[alternativas;categories(alternatives)];
               
            else
                error('Es select one, pero no tiene alternativas como "categorical"')

            end
        end
    end
end


alternativas=unique(alternativas,'stable');
blank=repmat({''},length(alternativas),1);
writecell([{'options','translation'};[alternativas blank]],rawFileSelectOne)
    % Lee las traducciones
b=readtable(workedFileSelectOne,'Sheet',workedSheetSelectOne,'FileType','spreadsheet','VariableNamesRange','A1','DataRange','A2');

end




%% Imprime el latex
% 1: pregunta, 2: type, 3 alternative
preLatex=cell(height(a),2);
counter=0;



for i=1:height(a)
    type=a.type{i};
    qu=a.question{i};
    opt=a.options{i};
    
    
    if(not(isempty(type)))
        counter=counter+1;
        preLatex{counter,1}=strrep(qu,newline,'');
        preLatex{counter,2}=1;
        
        counter=counter+1;
        preLatex{counter,1}=type;
        preLatex{counter,2}=2;
        
        
        if(strcmp(type,'Select one'))
            % Get the options
            alternatives=unique(data.(a.varName{i}));
            alternatives=alternatives(not(ismissing(alternatives)));
            if(iscategorical(alternatives))
                alternatives=categories(alternatives);
                fprintf('\n%s - ',a.varName{i})
               genCellstr(alternatives)

               if(translateSelectOne)

                   [esta,pos]=ismember(alternatives,b.options);
                   assert(all(esta))
                   alternatives=b.translation(pos);

               end

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
if(not(isempty(fileOutput)))
    fileID = fopen(fileOutput,'w');
    fprintf(fileID,'%s',latex);
    fclose(fileID);


end
