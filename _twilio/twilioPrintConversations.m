function twilioPrintConversations(logsTwilio,phone,varargin)



limitConversation=1; % In days
maxWidth=110;

if(~isempty(varargin))
    
    % This checks a few things, including if there is a struct called "opts"
    varargin=checkVarargin(varargin);
    
    while ~isempty(varargin)
        switch lower(varargin{1})
            case {'maxwidth'}
                maxWidth= varargin{2};
                
            otherwise
                error(['Unexpected option: ' varargin{1}])
        end
        varargin(1:2) = [];
    end
end

relevant=ismember(logsTwilio.newTo,phone)|ismember(logsTwilio.newFrom,phone);

logsTwilio=logsTwilio(relevant,:);

logsTwilio=sortrows(logsTwilio,'date');

N=height(logsTwilio);

lastDate=0;
conversationNum=0;
for i=1:N

    d=logsTwilio.date(i);
    f=logsTwilio.newFrom{i};
    t=logsTwilio.newTo{i};
    b=logsTwilio.body{i};

    if((d-lastDate)>limitConversation)
        conversationNum=conversationNum+1;
        fprintf('\n########################################\n### CONVERSATION %i #####################\n',conversationNum)
    end
 fprintf('\nFrom: %s | To: %s | Date: %s\n',f,t,datestr(d))

    for j=1:ceil(length(b)/maxWidth)

        fprintf('\n\t%s',b(1+maxWidth*(j-1):min(maxWidth*j,length(b))))

    end
    
    fprintf('\n')
    lastDate=d;
end