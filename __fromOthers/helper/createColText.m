function colText = createColText(temp,iRow)

% Construct column text by looping over column in a specific row
colText = '';
for iCol = 2:size(temp,2)
    
    % Last column does not need a & in Latex
    if iCol == size(temp,2)
        tempRow = string(cell2mat(temp(iRow, iCol)));
        if isempty(tempRow)
            continue
        end
    else
        tempRow = append(string(cell2mat(temp(iRow, iCol))),' & ');
        % Can be empty if the first model does not contain all variables
        if isempty(tempRow)
            tempRow = ' &';
        end
    end
    colText = char(append(colText, tempRow));
end


end