function [d1km]=lldistkm3(latlon1,latlon2)
% Calcula una matriz de distancia entre latlon1 Nx2 y latlon2 de 2xM

assert(size(latlon1,2)==2)
assert(size(latlon2,1)==2)

N=size(latlon1,1);
M=size(latlon2,2);

haversian=true;

% format: [d1km d2km]=lldistkm(latlon1,latlon2)
% Distance:
% d1km: distance in km based on Haversine formula
% (Haversine: http://en.wikipedia.org/wiki/Haversine_formula)
% d2km: distance in km based on Pythagoras’ theorem
% (see: http://en.wikipedia.org/wiki/Pythagorean_theorem)
% After:
% http://www.movable-type.co.uk/scripts/latlong.html
%
% --Inputs:
%   latlon1: latlon of origin point [lat lon]
%   latlon2: latlon of destination point [lat lon]
%
% --Outputs:
%   d2km: distance calculated by Haversine formula
%   d1km: distance calculated based on Pythagoran theorem
%
% --Example 1, short distance:
%   latlon1=[-43 172];
%   latlon2=[-44  171];
%   [d1km d2km]=distance(latlon1,latlon2)
%   d1km =
%           137.365669065197 (km)
%   d2km =
%           137.368179013869 (km)
%   %d1km approximately equal to d2km
%
% --Example 2, longer distance:
%   latlon1=[-43 172];
%   latlon2=[20  -108];
%   [d1km d2km]=distance(latlon1,latlon2)
%   d1km =
%           10734.8931427602 (km)
%   d2km =
%           31303.4535270825 (km)
%   d1km is significantly different from d2km (d2km is not able to work
%   for longer distances).
%
% First version: 15 Jan 2012
% Updated: 17 June 2012
%--------------------------------------------------------------------------

d1km=nan(N,M);

radius=6371;

for m=1:M
    
    lat1=latlon1(:,1)*pi/180;
    lat2=latlon2(1,m)*pi/180;
    lon1=latlon1(:,2)*pi/180;
    lon2=latlon2(2,m)*pi/180;
    
    deltaLat=lat2-lat1;
    deltaLon=lon2-lon1;
    
    if(haversian)
        %% Haversine distance
        a=sin((deltaLat)/2).^2 + cos(lat1).*cos(lat2) .* sin(deltaLon/2).^2;
        c=2*atan2(sqrt(a),sqrt(1-a));
        d1km(:,m)=radius*c;
        
    else
        %% Pythagoran distance
        x=deltaLon.*cos((lat1+lat2)/2);
        y=deltaLat;
        d1km(:,m)=radius*sqrt(x.*x + y.*y);
    end
end
end