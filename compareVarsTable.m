function compareVarsTable(tab1,tab2)

error('This function is not updated anymore, use getCommonVars({tab1,tab2},''diagnosticCommonVars'',true)')


% 
% v1=tab1.Properties.VariableNames;
% v2=tab2.Properties.VariableNames;
% 
% both1=ismember(v1,v2);
% both2=ismember(v2,v1);
% 
% if(any(both1))
%     fprintf('In Both:\n')
%     fprintf('\t%s\n',v1{both1})
% end
% 
% if(any(not(both1)))
%     fprintf('\nOnly table 1:\n')
%     fprintf('\t%s\n',v1{not(both1)})
% end
% 
% if(any(not(both2)))
%     fprintf('\nOnly table 2:\n')
%     fprintf('\t%s\n',v2{not(both2)})
% end
