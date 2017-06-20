function varargout = loader(varargin)

% LOADER - Generic loader and validator for object attributes.


    % ===> PREAMBLE <===
    
    % --- Macro Definitions.
    % Setting exit status.
    EXT = 0;
    
    % --- Variable declarations.
    % --------------------------
    
    % ===> FUNCTION CODE <===
    try
        % Analysing both arguments.
        args = 4;
        if ~nargout && ~nargin
            args = 1;
        elseif ~nargout && nargin
            args = 2;
        elseif ~nargin
            args = 3;
        end
        
        % Argument based switch.
        switch args
            case 1
                
            case 2
                
            case 3
                
            case 4
                
            otherwise
                ncl_error('','');
        end
        
        [varargout{1:nargout}] = varargin{:};
    catch ERR
        [varargout{1:nargout}] = varargin{:};
        ncl_err('+libbase.@modulo.loader: ',ERR.message);
    end
end
