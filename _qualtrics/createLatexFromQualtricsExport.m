%{
AUTHOR: Felipe Arteaga
DATE:  2020--
-------------------------------------------------------------------------
PROJECT:
-------------------------------------------------------------------------
DESCRIPTION: Create latex of survey (and excel "easy-to-translate") from
the qualtrics exported dataset

=========================================================================
%}

clc;clear;close all;fclose('all');feature('DefaultCharacterSet','UTF-8');

pcName=char(java.lang.System.getProperty('user.name'));
if(strcmp(pcName,'felipe'))
    % PC Felipe
    myDir='/Users/felipe/Dropbox/';
    addpath(genpath([myDir,'/myMatlabFunctions/']));
    projectDir=[myDir,'/projects/cb-warnings-ecuador/'];
end


fileQualtrics='/Users/felipe/Dropbox/Mineduc/encuestas/riesgo2020/dataBruta/SAE_Encuesta_Satisfaccion - FULL sample_March 26, 2021_22.28.xlsx';
data=readQualtricsExport(fileQualtrics,'originalQuestionNames',true,'originalQuestionDescriptions',true);
vars=data.Properties.VariableNames;
questions=data.Properties.VariableDescriptions;
%%

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

% Manualy change answers of "select_one" questions.

data.QID212=renamecats(data.QID212,...s
    categories((data.QID212)),...
    {'COVID-19 did not affect my application process',' Without COVID-19, I would have known better the schools that I already know, but I would not have applied to more schools', 'Without COVID-19, I would have known more schools and perhaps I would have added them to my application '} );

data.QID151=renamecats(data.QID151,... 
{'Fue necesario averiguar más de ellos','No fue necesario buscar más información'},...
{'It was necessary to find out more about them', 'It was not necessary to search for more information'});


data.QID154=renamecats(data.QID154,... 
categories(data.QID154),...
{'I know the other options well and I prefer to have no placement than to add those alternatives','I think I will definitely be placed in one of the schools I applied for','It is very difficult to find more schools','There are no more schools close enough (good or bad)'});

data.QID156=renamecats(data.QID156,... 
{'No','Sí'},...
{'No','Yes'});
data.QID140=renamecats(data.QID140,... 
{'No','Sí'},...
{'No','Yes'});
data.QID147=renamecats(data.QID147,... 
{'No','Sí'},...
{'No','Yes'});


data.QID232=renamecats(data.QID232,... 
{'Correo electrónico','Otro','SMS','Teléfono','Whatsapp'},...
{'E-mail','Other','SMS','Telephone','Whatsapp'});


data.QID240=renamecats(data.QID240,...
{'No es prioritario','No sé','Sí es prioriatrio'},...
{'He/she is not a beneficiary of the preferential subsidy','I do not know','He/she is a beneficiary of the preferential subsidy'});


writecell([vars' mainQ' subQ'],dirBasura('q.xls'))

% Work on the sheet, then read it again to produce the latex
%%
a=readtable('/Users/felipe/Dropbox/myMatlabFunctions/_basura/q_worked_chile.xls','Sheet','translation','FileType','spreadsheet','VariableNamesRange','A1','DataRange','A2');
a=a(not(a.Ommit==1),:);
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
            latex=[latex,newline,'\item ',preLatex{i,1}];
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
