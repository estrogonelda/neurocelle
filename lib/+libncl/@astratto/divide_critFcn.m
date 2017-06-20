function net = divide_critFcn(obj,net,idx)

% -----------------------------> DIVIDE_CRIT_FCN help <-------------------------
%
%
% ------------------------------------------------------------------------------


% --- Choosing divide_crit.
switch obj.divide_crit
    case 'random'
        
        obj_aux = obj;
        obj_aux.divide_crit = 'persistent_random';
        obj_aux.force_iterations = 'y';
        %num = obj_aux.num_inner_nets + 1;
        
        net = divide_critFcn(obj_aux,net,-1);
        
    case 'persistent_random'
        
        % Loading indexes.
        load(['saves/' obj.name '_divideIdx.mat']);
        
        if ~isempty(indexes) && idx <= size(indexes,1) && ~strcmp(obj.force_iterations,'y')
            
            % Using the loaded 'divideind'.
            net.divideFcn = 'divideind';
            net.divideParam.trainInd = indexes{idx,1};
            net.divideParam.valInd   = indexes{idx,2};
            net.divideParam.testInd  = indexes{idx,3};
        elseif strcmp(obj.force_iterations,'y') || idx > size(indexes,1)
            
            %disp('aumentando indexes!')
            % 'divideind' in the first time.
            net.divideFcn = 'divideind';
            
            x = 1:size(obj.targets,2);
            net.divideParam.testInd = ones(1,round(0.2*size(obj.targets,2)));
            net.divideParam.valInd = ones(1,round(0.2*size(obj.targets,2)));
            net.divideParam.trainInd = ones(1,size(x,2) - size(net.divideParam.valInd,2) - size(net.divideParam.testInd, 2));
            
            % valInd.
            cont = 1;
            while cont <= size(net.divideParam.valInd,2)
                val = round(1 + (size(x,2) - 1)*rand);
                
                if any(net.divideParam.valInd == val)
                    continue;
                else
                    net.divideParam.valInd(cont) = val;
                end
                
                cont = cont + 1;
            end
            k1 = ones(1,size(obj.targets,2));
            k1(net.divideParam.valInd) = 0;
            aux = x(k1 ~= 0);
            
            % testInd.
            cont = 1;
            while cont <= size(net.divideParam.testInd,2)
                val = round(1 + (size(aux,2) - 1)*rand);
                
                if any(net.divideParam.testInd == aux(val))
                    continue;
                else
                    net.divideParam.testInd(cont) = aux(val);
                end
                
                cont = cont + 1;
            end
            k2 = ones(1,size(obj.targets,2));
            k2(net.divideParam.testInd) = 0;
            k2 = x((k2 ~= 0) & (k1 ~= 0));
            
            % trainInd.
            net.divideParam.trainInd = k2;
            
            % Saving indexes. Only for 'persistent_random' divide_crit.
            if idx > 0
                % Preparing for save.
                if strcmp(obj.force_iterations,'y')
                    indexes = cat(1,{net.divideParam.trainInd net.divideParam.valInd ...
                        net.divideParam.testInd},indexes);
                else
                    % Just amplifying indexes with new values.
                    indexes = cat(1,indexes,{net.divideParam.trainInd net.divideParam.valInd ...
                        net.divideParam.testInd});
                end
                
                
                save(['saves/' obj.name '_divideIdx.mat'],'indexes');
            end
        end
        
    otherwise
        disp('ERRO!!');
end

net = net;
