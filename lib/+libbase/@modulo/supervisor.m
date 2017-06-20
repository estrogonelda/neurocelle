function output = supervisor(value,truth_list,condition,val_type,ret_param,varargin)

% ---------------------------> +LIBBASE.@MODULE.SUPERVISOR help <--------------
% +LIBBASE.@MODULE.SUPERVISOR - oiuihouih
%
% Input arguments:
%   value: Actual values.
%   truth_list: List of currect and possible and correct values.
%   condition: Auxiliary condition of values to match on another variables.
%   val_type: Type of input data.
%   ret_param: Limits the number os outputs for 'char' inputs and
%       provide an extra argument for 'numeric' inputs.
% -----------------------------------------------------------------------------


    try
        % No change in values by a vague ('-') list.
        if strcmp(truth_list,'-')
            output = value;
            return;
        end
        
        % Default value for 'val_type'. Invalid values must cause an error.
        if isempty(val_type)
            val_type = 'numeric';
        end
        
        % Default value for 'ret_param'.
        ctrl = true;
        if ischar(ret_param), ret_param = {ret_param}; end
        for ii = 1:size(ret_param,2)
            if any(strcmp(ret_param{ii},{'sample' 'custom' 'range'}))
                ctrl = ~ctrl;
                break;
            end
        end
        if ctrl, ret_param = cat(2,ret_param,{'sample'}); end
        
        switch val_type
            case 'string' %{'char' 'd' 9}
                % --- Consistence verification for 'truth_list' values.
                if ~any(strcmp(class(truth_list),{'char' 'cell'}))
                    error('Invalid ''truth_list'' type.');
                elseif isempty(truth_list) && ~any(strcmp(ret_param,'custom'))
                    output = '';
                    return;
                elseif ischar(truth_list)
                    truth_list = {truth_list};
                end
                
                % --- Consistence verification for 'value' values.
                if any([isempty(value) ~any(strcmp(class(value),{'char' 'cell'})) ~logical(condition)])
                    % Default returns for unconsistent input values.
                    if isempty(truth_list)
                        output = '';
                    else
                        output = truth_list{1};
                    end
                    return;
                elseif ischar(value)
                    % Spliting a raw character string.
                    value = regexp(value,'(,\s*)','split');
                end
                
                % Here 'value' must be a cell.
                vec = cell(1,size(value,2));
                for ii = 1:size(vec,2)
                    if any(strcmp(truth_list,value{ii}))
                        vec{ii} = truth_list{strcmp(truth_list,value{ii})};
                    elseif any(strcmp(ret_param,'custom'))
                        vec{ii} = value{ii};
                    else
                        vec{ii} = '';
                    end
                end
                value = vec(~strcmp(vec,''));
                
                % Decide when it must return a string for a single return value.
                if isempty(value)
                    % A default value.
                    value = truth_list{1};
                elseif size(value,2) == 1 || any(strcmp(ret_param,'uniq'))
                    value = value{1};
                end
                
                output = value;
            case 'numeric'
                % --- Consistence verification for 'truth_list' values.
                if ~any(strcmp(class(truth_list),{'char' 'single' 'double' 'logical' 'uint8' 'uint32'}))
                    error('Invalid ''truth_list'' type.');
                elseif ((ischar(truth_list) && isempty(str2num(truth_list))) ...
                        || isempty(truth_list)) && ~any(strcmp(ret_param,'custom'))
                    output = [];
                    return;
                elseif ischar(truth_list) && isempty(str2num(truth_list))
                    truth_list = [];
                elseif ischar(truth_list)
                    truth_list = str2num(truth_list);
                end
                
                
                % --- Consistence verification for 'value' values.
                if any([isempty(value) ...
                        ~any(strcmp(class(value),{'char', 'single' 'double' 'logical' 'uint8'})) ...
                        ~logical(condition)])
                    % Default returns for unconsistent input values.
                    if isempty(truth_list)
                        output = [];
                    else
                        if size(truth_list,1) == 1 && (any(strcmp(ret_param,'sample')) || any(strcmp(ret_param,'uniq')))
                            output = truth_list(1);
                        else
                            % Alteration here.
                            output = truth_list;
                        end
                    end
                    return;
                elseif ischar(value)
                    value = str2num(value);
                end
                
                % Range and sample values validation.
                vec = false(size(value));
                if any(strcmp(ret_param,'custom'))
                    if ~isempty(value)
                        vec(:) = true;
                    end
                elseif any(strcmp(ret_param,'sample'))
                    if size(value,1) == 1 && size(truth_list,1) == 1
                        for ii = 1:size(value,2);
                            vec(ii) = any(value(ii) == truth_list(:));
                        end
                    elseif size(value,1) > 1 && (size(value,1) == size(truth_list,1))
                        % All or nothing.
                        ctrl = true;
                        for ii = 1:size(value,2)
                            for jj = 1:size(value,1)
                                if ~any(value(jj,ii) == truth_list(jj,:))
                                    ctrl = ~ctrl;
                                    break;
                                end
                            end
                            
                            if ~ctrl, break; end
                        end
                        if ctrl, vec(:) = true; end
                    else
                        vec = [];
                    end
                elseif any(strcmp(ret_param,'range'))
                    % Matricial control switch.
                    ctrl = true;
                    if any(strcmp(varargin,'mtx')), ctrl = ~ctrl; end
                    
                    if ctrl && (size(value,1) == 1 && size(truth_list,1) == 1)
                        % Simple array selection.
                        vec(value(:) >= min(truth_list) & value(:) <= max(truth_list)) = true;
                    elseif ~ctrl && (size(value,1) == size(truth_list,1))
                        % Matricial approach.
                        ctrl = true;
                        for ii = 1:size(value,2)
                            if ~all(value(:,ii) >= min(truth_list,[],2) & value(:,ii) <= max(truth_list,[],2))
                                ctrl = ~ctrl;
                                break;
                            end
                        end
                        if ctrl, vec(:) = true; end
                    end
                end
                
                if all(~vec(:))
                    value = [];
                elseif size(value,1) > 1
                    value(:) = value(vec(:));
                else
                    value = value(vec);
                end
                
                
                % Decide to return a single value.
                if isempty(value)
                    % A default value.
                    if isempty(truth_list)
                        value = [];
                    elseif size(truth_list,1) == 1 && any(strcmp(ret_param,'uniq'))
                        value = truth_list(1);
                    elseif any(strcmp(ret_param,'uniq'))
                        value = truth_list(:,1);
                    else
                        value = truth_list;
                    end
                elseif any(strcmp(ret_param,'uniq'))
                    if size(value,1) == 1
                        value = value(1);
                    else
                        value = value(:,1);
                    end
                end
                
                output = value;
            case {'struct' 'object'}
                output = struct;
            otherwise
                error('Invalid ''val_type''. [''string''|''NUMERIC'']');
        end
    catch ERR
        error(['+libbase.@modulo.supervisor: ',ERR.message]);
    end
end
