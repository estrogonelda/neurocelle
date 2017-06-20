function setobj(obj,varargin)

%SETOBJ Summary of this function goes here
%   Detailed explanation goes here


    % --- Library import.
    import('libflmgr.*');
    import('libml.*');
    import('libncl.*');
    
    % Pick the state of the random seed generator.
    %prev_seed = rng;
    
    try
        if nargin == 1
            return;
        elseif nargin == 2
            % Iterate over model types.
            for ii = 1:numel(obj.parameters)
                % Identifying current specific model.
                screen(['Model type: ' obj.parameters(ii).general.model_type '.'],'','');
                
                % Reseting object.
                object = getObjStr;
                
                % Try to preprocess data.
                data = getDataStr;
                
                if ~isempty(obj.info.pre_processfcn)
                    try
                        % Principal Component Analysis (PCA).
                        [PC EV SCR EXP_VAR PVAL T2] = pca2(obj.data.inputs,'padronize','all');
                        
                        % Take only the relevant PCs.
                        k = min(find(cumsum(EXP_VAR) > 0.9));
                        if k <= 2, k = 2; end
                        
                        % Check normality assumption.
                        [H, b1, b2, mtx, idx, Huniv, Puniv] = mvnChk(SCR(:,1:k));
                        %[H, b1, b2, mtx, idx, Huniv, Puniv] = mvnChk(SCR(:,1:k));
                        
                        % Transform to new reduced scores.
                        data.inputs = mtx;
                        
                        % Transform to new reduced scores.
                        [data.targets, mn, sd] = pdr(obj.data.targets);
                        
                        % Retain PC coeficients and targets' mean and standard deviation.
                        obj.data.extra = {PC mn sd};
                        data.extra = obj.data.extra;
                        data.id = obj.data.id;
                    catch
                        data = obj.data;
                    end
                end
                
                try
                    switch obj.parameters(ii).general.model_type
                        case 'regression'
                            % Calling with struct argument.
                            %object = ra(obj.data);
                            
                            % Set model type.
                            object.type = 'regression';
                        case 'ann'
                            % Artificial Neural Networks
                            
                            % Calling with struct argument.
                            [object, stats] = ann(data,obj.parameters(ii));
                            stats = single(stats);
                            save(obj.info.objfile,'stats','data');
                        case 'svm'
                            2
                        case 'bayesian'
                            3
                        case 'markov_chain'
                            
                        case 'fuzzy'
                            % Calling with struct argument.
                            %object = FZZmkr(obj.data);
                            
                            object.type = 'fuzzy';
                        otherwise
                            % Custom model.
                    end
                    
                    % Data indentity initialization.
                    num = num2str(round(1e8*rand));
                    object.id = ['obj-' num(end:-1:end-5)];
                catch ERR
                    ERR.message
                end
                
                % Object's return.
                obj.objects(ii) = object;
            end
        else
            error('Invalid inputs.');
        end
    catch ERR
        % Restore random seed generator to it's original state.
        %rng(prev_seed);
        
        error(['@astratto.setobj: ',ERR.message]);
    end
    
    % Restore random seed generator to it's original state.
    %rng(prev_seed);
end
