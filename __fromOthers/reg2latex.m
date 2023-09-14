function reg2latex(mdl, varargin)
% function reg2latex(mdl, varargin)
% Produces a tex document summarizing the regression output.
%
% Syntax:
%	- sum_stat = reg2latex(mdl,filename, tabPosition, tabCaption, modelName, tabLabel, tabNote, addInfo)
%
% Note: 
%   - The function prints out the standard errors below the coefficients in
%     brackets.
%   - The function can handel the input of multiple models in order to
%     produce a table which list the results column wise.
%   - Numbers are rounded to the 4th digit.
%
% Input:
%   Required:
%	- mdl: 1x1 linear model (required)
%   Optional:
%   - filename: char (e.g.'myFolder/myTable1.tex')
%   - tabPosition: char (e.g. 'H' or other latex specific position settings)
%   - tabCaption: char (e.g. 'My personal caption')
%   - modelName: char (e.g. 'My fancy model 1')
%   - tabLabel: char (e.g. 'tab:myLabel')
%   - tabNote: char ('Some customized text.')
%   - addInfo: struct with additional information to be added below the
%   coefficients in the output table.
%
% Output:
%	- .tex: file to the current folder or the path specified in the
%	optional variable filename.

% Determine number of models
numModel = size(mdl,2);
% Get number of column separator for latex and the number of necessary columns in table
colSep = repmat('&',1,numModel);
colPos = repmat('c',1,numModel);

% Define default settings for table output
defaultFilename = 'table.tex';
defaultTabPosition = 'H';
defaultTabCaption = '';
defaultTabLabel = '';
defaultTabNote = '';
defaultTabInfo = struct;

% Construct default model names if no specific model name is parsed into the function
defaultModelName = '';
for iCol = 1:numModel
    temp = append(string(colSep(iCol)),' Model ',string(iCol));
    defaultModelName = char(append(defaultModelName, temp));
    clear temp
end

p = inputParser;
addRequired(p, 'mdl');
addOptional(p, 'filename', defaultFilename, @ischar);
addOptional(p, 'tabPosition', defaultTabPosition, @ischar);
addOptional(p, 'tabCaption', defaultTabCaption, @ischar);
addOptional(p, 'tabLabel', defaultTabLabel, @ischar);
addOptional(p, 'modelName', defaultModelName, @ischar)
addOptional(p, 'tabNote', defaultTabNote, @ischar);
addOptional(p, 'addInfo', defaultTabInfo, @isstruct);
parse(p, mdl, varargin{:});


% Check wether the modelName is correctly specified. If not set default
% model Name again
if count(p.Results.modelName,'&') ~= numModel   
    modelName = defaultModelName;
    warning('The model names have been incorrectly specified. They are replaced by the default names.')
else
    modelName = p.Results.modelName;
end

% Open file
file = fopen(p.Results.filename, 'w');

% Start table
fprintf(file, '\\begin{table}[%s] \n', p.Results.tabPosition);
fprintf(file, '\\centering \n');
% Set caption if input is not empty, else do not set caption
if ~isempty(p.Results.tabCaption)
    fprintf(file, '\\caption{%s} \n', p.Results.tabCaption);
end
fprintf(file, '\\label{%s}\n', p.Results.tabLabel);
fprintf(file, '\\begin{threeparttable}\n');
fprintf(file, '\\begin{tabular}{l%s}\n',colPos);
fprintf(file, '\\toprule \n');
% Design header
fprintf(file, '%s \\\\ \n', modelName);
fprintf(file, '\\midrule \n');

% Get maximum number of explanatory variables and unique number of
% variables
coefficients = nan(numModel,1);

for iModel = 1:numModel
    coefficients(iModel) = p.Results.mdl{1,iModel}.NumCoefficients;
end

% Get unique coefficient names
coefficientsNames = cell(1,numModel);
for iModel = 1:numModel
    coefficientsNamesTemp = char(p.Results.mdl{1,iModel}.CoefficientNames');
    coefficientsNames{1,iModel} =  char(coefficientsNamesTemp);
end

% Append vertically coefficient names
coefficientsNames = char(coefficientsNames);

% Add cell array of unique coefficient names
rowNamesUnique = unique(string(coefficientsNames));

% Remove empty first row

% Loop over models and append to one cell array
temp = cell(max(coefficients*2),numModel+1); % Create empty cell array

% Add unique row names to temp
idxTemp = 1:2:size(temp,1);
for iVar = 1:size(idxTemp,2)
    temp(idxTemp(iVar),1) = {strtrim(char((rowNamesUnique(iVar))))};
end

for iModel=1:numModel
    
    outCell = createTabelCell(p.Results.mdl{iModel});
    
    % Add variables to cell
    for iVar = 1:size(outCell,1)
        % Find variable in cell
        idxVar = find(strcmp(temp(:,1),outCell(iVar,1)));
        if isempty(idxVar)
            continue
        else
            temp(idxVar,iModel+1) = outCell(iVar,2); % add coefficients
            temp(idxVar+1,iModel+1) = outCell(iVar+1,2); % add coefficients
        end
    end
end

% Loop through every row
for iRow = 1:size(temp,1)
    
    % Check if Row number is divisible by 2. To place multirow
    % accordingly
    out=~rem(iRow,2)*iRow/2;
    
    % Format first column
    if out == 0
        % Format first column of variable names
        textVar = append('\multirow{2}{*}{',cell2mat(temp(iRow,1)),'}&');
        
        % Call function and create column text
        colText = createColText(temp,iRow);
        % Construct full column text
        colTextFull = append(textVar,colText);
        % Write column text to file
        fprintf(file,'%s \\\\ \n', colTextFull);
        
    else
        
        % Call function and create column text
        colTextFull = createColText(temp,iRow);
        
        % Write column text to file. Added & to reflect the fact that first
        % column is empty
        fprintf(file,'& %s \\\\ \n', colTextFull);
        
    end
end

% Loop over the additional input into the models if additional info was
% parsed
if ~isempty(fieldnames(p.Results.addInfo))
   
    % Add additional regresssion statistics to the output table
    fprintf(file, '\\midrule \n');
    
    for iAddInfo = 1:size(p.Results.addInfo.addFieldName,2)
        
        % Loop over additional entries
        infoName = p.Results.addInfo.addFieldName{iAddInfo};

        % Loop over models
        tempModels = fieldnames(p.Results.addInfo);
        
        temp = cell(1,numModel+1);
        
        % Write variable name into cell array
        temp{1,1} = infoName;
        
        % Loop starts at 2 because the first input in the struct contains the
        % names of the additional input
        for iModel = 2:size(tempModels,1)

          % Add information per model to cell
          temp{1,iModel} = p.Results.addInfo.(tempModels{iModel}).(infoName);
            
        end

        % Call function and create column text
        colText = createColText(temp,1);
        % Construct full column text
        colTextFull = append(infoName,' & ',colText);
        
        % Print row to file
        fprintf(file,'%s \\\\ \n', colTextFull);

    end
    
end

% Closing the file
fprintf(file, '\\bottomrule \n');
fprintf(file, '\\end{tabular} \n');
fprintf(file, '\\begin{tablenotes} \n');
fprintf(file, '\\scriptsize \n');
fprintf(file, '\\item \\leavevmode\\kern-\\scriptspace\\kern-\\labelsep Note:$^{*}$p$<$0.10,$^{**}$p$<$0.05,$^{***}$p$<$0.01 %s \n', p.Results.tabNote);
fprintf(file, '\\end{tablenotes}\n');
fprintf(file,'\\end{threeparttable} \n');
fprintf(file, '\\end{table} \n ');
fclose(file);

end