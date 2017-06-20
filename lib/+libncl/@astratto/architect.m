function varargout = architect(varargin)

% ---------------------------> ARCHITECT help <---------------------------------
% ARCHITECT - Create neural networks' architectures for neurocelle programs.
% 
% ARCHITECT arguments usage:
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
%
% Author: José Leonel L. Buzzo.
% Last Modified: 11/01/2016.
% ------------------------------------------------------------------------------


% --- Shuffling the random params, this MUST stay here!
rng('shuffle');


% Create based on the object struct information.
if nargin == 3 && isstruct(varargin{1}) && ~isempty(varargin{1}) && isnumeric(varargin{2}) && ~isempty(varargin{2})
    
    % --- Time.
    train_time = tic;
    time = 0;
    
    % Design setting.
    %dsgn = nnmask(designer2(obj),[],obj.vt_archs(1));
    
    % Fixing input type.
    varargin{2} = double(varargin{2});
    varargin{2}(2:varargin{2}(end)+1) = varargin{2}(2:varargin{2}(end)+1) + varargin{1}.num_neurons_layers(:,1)' - 1;
    
    % --- Creating the network.
    net = feedforwardnet(varargin{2}(2:varargin{2}(end)+1));
    
    % --- Setting training function and params.
    net.trainFcn = varargin{1}.trainFcn{varargin{2}(varargin{2}(end)+2)};
    net.trainParam.lr = varargin{1}.num_lr_vals(varargin{2}(end-1));    % Set the learning rate, for trainlm.
    net.trainParam.mc = varargin{1}.num_mc_vals(varargin{2}(end-2));    % Set the momentum rate.
    net.trainParam.showWindow = 0;                                      % Hide training window.
    
    % --- Setting layers' transfer functions.
    for i = 1:varargin{2}(end)+1
        net.layers{i}.transferFcn = varargin{1}.transferFcn_layers{varargin{2}(varargin{2}(end)+2+i)};
    end
    
    % --- Setting divide_crit.
    %if isempty(varargin{3}), varargin{3} = 1; end
    net = divide_critFcn(varargin{1},net,varargin{3});
    
    
    % --- Setting raffling_weights_crit.
    if strcmp(varargin{1}.raffling_weights_crit{varargin{2}(end-3)},'persistent_random')
        % Loading the random weights seed.
        k = load('rseed.mat');
        rng(k.rseed);
    elseif strcmp(varargin{1}.raffling_weights_crit{varargin{2}(end-3)},'force_value')
        net = nninit(net,varargin{1}.inputs,varargin{1}.targets);
    end
        
    % Saveing the random weights seed.
    rnd_seed = rng;
    
    
    % --- Training the network. A função rng parece ser a resposta.
    [net,tr] = train(net,varargin{1}.inputs,varargin{1}.targets);
    %net.userdata = tr;
    
    
    % --- Loading the architectures' structure fields.
    arch = varargin{1}.architecture;
    arch.id = uint32(varargin{2}(1));
    arch.design = uint32(varargin{2});
    
    % Reurn value;
    if varargin{3} == 1 %varargin{1}.num_inner_nets;
        % Recursive part.
        %arch.networks = net; % Function cat causes an error in posterior readings;
        arch.pattern_indexes = {uint16(tr.trainInd) uint16(tr.valInd) uint16(tr.testInd)};
        arch.weights_random_param = rnd_seed;
        arch.stats = nnstats(dataset,extra_arch_info(varargin{1},net,tr),[varargin{1}.code_name '-' num2str(arch.id)],varargin{3});
        arch.times = single(toc(train_time));
        
        varargout{:} = arch;
    else
        % Prevent from cumulative time.
        time = toc(train_time);
        arch2 = architect(varargin{1},varargin{2},varargin{3} - 1);
        
        % Recursive part.
        %arch.networks = cat(1,net,arch2.networks);
        arch.pattern_indexes = cat(1,arch2.pattern_indexes,{uint16(tr.trainInd) uint16(tr.valInd) uint16(tr.testInd)});
        arch.weights_random_param = cat(1,arch2.weights_random_param,rnd_seed);
        arch.stats = nnstats(arch2.stats,extra_arch_info(varargin{1},net,tr),[varargin{1}.code_name '-' num2str(arch.id)],varargin{3});
        arch.times = cat(1,arch2.times,single(time));
        
        varargout{:} = arch;
    end
    %if varargin{3} == 1, save('pongao.mat', 'net'); end
    
elseif nargin == 2 && iscell(varargin{1}) && ~isempty(varargin{1})
    % Return a cell oriented architecture.
else
    % Error return value.
    varargout{:} = -1;
end

% Restoring default random seed settings.
rng('default');
