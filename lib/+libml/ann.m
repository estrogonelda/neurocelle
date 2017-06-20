function [output, stats] = ann(varargin)

% ---------------------------> ANN help <--------------------------------------
% ANN - Create architectures for Artificial Neural Networks.
%
% ANN arguments usage:
%   
%   For nargin == 3.
%       varargin{1} = obj;
%       varargin{2} = design_vec;
%       varargin{3} = num_inner_nets;
%       
%   For nargin == 2.
%       varargin{1} = design_vec;
%       varargin{2} = num_inner_nets;
%       
%   varargout is an array type architecture with size num_inner_netsx1.
%
% Author: José Leonel L. Buzzo.
% Last Modified: 11/01/2016.
% -----------------------------------------------------------------------------


    % =======================> PREAMBLE <======================================
    
    % -----------------------> Macro Definitions ------------------------------
    % Success exit status.
    %EXT = 0;
    
    % -----------------------> Library import ---------------------------------
    import('libflmgr.*');
    import('libml.*');
    
    % -----------------------> Variable declarations --------------------------
    % Output.
    output = [];
    
    
    % =======================> FUNCTION CODE <=================================
    
    try
        % Adjusting input arguments.
        if nargin == 2
            data = varargin{1};
            params = varargin{2}.model_specific;
            algorithm = varargin{2}.design_specific;
            options = varargin{2}.general;
        elseif nargin == 4
            data = varargin{1};
            params = varargin{2};
            algorithm = varargin{3};
            options = varargin{4};
        else
            return;
        end
        
        
        % Architecture creation!
        [output, stats] = createArch(data,params,algorithm,options);
        
    catch ERR
        error(['+libml.ann: ',ERR.message]);
    end
end


function [obj, perf_mtx] = createArch(data,params,algorithm,options)

