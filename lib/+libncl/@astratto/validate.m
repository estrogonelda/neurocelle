function validate(obj)

% VALIDATE Summary of this function goes here
%   Detailed explanation goes here


    % --- Library import.
    import('libbase.*');
    import('libflmgr.*');
    import('libncl.*');
    
    % Validating fields, sequentially.
    fds = properties(obj);
    for ii = 1:size(fds,1)
        try
            switch fds{ii}
                case 'info'
                    % Must check for the existence of the file paths.
                    dftname = 'Problem1';
                    obj.(fds{ii}).problem = obj.supervisor(obj.(fds{ii}).problem,...
                        dftname,ischar(obj.(fds{ii}).problem),'string',{'uniq' 'custom'});
                    if ~strcmp(dftname,'Problem1'), dftname = obj.(fds{ii}).problem; end
                    
                    obj.(fds{ii}).configfile = obj.supervisor(obj.(fds{ii}).configfile,...
                        [dftname '.cfg'],ischar(obj.(fds{ii}).configfile),'string',{'uniq' 'custom'});
                    
                    obj.(fds{ii}).datafile = obj.supervisor(obj.(fds{ii}).datafile,...
                        [dftname '.mat'],ischar(obj.(fds{ii}).datafile),'string',{'uniq' 'custom'});
                    
                    obj.(fds{ii}).objfile = obj.supervisor(obj.(fds{ii}).objfile,...
                        ['obj_' dftname '.mat'],ischar(obj.(fds{ii}).objfile),'string',{'uniq' 'custom'});
                    
                    %obj.(fds{ii}).pre_processfcn = obj.supervisor(obj.(fds{ii}).pre_processfcn,...
                    %    '',ischar(obj.(fds{ii}).pre_processfcn) && exist(obj.(fds{ii}).pre_processfcn,'file'),'string',{'uniq' 'custom'});
                    
                    obj.(fds{ii}).processfcn = obj.supervisor(obj.(fds{ii}).processfcn,...
                        '',ischar(obj.(fds{ii}).processfcn) && exist(obj.(fds{ii}).processfcn,'file'),'string',{'uniq' 'custom'});
                    
                    obj.(fds{ii}).post_processfcn = obj.supervisor(obj.(fds{ii}).post_processfcn,...
                        '',ischar(obj.(fds{ii}).post_processfcn) && exist(obj.(fds{ii}).post_processfcn,'file'),'string',{'uniq' 'custom'});
                case 'data'
                    if exist(obj.info.datafile,'file')
                        vars = load(obj.info.datafile);
                        fds2 = fields(vars);
                        cl = cell(size(fds2));
                        for jj = 1:size(cl,1)
                            cl{jj} = vars.(fds2{jj});
                        end
                        
                        obj.setdata(cl{:});
                    end
                case 'statistics'
                    
                case 'parameters'
                    for jj = 1:size(obj.(fds{ii}),2)
                        % --- General params.
                        obj.(fds{ii})(jj).general.model_type = obj.supervisor(obj.(fds{ii})(jj).general.model_type,...
                            obj.defaults.parameters.general.model_type,1,'string','');
                        
                        obj.(fds{ii})(jj).general.model_sub_type = obj.supervisor(obj.(fds{ii})(jj).general.model_sub_type,...
                            obj.defaults.parameters.general.model_sub_type,1,'string','custom');
                        
                        obj.(fds{ii})(jj).general.model_fcn = obj.supervisor(obj.(fds{ii})(jj).general.model_fcn,...
                            obj.defaults.parameters.general.model_fcn,1,'string','');
                        
                        obj.(fds{ii})(jj).general.design_type = obj.supervisor(obj.(fds{ii})(jj).general.design_type,...
                            obj.defaults.parameters.general.design_type,1,'string','');
                        
                        obj.(fds{ii})(jj).general.design_fcn = obj.supervisor(obj.(fds{ii})(jj).general.design_fcn,...
                            obj.defaults.parameters.general.design_fcn,1,'string','');
                        
                        obj.(fds{ii})(jj).general.performance_crit = obj.supervisor(obj.(fds{ii})(jj).general.performance_crit,...
                            obj.defaults.parameters.general.performance_crit,1,'string',{'custom' 'uniq'});
                        
                        obj.(fds{ii})(jj).general.ordenation_crit = obj.supervisor(obj.(fds{ii})(jj).general.ordenation_crit,...
                            obj.defaults.parameters.general.ordenation_crit,1,'string',{'custom' 'uniq'});
                        
                        obj.(fds{ii})(jj).general.selection_crit = obj.supervisor(obj.(fds{ii})(jj).general.selection_crit,...
                            obj.defaults.parameters.general.selection_crit,1,'string',{'custom' 'uniq'});
                        
                        obj.(fds{ii})(jj).general.force_iterations = obj.supervisor(obj.(fds{ii})(jj).general.force_iterations,...
                            obj.defaults.parameters.general.force_iterations,1,'string',{'uniq'});
                        
                        input = obj.(fds{ii})(jj).general.num_iterations;
                        str = '(ischar(x) && ~isempty(str2num(x)) && sum(size(str2num(x))) == 2 && ~mod(str2num(x),1)) || (isnumeric(x) && ~isempty(x) && sum(size(x)) == 2 && ~mod(x,1))';
                        obj.(fds{ii})(jj).general.num_iterations = obj.supervisor(input,...
                            obj.defaults.parameters.general.num_iterations,obj.condition(str,input),'',{'uniq' 'range'});
                        
                        input = obj.(fds{ii})(jj).general.num_saves;
                        str = '(ischar(x) && ~isempty(str2num(x)) && sum(size(str2num(x))) == 2 && ~mod(str2num(x),1)) || (isnumeric(x) && ~isempty(x) && sum(size(x)) == 2 && ~mod(x,1))';
                        obj.(fds{ii})(jj).general.num_saves = obj.supervisor(input,...
                            obj.defaults.parameters.general.num_saves,obj.condition(str,input),'',{'uniq' 'range'});
                        
                        
                        % --- Model specific params (Artificial Neural Networks).
                        switch obj.(fds{ii})(jj).general.model_type
                            case 'regression'
                                
                            case 'ann'
                                obj.(fds{ii})(jj).model_specific.ann_type = obj.supervisor(obj.(fds{ii})(jj).model_specific.ann_type,...
                                    obj.defaults.parameters.model_specific.ann_type,1,'string','uniq');
                                
                                % Deterministic params.
                                input = obj.(fds{ii})(jj).model_specific.num_hidden_layers;
                                str = '(ischar(x) && ~isempty(str2num(x)) && sum(size(str2num(x))) == 2 && ~mod(str2num(x),1)) || (isnumeric(x) && ~isempty(x) && sum(size(x)) == 2 && ~mod(x,1))';
                                obj.(fds{ii})(jj).model_specific.num_hidden_layers = obj.supervisor(input,...
                                    obj.defaults.parameters.model_specific.num_hidden_layers,obj.condition(str,input),'',{'uniq' 'range'});
                                
                                input = obj.(fds{ii})(jj).model_specific.num_neurons_layers;
                                str = ['(ischar(x) && ~isempty(str2num(x)) ' ...
                                    '&& size(str2num(x),1) == ' num2str(obj.(fds{ii})(jj).model_specific.num_hidden_layers) ...
                                    '&& size(str2num(x),2) == 2 && all(all(~mod(str2num(x),1))) )'...
                                    '|| (isnumeric(x) && size(x,1) == ' num2str(obj.(fds{ii})(jj).model_specific.num_hidden_layers) ...
                                    '&& size(x,2) == 2 && all(all(~mod(x,1)))) && all(x(:,1) > x(:,2))'];
                                dft = str2num(obj.defaults.parameters.model_specific.num_neurons_layers);
                                dft = repmat(dft,obj.(fds{ii})(jj).model_specific.num_hidden_layers,1);
                                % Using matricial switch in modulo.supervisor method.
                                obj.(fds{ii})(jj).model_specific.num_neurons_layers = ...
                                    sort(obj.supervisor(input,dft,obj.condition(str,input),'','range','mtx'),2);
                                
                                obj.(fds{ii})(jj).model_specific.trainFcn = obj.supervisor(obj.(fds{ii})(jj).model_specific.trainFcn,...
                                    obj.defaults.parameters.model_specific.trainFcn,1,'string','');
                                
                                obj.(fds{ii})(jj).model_specific.transferFcn_layers = obj.supervisor(obj.(fds{ii})(jj).model_specific.transferFcn_layers,...
                                    obj.defaults.parameters.model_specific.transferFcn_layers,1,'string','');
                                
                                obj.(fds{ii})(jj).model_specific.extra_deterministic_param = obj.supervisor(obj.(fds{ii})(jj).model_specific.extra_deterministic_param,...
                                    obj.defaults.parameters.model_specific.extra_deterministic_param,1,'string','');
                                
                                % Stochastic params.
                                obj.(fds{ii})(jj).model_specific.divide_crit = obj.supervisor(obj.(fds{ii})(jj).model_specific.divide_crit,...
                                    obj.defaults.parameters.model_specific.divide_crit,1,'string','');
                                
                                obj.(fds{ii})(jj).model_specific.raffling_weights_crit = obj.supervisor(obj.(fds{ii})(jj).model_specific.raffling_weights_crit,...
                                    obj.defaults.parameters.model_specific.raffling_weights_crit,1,'string','');
                                
                                obj.(fds{ii})(jj).model_specific.raffling_bias_crit = obj.supervisor(obj.(fds{ii})(jj).model_specific.raffling_bias_crit,...
                                    obj.defaults.parameters.model_specific.raffling_bias_crit,1,'string','');
                                
                                obj.(fds{ii})(jj).model_specific.num_mc_vals = obj.supervisor(obj.(fds{ii})(jj).model_specific.num_mc_vals,...
                                    obj.defaults.parameters.model_specific.num_mc_vals,1,'','range');
                                
                                obj.(fds{ii})(jj).model_specific.num_lr_vals = obj.supervisor(obj.(fds{ii})(jj).model_specific.num_lr_vals,...
                                    obj.defaults.parameters.model_specific.num_lr_vals,1,'','range');
                                
                                obj.(fds{ii})(jj).model_specific.extra_stochastic_param = obj.supervisor(obj.(fds{ii})(jj).model_specific.extra_stochastic_param,...
                                    obj.defaults.parameters.model_specific.extra_stochastic_param,1,'string','');
                                
                                % Design params.
                                % Calculating 'design_vct'.
                                % Calculating number of deterministic params.
                                nl = obj.(fds{ii})(jj).model_specific.num_hidden_layers;
                                vct = ones(2*nl+4,2,'uint32');
                                vct(1,:) = nl;
                                for kk = 1:nl
                                    vct(kk+1,1) = obj.(fds{ii})(jj).model_specific.num_neurons_layers(kk,2) - obj.(fds{ii})(jj).model_specific.num_neurons_layers(kk,1) + 1;
                                    vct(kk+1+nl+1,1) = numel2(obj.(fds{ii})(jj).model_specific.transferFcn_layers);
                                end
                                vct(nl+2,1) = numel2(obj.(fds{ii})(jj).model_specific.trainFcn);
                                vct(2*nl+3,1) = numel2(obj.(fds{ii})(jj).model_specific.transferFcn_layers);
                                vct(2*nl+4,1) = numel2(obj.(fds{ii})(jj).model_specific.extra_deterministic_param);
                                
                                % Calculating number of Stochastic params.
                                vct(2,2) = numel2(obj.(fds{ii})(jj).model_specific.divide_crit);
                                vct(3,2) = numel2(obj.(fds{ii})(jj).model_specific.raffling_weights_crit);
                                vct(4,2) = numel2(obj.(fds{ii})(jj).model_specific.raffling_bias_crit);
                                vct(5,2) = numel2(obj.(fds{ii})(jj).model_specific.num_mc_vals);
                                vct(6,2) = numel2(obj.(fds{ii})(jj).model_specific.num_lr_vals);
                                if nl > 1
                                    vct(7,2) = numel2(obj.(fds{ii})(jj).model_specific.extra_stochastic_param);
                                end
                                obj.(fds{ii})(jj).model_specific.design_vct = vct;
                                
                                % Calculating 'design_mask'.
                                input = obj.(fds{ii})(jj).model_specific.design_mask;
                                str = ['ischar(x) && ~isempty(str2num(x)) && size(str2num(x),1) == ' num2str(size(vct,1)) ' && size(str2num(x),2) == 2'];
                                dft = true(size(vct));
                                dft(1,:) = false;
                                obj.(fds{ii})(jj).model_specific.design_mask = logical(obj.supervisor(input,dft,obj.condition(str,input),'','custom'));
                                
                                % >>> Heavy computation here! <<<
                                % Other calculations for 'design_vct' from 'design_type'.
                                vct(~obj.(fds{ii})(jj).model_specific.design_mask(:,1),1) = 1;
                                dsgn = obj.designer(vct(:,1),obj.(fds{ii})(jj).general.design_type,jj);
                                
                                input = obj.(fds{ii})(jj).model_specific.design_archs;
                                if ischar(input) && isempty(str2num(input))
                                    obj.(fds{ii})(jj).model_specific.design_archs = dsgn;
                                elseif ischar(input)
                                    % User defined design. ERRO!!
                                    obj.(fds{ii})(jj).model_specific.design_archs = cell(numel2(obj.algorithms),1);
                                    for kk = 1:numel2(obj.(fds{ii})(jj).model_specific.design_archs)
                                        obj.(fds{ii})(jj).model_specific.design_archs{kk} = str2num(input);
                                    end
                                end
                                
                                % Calculating 'num_design_archs', 'num_archs_units' 'num_units_replicates' and 'num_total'.
                                obj.(fds{ii})(jj).model_specific.num_design_archs = prod(vct(obj.(fds{ii})(jj).model_specific.design_mask(:,1),1));
                                
                                obj.(fds{ii})(jj).model_specific.num_archs_units = prod(vct(obj.(fds{ii})(jj).model_specific.design_mask(:,2),2));
                                
                                input = obj.(fds{ii})(jj).model_specific.num_units_replicates;
                                str = '(ischar(x) && ~isempty(str2num(x)) && sum(size(str2num(x))) == 2 && ~mod(str2num(x),1)) || (isnumeric(x) && ~isempty(x) && sum(size(x)) == 2 && ~mod(x,1))';
                                obj.(fds{ii})(jj).model_specific.num_units_replicates = obj.supervisor(input,...
                                    obj.defaults.parameters.model_specific.num_units_replicates,obj.condition(str,input),'',{'uniq' 'range'});
                                
                                obj.(fds{ii})(jj).model_specific.num_total = obj.(fds{ii})(jj).model_specific.num_design_archs*obj.(fds{ii})(jj).model_specific.num_archs_units*obj.(fds{ii})(jj).model_specific.num_units_replicates;
                            case 'fuzzy'
                                
                            otherwise
                        end
                        % --- Design specific params (Genetic Algorithms).
                        % ------------------------------------------------
                    end
                case 'objects'
                    obj.setobj;
                otherwise
            end
        catch ERR
            ii
            ERR.message
            %error(['@astratto.validate: ',ERR.message]);
        end
    end
end
