function H = flag_h(obj,varargin)

% Display a help text.


    % Setting return status.
    EXT = true;
    
    try
        % Adjusting inputs.
        if isempty(varargin)
            str = 'ncl';
        elseif ~ischar(varargin{1})
            % Invalid search term.
            error('Invalid search term in ''-h'' flag.');
        else
            str = varargin{1};
        end
        
        % Can make only one help search.
        help(str);
        
        % Success return status.
        H = EXT;
    catch ERR
        % Failure return status.
        H = ~EXT;
        obj.log.note('flag_h: ',ERR.message);
        return;
    end
end
