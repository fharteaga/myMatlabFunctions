function [lat,lon] = UTMtoLatLon(easting,northing,utmstruct)

% see latLonToUTM.m to check what is the utmstruct

[lat,lon] = projinv(utmstruct,easting,northing);