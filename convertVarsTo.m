function inTable = convertVarsTo(inTable, varsToConvert,target)

% traget could be logical o categorical

% Loop through column names
for i = 1:numel(varsToConvert)
    % Get column index
    if(ismember(varsToConvert{i}, inTable.Properties.VariableNames))
        switch lower(target)
            case 'categorical'
                % Convert to categorical
                inTable.(varsToConvert{i}) = categorical(inTable.(varsToConvert{i}));
            case 'logical'
                % Convert to categorical (OJO: nans a 0!)
                inTable.(varsToConvert{i}) = inTable.(varsToConvert{i})==1;
            otherwise
                error('aca')
        end
    end

end