% Create the Artificial Neural Network from the input arguments.


    % Library import.
    import('libml.*');
    
    % Elapsed time.
    time = tic;
    tm = 0;
    
    % Pick the state of the random seed generator.
    prev_seed = rng;
    
    % Load a fixed random seed generator.
    k = load('rseed.mat');
    
    % Allocating memory.
    design = double(params.design_vct);
    design(~params.design_mask) = 1;
    design(1,:) = params.design_vct(1,:);
    arch = design(:,1);
    unit = design(:,2);
    
    % Use specific 'divide_crit'.
    idx = sampler(size(data.inputs,1),[.6 .2 .2],params.num_units_replicates);
    idx_rnd = idx;
    save indexes.mat idx;
    
    % Performance matrix.
    num = min(options.num_iterations,params.num_design_archs);
    perf_mtx = zeros(params.num_units_replicates,3*params.num_archs_units,num);
    best_perf = zeros(1,3);
    
    % Get object structure.
    obj = getObjStr;
    
    
    try
        % Start counting.
        counter = 1;
        
        for ii = params.design_archs(1:num)
            iii = find(params.design_archs == ii);
            
            % === Deterministic params ===
            arch(2:end) = masker(design(2:end,1),ii);
            
            % --- Creating the network.
            net = feedforwardnet((params.num_neurons_layers(:,1) + arch(2:arch(1)+1) - 1)');
            net = configure(net,data.inputs',data.targets');
            %net = net_tmp;
            
            % --- Setting training function and params.
            net.trainFcn = params.trainFcn{arch(arch(1)+2)};
            net.trainParam.showWindow = 0;                          % Hide training window.
            
            % --- Setting layers' transfer functions.
            for jj = 1:arch(1)+1
                net.layers{jj}.transferFcn = params.transferFcn_layers{arch(arch(1)+2+jj)};
            end
            
            % --- Setting 'extra_deterministic_param'.
            % ----------------------------------------
            
            for jj = 1:params.num_archs_units
                
                % === Stochastic params ===
                unit(2:end) = masker(design(2:end,2),jj);
                
                % --- Setting divide_crit.
                net.divideFcn = 'divideind';
                
                % --- Old style.
                %if ischar(params.divide_crit), params.divide_crit = {params.divide_crit}; end
                %if strcmp(params.divide_crit{unit(2)},'persistent_random')
                %    net_tmp.divideFcn = 'divideind';
                %else
                %    net_tmp.divideFcn = 'dividerand';
                %    net_tmp.divideParam.trainRatio = .6;
                %    net_tmp.divideParam.valRatio = .2;
                %    net_tmp.divideParam.testRatio = .2;
                %end
                
                
                % --- Setting raffling_weights_crit.
                %if ischar(params.raffling_weights_crit), params.raffling_weights_crit = {params.raffling_weights_crit}; end
                %if strcmp(params.raffling_weights_crit{unit(3)},'persistent_random')
                %    % Load a fixed random weights seed.
                %    k = load('rseed.mat');
                %end
                
                % --- Setting raffling_bias_crit.
                %if ischar(params.raffling_bias_crit), params.raffling_bias_crit = {params.raffling_bias_crit}; end
                %if strcmp(params.raffling_bias_crit{unit(4)},'persistent_random')
                %    % Load a fixed random weights seed.
                %    k = load('rseed.mat');
                %end
                
                % --- Setting other params.
                net.trainParam.mc = params.num_mc_vals(unit(5));      % Set the momentum constant.
                net.trainParam.lr = params.num_lr_vals(unit(6));      % Set the learning rate, for trainlm.
                
                % Preserve net's configurations.
                net_tmp = net;
                
                % --- Setting 'extra_stochastic_param'.
                % -------------------------------------
                for kk = 1:params.num_units_replicates
                    % --- Set random seed first.
                    if strcmp(params.raffling_weights_crit{unit(3)},'persistent_random')
                        rng(k.rseed);
                    else
                        rng('shuffle');
                    end
                    
                    % --- So reinitialize network's weights.
                    net_tmp = init(net);
                    
                    % --- Set training indexes after 'init' function to avoid reset indexes.
                    if strcmp(params.divide_crit{unit(2)},'persistent_random')
                        net_tmp.divideParam.trainInd = idx{1}(kk,:);
                        net_tmp.divideParam.valInd = idx{2}(kk,:);
                        net_tmp.divideParam.testInd = idx{3}(kk,:);
                    else
                        % Shuffle every time.
                        idx_rnd = sampler(size(data.inputs,1),[.6 .2 .2],params.num_units_replicates);
                        net_tmp.divideParam.trainInd = idx_rnd{1}(kk,:);
                        net_tmp.divideParam.valInd = idx_rnd{2}(kk,:);
                        net_tmp.divideParam.testInd = idx_rnd{3}(kk,:);
                    end
                    
                    % Debug code:
                    %net_tmp.LW{3,2}(:,1:4)
                    %net_tmp.divideParam.testInd
                    
                    % =====> Training the network <=====
                    % Remember to transpose data!
                    if strcmp(params.ann_type,'supervised')
                        % Supervised training.
                        [net_tmp, tr, data.outputs] = train(net_tmp,data.inputs',data.targets');
                        
                        % Reshape data.
                        data.outputs = data.outputs';
                        %data.errors = data.errors';
                    else
                        % Unsupervised training.
                        %[net_tmp, tr, data.outputs, data.errors] = train(net_tmp,data.inputs',data.targets');
                    end
                    
                    % Debug code:
                    %tr.testInd(1:4)
                    %net_tmp.LW{3,2}(:,1:4)
                    
                    % --- Performance measure using 'performance_crit' function:
                    perf = analyser(data.targets,data.outputs,idx,kk);
                    perf_mtx(kk,3*(jj-1)+1:3*(jj-1)+3,iii) = perf;
                    
                    
                    % --- Select object by a criterium.
                    crit = perf >= best_perf;
                    if all([iii jj kk] == [1 1 1]) ...
                            || (~all(crit) && sum(crit) >= 2 && (best_perf(~crit) - perf(~crit) <= 0.08)) ...
                            || all(crit)
                        fprintf('Subs!!\n');
                        best_perf = perf;
                        
                        obj.type = 'ann';
                        obj.sub_type = params.ann_type;
                        obj.application = data.id;
                        obj.topology = net_tmp;
                        obj.params = rng;
                        obj.records = tr;
                        obj.records.lambda = perf;
                    end
                    
                    % --- Print to screen.
                    str = ['Problem: ' data.id ', num: ' num2str(counter) ', [ii jj kk]: ' num2str([ii jj kk]) ', perf: ' num2str(perf) ', time: ' num2str(toc(time)-tm)];
                    fprintf('%s.\n',str);
                    
                    % --- Transcurred time.
                    tm = toc(time);
                    
                    % --- Update counter.
                    counter = counter + 1;
                end
            end
            
            % Limit number of iterations.
            if iii >= options.num_iterations, rng(prev_seed); return; end
        end
    catch ERR
        %[iii jj kk]
        ERR.message
    end
    
    
    % Restore random seed generator to it's original state.
    rng(prev_seed);
end

function prf = analyser(targets,outputs,idx,k)

% efcve


    % Analyse ANN.
    import('libml.*');
    
    prf = zeros(1,3);
    
    % --- Paired Hotelling's test.
    % Train.
    [~, ~, prf(1)] = feval('hotelling',...
        targets(idx{1}(k,:),:),outputs(idx{1}(k,:),:),[],'paired',[]);
    % Validation.
    [~, ~, prf(2)] = feval('hotelling',...
        targets(idx{2}(k,:),:),outputs(idx{2}(k,:),:),[],'paired',[]);
    % Test.
    [~, ~, prf(3)] = feval('hotelling',...
        targets(idx{3}(k,:),:),outputs(idx{3}(k,:),:),[],'paired',[]);
end
