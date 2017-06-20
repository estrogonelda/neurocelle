function argcount = flagwrapper(varargin)

% Analysing flag inputs.


    % Argument counter: numeric (1), char (2), cell (3), structure or object
    % (4) and invalid (0) values.
    argcount = ones(nargin,1,'uint8');
    
    try
        % Inputs verification and counting.
        for ii = 1:nargin
            if ischar(varargin{ii})
                argcount(ii) = 2;
            elseif iscell(varargin{ii})
                argcount(ii) = 3;
            elseif isa(varargin{ii},'progetto')
                argcount(ii) = 4;
            elseif ~isnumeric(varargin{ii})
                argcount(ii) = 0;
            end
        end
    catch ERR
        error(['flagwrapper: ',ERR.message]);
    end
end
