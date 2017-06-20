function result = general_loader(value,true_list,aux_value,type,extra)

% ---------------------------> GENERAL_LOADER help <----------------------------
% GENERAL_LOADER oiuihouih
%
% Input arguments:
%   value: Objects' value.5
%   true_list: List of currect and possible values.
%   aux_value: Auxiliary value to match another variable.
%   type: Type of output data.
%   extra: Extra param. Limits the number os outputs for'char' inputs and
%       provide an extra argument for 'numeric' inputs.
% ------------------------------------------------------------------------------


if strcmp(type,'char')
    % --- Consistence verification for the input values.
    if any([isempty(value) ~ischar(value) any(aux_value)])
        value = true_list{1};
    else
        value = regexp(value,'(,\s*)','split');
    end
    
    vec = cell(1,size(value,2));
    for i = 1:size(vec,2)
        if any(strcmp(true_list, value(i)))
            vec{i} = true_list{strcmp(true_list, value(i))};
        else
            vec{i} = '';
        end
    end
    value = vec(~strcmp(vec,''));
    
    if isempty(value)
        % A default value.
        value = true_list{1};
    elseif size(value,2) == 1 || (~isempty(extra) && size(value,2) > extra)
        % Must return a string for a single return value or return the
        % first valid value like that.
        value = value{1};
    end
    
    result = value;
    return;
    
elseif strcmp(type,'numeric')
    
    % --- Consistence verification for the input values.
    if any([isempty(str2num(value)) any(str2num(value) < true_list(1) | str2num(value) > true_list(2)) any(aux_value)])
        % The default values accordingly to the extra param.
        switch extra{1}
            case 'model_type'
                % Form num_hidden_layers.
                value = 2;
            case 'num_hidden_layers'
                % Form num_hidden_layers.
                value = 2;
            case 'num_neurons_layers' % extra is the num_hidden_layers to calculate the layers' sizes.
                % For num_neurons_layers, a N-2 matrix.
                value = ones(extra{2},2);
                value(:,2) = 10;
            case 'num_mc_vals'
                % Form num_hidden_layers.
                value = 0.5;
            case 'num_lr_vals'
                % Form num_hidden_layers.
                value = 0.001;
            case 'num_inner_nets'
                % Form num_hidden_layers.
                value = 3;
            %case 'num_iteractions'
                % Form num_hidden_layers.
            %    value = 3;
            otherwise
                value = [];
        end
    else
        value = str2num(value);
    end
    
    result = value;
    return;
end

result = -1;
end
