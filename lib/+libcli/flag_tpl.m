function H = flag_tpl(obj,varargin)

% Description...

    % Setting return status.
    EXT = 0;
    
    % Initialy, 'H' is set to the exit status 'exit_stt', that is, by default
    % the success value '0', changing inside the function, if needed.
    H = cell(size(varargin))';
    for ii = 1:size(varargin,2)
        H{ii} = EXT;
        try
            % Feel the input.
            if ischar(varargin{ii})
                % Action here.
                %kill the process.
            else
                error('Invalid flag input.');
            end
            
            H{ii} = obj;
        catch ERR
            H{ii} = ~EXT;
            error(['flag_a: ',ERR.message]);
        end
    end
end
