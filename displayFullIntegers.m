function output=displayFullIntegers(input)
varsT=input.Properties.VariableNames;
for v=1:length(varsT)
    if(isnumeric(input.(varsT{v})))
        input.(varsT{v})=mat2cellstr(input.(varsT{v}),'wts',false);
    end
end


output=input;