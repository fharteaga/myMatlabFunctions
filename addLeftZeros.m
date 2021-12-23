function numStr=addLeftZeros(num,width)

numStr=num2str(num);
if(length(numStr)<width)
    numStr=[repmat('0',1,width-length(num)),numStr];
end