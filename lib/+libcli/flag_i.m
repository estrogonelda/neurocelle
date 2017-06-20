function H = flag_i(obj,varargin)

% Make rustic interface.


    % Setting return status.
    EXT = 0;
    
    varargin{:}
    % Initialy, 'H' is set to the exit status 'exit_stt', that is, by default
    % the success value '0', changing inside the function, if needed.
    H = cell(nargin-1,1);
    for ii = 1:nargin-1
        H{ii} = EXT;
        try
            % Make a simple interface.
            str = '';
            while ~strcmp(str,'exit')
                obj = ezstat(varargin{ii});
            end
            
            H{ii} = obj;
        catch ERR
            H{ii} = ~EXT;
            ncl_err('flag_p: ',ERR.message);
        end
    end
end
