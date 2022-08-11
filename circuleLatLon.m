function [latLonCircule]=circuleLatLon(latCenter,lonCenter,radioKM)

assert(numel(latCenter)==1)
assert(numel(lonCenter)==1)
assert(numel(radioKM)==1)
% Get UTM zone
dczone = utmzone(latCenter,lonCenter);

utmstruct = defaultm('utm');
utmstruct.zone = dczone;
utmstruct.geoid = wgs84Ellipsoid;
utmstruct = defaultm(utmstruct);

[x,y] = projfwd(utmstruct,latCenter,lonCenter);

points=100;
r=radioKM*1000;
th = linspace(0,2*pi,points)';
xCirc = r * cos(th) + x;
yCirc = r * sin(th) + y;


[latCirc,lonCirc] = projinv(utmstruct,xCirc,yCirc);
latLonCircule=[latCirc,lonCirc];

%close all
%plot(lonCirc,latCirc,'LineStyle','--','LineWidth',3,'color',[234	67	53]/256	);