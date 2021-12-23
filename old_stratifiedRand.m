function tipo=stratifiedRand_old(tabla,numTreats,relativeSize)

% tabla is a Table with all the relevant strat var

% This version does not consider stratification in subsets of strata


stratVars=tabla.Properties.VariableNames;




strataMinSize=nan;
if(nargin==2)
    assert(numel(numTreats)==1,'Number of treatments not provided')
    relativeSize=ones(1,numTreats)/numTreats;
    strataMinSize=numTreats;
else
    %% Minum size of strata
    for i=2:20
        mod_=mod(relativeSize*i,1);
        if(all(mod_<1e-14))
            strataMinSize=i;
            break
        end
    end
end
assert(length(relativeSize)==numTreats);
assert(abs(sum(relativeSize)-1)<1e-14,'Sum of relative sizes must be 1')
assert(not(isnan(strataMinSize)))

assert(not(ismember('ones_SR',stratVars)))
assert(not(ismember('random_SR',stratVars)))
assert(not(ismember('tipo',stratVars)))
assert(not(ismember('orden_SR',stratVars)))
assert(not(ismember('ordenOrig_SR',stratVars)))

% Original sort:

tabla.ordenOrig_SR=(1:height(tabla))';
tabla.random_SR=rand(height(tabla),1);
tabla.ones_SR=ones(height(tabla),1);




%%

varsCollapse={'ones_SR'};
customFun=struct;
statsCollapse={'sum'};

for i=1:(numTreats-1)
    stat=sprintf('relSize%i',i);
    statsCollapse=[statsCollapse,{['c_',stat]}]; %#ok<AGROW>
    varsCollapse=[varsCollapse,{'random_SR'}]; %#ok<AGROW>
    customFun.(stat)=@(x)quantile(x,sum(relativeSize(1:i)));
end



% I sort according to random_SR beacause I want to clasify the misfits randomly:
tabla=sortrows(tabla,[stratVars,'random_SR']);
tabla.orden_SR=(1:height(tabla))';
tabla=stataCollapse(stratVars,tabla,{'orden_SR','ones_SR'},{'min','sum'},'mergewithoriginal',true);
tabla.ordenWithinGroup=tabla.orden_SR-tabla.orden_SR_min+1;

% Clasify misfits:
tabla.isMisfit=tabla.ordenWithinGroup<=mod(tabla.ones_SR_sum,strataMinSize);
tabla.ones_SR_sum=[];

% Assing treatment in each stratum that is NOT misfits (I do not use the
% assigment for misfits of this procedure)
tabla=sortrows(tabla,[stratVars,'isMisfit']);
tabla=stataCollapse([stratVars,'isMisfit'],tabla,varsCollapse,statsCollapse,'mergewithoriginal',true,'customfun',customFun);

tabla.tipo=ones(height(tabla),1);

for i=1:(numTreats-1)
    stat=sprintf('c_relSize%i',i);
    tabla.tipo=tabla.tipo+double(tabla.random_SR>tabla.(['random_SR_',stat]));
end

% Now, I assign treatment within the fake stratum of misfits.
tabla.tipo(tabla.isMisfit)=1;

for i=1:(numTreats-1)
    stat=sprintf('relSize%i',i);
    tabla.tipo(tabla.isMisfit)=tabla.tipo(tabla.isMisfit)+double(tabla.random_SR(tabla.isMisfit)>customFun.(stat)(tabla.random_SR(tabla.isMisfit)));
end

fprintf('Randomization within strata\n')
tab(tabla.tipo(not(tabla.isMisfit)));
fprintf('Randomization out of strata\n')
tab(tabla.tipo(tabla.isMisfit));



tabla=sortrows(tabla,'ordenOrig_SR');
tipo=tabla.tipo;

%% Si hay que imponer igual random_SRe para misma familia:


% Now, apoderados with more than one kid have the same treatment:

% datosEnviar.random_SRApod=rand(height(datosEnviar),1);
% datosEnviar.hijos=ones_SR(height(datosEnviar),1);
% datosEnviar=sortrows(datosEnviar,{'id_apoderado','random_SRApod'});
% datosEnviar=stataCollapse({'id_apoderado'},datosEnviar,{'hijos','tipo'},{'sum','first'},'mergewithoriginal',true);
% % Si tiene más de un hijo, me quedo con un solo treat:
% datosEnviar.tipo(datosEnviar.hijos_sum>1)=datosEnviar.tipo_first(datosEnviar.hijos_sum>1);
%
% if(saveWithIdApod)
%     assert(all(datosEnviar.hijos_sum==1))
%     save(sprintf('/Users/felipe/Dropbox/Mineduc/modelacion/riesgo/SMS/2020/muestraWhatsapp_%s',datestr(now)),'datosEnviar')
% end
% else
%    load('/Users/felipe/Dropbox/Mineduc/modelacion/riesgo/SMS/2020/muestraWhatsapp_05-Sep-2020 00:09:09.mat')
% end
%
% datosGenerales=outerjoin(datosGenerales,datosEnviar,'key','id_postulante','mergekeys',true,'type','left','rightvariables','tipo');
% datosGenerales=sortrows(datosGenerales,{'id_postulante'});
% assert(all(isnan(datosGenerales.tipo(not(datosGenerales.enviar)))));
% assert(all(not(isnan(datosGenerales.tipo((datosGenerales.enviar))))));
%
% % If has more than 13 pref, I assign the no list treatment
% assert(sum(not(isnan(datosGenerales.tipo))&datosGenerales.cantPost>13)<40)
% datosGenerales.tipo(not(isnan(datosGenerales.tipo))&datosGenerales.cantPost>13)=2;
%
% tab(datosGenerales.tipo);