function temp = createTabelCell(mdl)

mdlCell = table2cell(mdl.Coefficients);

% Create stars for table output
for iPvalue = 1:size(mdl.Coefficients.pValue,1)
    
    % 1% significance
    if mdl.Coefficients.pValue(iPvalue) < 0.01
        
        starAdded = '$^{***}$';
        mdlCell{iPvalue,1} = append(num2str(round(mdl.Coefficients.Estimate(iPvalue),4)), starAdded);
        
    % 5% significance
    elseif mdl.Coefficients.pValue(iPvalue) > 0.01 && mdl.Coefficients.pValue(iPvalue) < 0.05
        
        starAdded = '$^{**}$';
        mdlCell{iPvalue,1} = append(num2str(round(mdl.Coefficients.Estimate(iPvalue),4)), starAdded);
        
    % 10% significance    
    elseif mdl.Coefficients.pValue(iPvalue) > 0.05 && mdl.Coefficients.pValue(iPvalue)< 0.1
        starAdded = '$^{*}$';
        mdlCell{iPvalue,1} = append(num2str(round(mdl.Coefficients.Estimate(iPvalue),4)), starAdded);
    end    
    
end

% Number of Variables
numRow = size(mdl.Coefficients,1)*2; % Multiple by 2 to allow the standard error to be printed below coefficient value

% Writing the data
temp = cell(numRow, 2);
posCoefficients = 1:2:size(temp);
posStandardError = 2:2:size(temp);

% Access and index mdl
temp(posCoefficients,2) = mdlCell(:,1); % Coefficients
temp(posStandardError,2) = mdlCell(:,2); % Standard erros

% Format coefficients and standard error if they are not significant
for iRow=1:size(temp,1)
    if ~ischar(temp{iRow,2})
        temp{iRow,2} = num2str(round(temp{iRow,2},4));
    end
    
    % Add parenthesis around standard errors
    if ~mod(iRow,2)
        temp{iRow,2} = append('(',temp{iRow,2},')');
    end
    
end

% Add row names
temp(posCoefficients) = mdl.Coefficients.Properties.RowNames;

end


