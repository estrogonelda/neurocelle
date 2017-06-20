function varargout = tplt(obj,varargin)

% ---------------------------> TPLT help <-------------------------------------
% TPLT - Make input arguments management.
%
% Arguments usage:
%   jljlk
%   
% See also: ncl.
%
% Author: José Leonel L. Buzzo.
% Last Modified: 11/06/2016.
% -----------------------------------------------------------------------------


    % =======================> PREAMBLE <======================================
    
    % -----------------------> Macro Definitions ------------------------------
    % Success exit status.
    EXT = 0;
    
    % -----------------------> Library import ---------------------------------
    import('libflmgr.*');
    
    % -----------------------> Variable declarations --------------------------
    % Adjusting inputs number.
    xnargin = nargin - 1;
    
    
    % =======================> FUNCTION CODE <=================================
    
    try
        % Analysing both arguments.
        args = 4;
        if ~nargout && ~xnargin
            args = 1;
        elseif ~nargout && xnargin
            args = 2;
        elseif ~xnargin
            args = 3;
        end
        
        % Argument based switch.
        switch args
            case 1
                % Open a new configuration file to edit.
                screen('Open a new configuration file to edit.','');
                edit('Untitled.xml');
            case 2
                % Exception for '-h' flag.
                if size(varargin,2) == 1 && strcmp(varargin(1),'-h')
                    flag_h(obj);
                else
                    % Analysing flags.
                    flag_analyser(obj,varargin{:});
                    % Inner processes goes here.
                    % Here the 'ans' variable can take the return value of
                    % flag_analyser.
                end
            case 3
                % Load the default configuration file.
                screen('Load the default configuration file.','');
                %H = feval(structure.info.loaderfcn,structure);
                
                [varargout(1:nargout)] = {obj};
            case 4
                % Exception for '-h' flag.
                if size(varargin,2) == 1 && strcmp(varargin(1),'-h')
                    flag_h(obj);
                    [varargout(1:nargout)] = {EXT};
                else
                    % Analysing flags.
                    [varargout{1:nargout}] = flag_analyser(obj,varargin{:});
                end
            otherwise
                error('Invalid input arguments.');
        end
    catch ERR
        % Custom error message.
        obj.log.note('tplt: ',ERR.message);
    end
end


function varargout = flag_analyser(structure,varargin)

    % Library import.
    import('libcli.*');
    
    % Counting outputs and inputs.
    flags = structure.flags;
    H = cell(size(flags,1)+1,1);
    H_ept = false(size(H));
    argsin = varargin;
    
    
    % Counting flags.
    idxn = zeros(size(flags,1),1);
    for ii = 1:size(argsin,2)
        if ischar(argsin{ii})
            idxn(strcmp(flags(:,1),argsin{ii})) = ii;
        end
    end
    
    % Analysing flags' validity.
    ii = 1;
    while ii <= size(flags,1)
        % Counting valid flags.
        nums = min(idxn(idxn > idxn(ii)) - idxn(ii)) > 1;
        % This cause an empty matrix if ii is in the greater position of idxn.
        
        if idxn(ii) && ~isempty(nums) && nums % Only for nums > 1.
            nums = min(idxn(idxn > idxn(ii)) - idxn(ii)) - 1;
        elseif idxn(ii) && isempty(nums) && idxn(ii) < size(argsin,2)
            nums = size(argsin,2) - idxn(ii);
        else
            ii = ii + 1;
            continue;
        end
        
        % Execute function handle to the currect flag.
        H{ii+1} = flags{ii,2}(structure,argsin{idxn(ii)+1:idxn(ii)+nums});
        H_ept(ii+1) = true;
        
        ii = ii + 1;
    end
    
    % Action with no flags goes here.
    if all(idxn == 0)
        H{1} = no_flag(structure,argsin{:});
        H_ept(1) = true;
    elseif min(idxn(idxn > 0)) > 1
        H{1} = no_flag(structure,argsin{1:min(idxn(idxn > 0))-1});
        H_ept(1) = true;
    end
    
    
    % Output returns.
    if nargout == 0
        varargout = {H};
    elseif nargout <= size(H(H_ept),1);
        H = H(H_ept);
        varargout(1:nargout) = H(1:nargout);
    else
        H = H(H_ept);
        varargout(1:nargout) = cat(1,H,cell(nargout - size(H,1),1));
    end
end
