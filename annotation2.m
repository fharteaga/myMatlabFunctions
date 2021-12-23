function tx=annotation2(type,pos,orientation,varargin)

% annotation2('textbox',[x,y],'n','String','holaaa')

switch lower(type)
    case 'textbox'
        switch lower(orientation)
            case 'e'
                % position=[pos,1,0];
                hAlig='left';
                vAlig='middle';
            case 'w'
                % position=[pos-[1 0],1,0];
                hAlig='right';
                vAlig='middle';
            case 'n'
                % position=[pos,0,0];
                hAlig='center';
                vAlig='bottom';
            case 's'
                % position=[pos,0,0];
                hAlig='center';
                vAlig='top';
            case {'c','0','o'}
                % position=[pos,0,0];
                hAlig='center';
                vAlig='middle';
            case 'ne'
                % position=[pos,1,0];
                hAlig='left';
                vAlig='bottom';
            case 'nw'
                % position=[pos-[1 0],1,0];
                hAlig='right';
                vAlig='bottom';
            case 'se'
                % position=[pos,1,0];
                hAlig='left';
                vAlig='top';
            case 'sw'
                % position=[pos-[1 0],1,0];
                hAlig='right';
                vAlig='top';
            otherwise
                error('No programaodoo!')
        end
        
    otherwise
        error('No programaodoo!')
end


tx=text('Position',pos,'verticalAlignment',vAlig,'HorizontalAlignment',hAlig,varargin{:});


