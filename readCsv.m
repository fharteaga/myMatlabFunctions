
function data=readCsv(archivo,varargin)
% This might be a useful function only if readtable is extremly slow...
warning('Using "readCsv.m". Consider changing to "readtable.m"')
if(exist(archivo, 'file') == 2)
    
    fid = fopen(archivo,'r','n','utf-8');
    
    
    %% Reviso el input
    % Default values
    
    stringFormat='%s';
    numberFormat='%f64';
    delimiter=','; % Opciones: '\t' ';' '|'
    buscarStrings=false;
    conTipoVar=false;
    dataInTable=true;
    
    % Viene un cell {nombreVar,tipo} que definen la var y el tipo (o un
    % cell con varios pares {{nombreVar1,tipo1},{nombreVar1,tipo1}} )
    conTipoVarEspecifico=false;
    
    if(~isempty(varargin))  
    varargin=checkVarargin(varargin);
    
    % Loading optional arguments
    while ~isempty(varargin)
        switch lower(varargin{1})
            case 'delimiter'
                delimiter = varargin{2};
            case {'stringvars','stringvar'}
                buscarStrings=true;
                sonStringsVars=varargin{2};
                if(not(iscellstr(sonStringsVars))) %#ok<ISCLSTR>
                    sonStringsVars={sonStringsVars};
                end
            case 'tipovar'
                conTipoVar=true;
                tipoVar=varargin{2};
            case 'tipovarespecifico'
                conTipoVarEspecifico=true;
                tipoVarEspecifico=varargin{2};
                if(not(iscellstr(tipoVarEspecifico{1})))
                    tipoVarEspecifico={tipoVarEspecifico};
                end
            case 'numberformat'
                numberFormat=varargin{2};
            case 'dataset'
                dataInTable=not(varargin{2});
            otherwise
                error(['Unexpected option: ' varargin{1}])
        end
        varargin(1:2) = [];
    end
    
    end
    
    primerLinea=fgetl(fid);
    preHeaders = textscan(primerLinea,'%s','delimiter',delimiter);
    headers=preHeaders{1};
    
    % Remove wired characters (non numeric, letter or _):
    numericOrUnderscore=[48:57,95];
    
    for h=1:length(headers)
        valid=isletter(headers{h})|ismember(double(headers{h}),numericOrUnderscore);
        if(not(all(valid)))
            warning('Header "%s" is not valid, replaced with "%s"',headers{h},headers{h}(valid))
            headers{h}=headers{h}(valid);
        end
    end
    
    
    if(conTipoVar)
        assert(not(conTipoVarEspecifico))
        assert(length(tipoVar)==length(headers))
        assert(not(buscarStrings),'Si ingresas el tipo de var, no puedes ademas definir algunas string')
        varsStr=strcmp(tipoVar,stringFormat);
    else
        
        
        tipoVar=cell(1,length(headers));
        varsStr=false(1,length(headers));
        
        for i=1:length(headers)
            
            if(buscarStrings&&ismember(headers{i},sonStringsVars))
                tipoVar{i}=stringFormat;
                varsStr(i)=true;
            else
                tipoVar{i}=numberFormat;
            end
            % If hay info en alguna variable en específico:
            if(conTipoVarEspecifico)
                for c=1:length(tipoVarEspecifico)
                    if(strcmp(headers{i},tipoVarEspecifico{c}{1}))
                        tipoVar{i}=tipoVarEspecifico{c}{2};
                    end
                end
            end
        end
    end
    
    fclose(fid);
    
    fid = fopen(archivo,'r','n','utf-8');
    
    preData = textscan(fid, sprintf('%s',tipoVar{:}),'delimiter',delimiter,'CollectOutput',1,'HeaderLines',1);
    
    fclose(fid);
    
    
    
    %% Dataset
    
    
    
    cantMatrices=length(preData);
    tipoMatrices=cell(cantMatrices,1);
    tipoMatricesPrint=cell(cantMatrices,1);
    largoAcumulado=0;
    numericMatrices=false(cantMatrices,1);
    for c=1:cantMatrices
        
        largo=size(preData{c},2);
        largoAcumulado=largo+largoAcumulado;
        tipoMatricesPrint{c}=tipoVar{largoAcumulado};
        tipoMatrices{c}=class(preData{c}(1));
        numericMatrices(c)=isnumeric(preData{c}(1));
    end
    
    
    
    [tipos,pos]=unique(tipoMatrices);
    tiposPrint=tipoMatricesPrint(pos);
    cantTipos=length(tipos);
    
    % If cantTipos>1, I have to distinguish which t
    
    if(dataInTable)
        preTables=cell(1,cantTipos);
        for t=1:cantTipos
            preHeaders=headers(strcmp(tipoVar,tiposPrint{t}))';
            prePreData=horzcat(preData{strcmp(tipoMatrices,tipos{t})});
            if(isnumeric(t))
                preTables{t}=array2table(prePreData,'VariableNames',preHeaders);
            else
                preTables{t}=cell2table(prePreData,'VariableNames',preHeaders);
            end
        end
        
        data=horzcat(preTables{:});
        
        
    else
        
        preDataset=cell(1,cantTipos);
        for t=1:cantTipos
            preHeaders=headers(strcmp(tipoVar,tiposPrint{t}))';
            prePreData=horzcat(preData{strcmp(tipoMatrices,tipos{t})});
            if(isnumeric(t))
                preDataset{t}=cell2dataset(num2cell(prePreData),'ReadVarNames',false,'varNames',preHeaders);
            else
                preDataset{t}=cell2dataset(prePreData,'ReadVarNames',false,'varNames',preHeaders);
            end
        end
        
        data=horzcat(preDataset{:});
        %
        %         switch cantTipos
        %             case 1
        %                 data=dataset([{[preData{1}]},headers']);
        %             case 2
        %                 data=dataset([{[preData{strcmp(tipoMatrices,tipos{1})}]},headers(strcmp(tipoVar,tiposPrint{1}))'],...
        %                     [{[preData{strcmp(tipoMatrices,tipos{2})}]},headers(strcmp(tipoVar,tiposPrint{2}))']);
        %
        %             case 3
        %                 data=dataset([{[preData{strcmp(tipoMatrices,tipos{1})}]},headers(strcmp(tipoVar,tiposPrint{1}))'],...
        %                     [{[preData{strcmp(tipoMatrices,tipos{2})}]},headers(strcmp(tipoVar,tiposPrint{2}))'],...
        %                     [{[preData{strcmp(tipoMatrices,tipos{3})}]},headers(strcmp(tipoVar,tiposPrint{3}))']);
        %
        %             otherwise
        %                 error('Implementar pa mas casos!')
        %
        %         end
        
    end
    
    
else
    
    error('\nNo se encontro el archivo:\n\n %s\n\nPor favor ingrese otro, gracias!',archivo)
    
end


