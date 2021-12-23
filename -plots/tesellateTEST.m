    
clear
clc
fakedata=false;
    
if(fakedata)
    N=10000;
    
    xData=randn(N,1);
    yData=randn(N,1);
    
    latlon=false;
    

else
load('/Users/felipe/Dropbox/projects/warnings/data/chile/inputRD.mat','dataRD')
    
    sirve=lldistkm3([dataRD.latitud_meanIni,dataRD.longitud_meanIni],[ -33.4176;-70.6510])<15;
    dataa=dataRD(sirve,:);
    yData=dataa.latitud_meanIni;
    xData=dataa.longitud_meanIni;
    latlon=true;

end

var=randn(length(yData),1);

%tessellate(xData,yData,var,'latlon',latlon,'num',30,'stat','q.25')
tessellate(xData,yData)