function [easting,northing,utmstruct] = latLonToUTM(lat,lon,varargin)

withWarning=true;
if(~isempty(varargin))
    
    % This checks a few things, including if there is a struct called "opts"
    varargin=checkVarargin(varargin);
    
    while ~isempty(varargin)
        switch lower(varargin{1})
            case {'withwarning'}
                withWarning= varargin{2};
                
            otherwise
                error(['Unexpected option: ' varargin{1}])
        end
        varargin(1:2) = [];
    end
end


assert(all(lon<=180)&all(lat<=90))
assert(all(lon>=-180)&all(lat>=-90))

dczone = utmzone(mean(lat,'omitnan'),mean(lon,'omitnan'));

if(withWarning)
    %        Check how many points are outside zone
    [latlim,lonlim] = utmzone(dczone);
    out=lat>latlim(2)|lat<latlim(1)|lon>lonlim(2)|lon<lonlim(1);

    if(any(out))
        fprintf('%.1f%% of observations are outside main utm zone: %s\n',mean(out)*100,dczone);
    end
end

utmstruct = defaultm('utm');
utmstruct.zone = dczone;
utmstruct.geoid = wgs84Ellipsoid;
utmstruct = defaultm(utmstruct);
[easting,northing] = projfwd(utmstruct,lat,lon);