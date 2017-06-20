function output = getArgumentsGuideStruct(varargin)

% sedfwrev


    % Declaring inner structs.
    vals = struct(...
        'number',0,...
        'required',0,...
        'positions',[],...
        'conditions',[],...
        'templates',[]);
    
    % Input arguments guide struct.
    output = struct(...
        'logical',vals,...
        'char',vals,...
        'uint8',vals,...
        'single',vals,...
        'double',vals,...
        'cell',vals,...
        'struct',vals,...
        'dataset',vals,...
        'object',vals);
    
    % Expand to return output arguments guide struct too.
    output(2) = output;
    
    % Set empty conditions to all types.
    fds = fields(output);
    for ii = 1:numel(fds)
        output(1).(fds{ii}).conditions = {'[]'};
        output(2).(fds{ii}).conditions = {'[]'};
        output(1).(fds{ii}).templates = {[]};
        output(2).(fds{ii}).templates = {[]};
    end
end
