function removeNansFromTextFile(file,replaceNansWith)

if(nargin<2)
replaceNansWith='';
end
inputFilename = file;
outputFilename = file;


% If file is too big, is easier to read line by line
f=fileread(inputFilename);
mf = strrep(f, 'NaN', replaceNansWith);

outputFile = fopen(outputFilename, 'w');
fprintf(outputFile,'%s',mf);
fclose(outputFile);
