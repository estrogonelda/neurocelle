function validate(obj)

% +LIBNCL.@PROGETTO.VALIDATE Summary of this function goes here
%   Detailed explanation goes here


    % Library import.
    import('libflmgr.*');
    
    % Validating fields, sequentially.
    fds = properties(obj);
    for ii = 1:size(fds,1)
        try
            switch fds{ii}
                case 'id'
                    
                case 'meta'
                    
                otherwise
            end
        catch ERR
            error(['+libncl.@progetto.validate: ' ERR.message]);
        end
    end
end
