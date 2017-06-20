function H = flag_r(obj,varargin)

% Report function.

    % Setting return status.
    EXT = 0;
    varargin
    % Initialy, 'H' is set to the exit status 'exit_stt', that is, by default
    % the success value '0', changing inside the function, if needed.
    H = cell(nargin-1,1);
    for ii = 1:nargin-1
        try
            % Feel the input.
            switch class(varargin{ii})
                case 'char'
                    %obj.commons.uid = 'char';
                case 'struct'
                    % Compiling LaTeX report.
                    obj.commons.uid = 'cell';
                otherwise
                    error('Invalid flag input.');
            end
            
            H{ii} = obj;
        catch ERR
            H{ii} = ~EXT;
            obj.log.note('flag_r: ',ERR.message);
        end
    end
end
