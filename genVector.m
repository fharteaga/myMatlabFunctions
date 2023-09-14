function genVector(vector)


fmt = [' [', repmat('%g, ', 1, numel(vector)-1), '%g]'];


showShorcut(sprintf(fmt, vector));

