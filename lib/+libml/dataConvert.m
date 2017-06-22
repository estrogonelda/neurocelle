function varargout = dataConvert(varargin)

% DATATRANSFORM Summary of this function goes here
%   Detailed explanation goes here


    % Possible options.
    str = {'double', 'mtx', 'dataset', 'obj'};
    
    
    try
        % Options' positions.
        pos = false(1,nargin);
        
        for ii = 1:size(str,2)
            % Find transformations params sequentially.
            pos = pos | strcmp(varargin,str{ii});
        end
        num = sum(pos);
        varargout = cell(1,nargin-num);
        
        ctrl = 0;
        for ii = 1:nargin
            k = find(pos,1,'first');
            
            % Existence verification.
            if isempty(k)
                break;
            elseif ii == k
                pos(k) = false;
                continue;
            elseif ischar(varargin{ii})
                % Only nunmeric values.
                continue;
            else
                ctrl = ctrl + 1;
            end
            
            % Find transformations params sequentially.
            switch varargin{k}
                case 'double'
                    [varargout{ctrl}] = double(varargin{ii});
                case 'dataset'
                    [varargout{ctrl}] = single(varargin{ii});
                otherwise
                    screen(['Invalid convertion type: ''' varargin{k} ''''],'');
                    [varargout{ctrl}] = [];
            end
        end
        
        % Varargout adjust.
        if size(varargout,2) < nargout
            disp('Q??');
            [varargout(size(varargout,2)+1:nargout)] = {[]};
        end
    catch ERR
        error(['+libml.dataConvert: ' ERR.message]);
    end
end
