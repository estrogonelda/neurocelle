function H = flag_o(obj,varargin)

% ---------------------------> FLAG_S help <------------------------------------
% FLAG_O - General object flag.
%
% Arguments usage:
%   
%   If no object argument is supplied, the statistics are returned on the
%   default object, otherwise it will be returned on the supplied one.
%   
% See also: no_flag.
%
% Author: José Leonel L. Buzzo.
% Last Modified: 11/06/2016.
% ------------------------------------------------------------------------------


    % =======================> PREAMBLE <=======================================
    
    % --- Macro Definitions.
    % Success exit status.
    EXT = 0;
    
    % --- Variable declarations.
    % Control param.
    ctrl = 0;
    
    % Inputs adjustment.
    args = nargin - 1;
    
    % Others. Can receive until two object and/or string arguments.
    argcount = ones(nargin-1,1);
    
    
    % =======================> FUNCTION CODE <==================================
    try
        % Inputs verification and counting.
        for ii = 1:args
            % Value 1 for numeric arguments (dafeult).
            if isa(varargin{ii},obj.meta.extension)
                % Value 2 for object arguments.
                argcount(ii) = 2;
            elseif ischar(varargin{ii})
                % Value 3 for character arguments.
                argcount(ii) = 3;
            elseif ~isnumeric(varargin{ii})
                % Value 0 for invalid type arguments.
                argcount(ii) = 0;
            end
        end
        
        % Action decisions.
        k = find(argcount == 2);
        if size(k,1) == 2
            % Two input objects.
            obj(2) = varargin{k(2)};
            obj(1) = varargin{k(1)};
        elseif size(k,1) == 1
            % One input object.
            obj = varargin{k};
        end
        
        
        k = find(argcount == 1);
        switch size(k,1)
            case 0
                % Work on objects only.
                if ~any(argcount == 2)
                    error('No valid input arguments supplied.');
                end
            case 1
                %One input matrix.
                
                % Unsupervised learning.
                if ~isempty(varargin{k}) && size(varargin{k},1) >= size(varargin{k},2)% && size(varargin{k},1) < 20
                    %obj = annarch(obj,varargin{k(jj)});
                    disp('Unsup');
                else
                    error('Number of sample units must be greater than the dimensions.');
                end
            case 2
                % Two sample matrixes.
                
                % Singularity verification.
                if isempty(varargin{k(1)}) || isempty(varargin{k(2)}) ...
                    || size(varargin{k(1)},1) < size(varargin{k(1)},2) ...
                    || size(varargin{k(2)},1) < size(varargin{k(2)},2)
                    
                    error('Number of sample units must be greater than the dimensions.');
                end
                
                if size(varargin{k(1)},1) == size(varargin{k(2)},1) && any(strcmp(varargin(argcount == 3),'suppervised'))
                    % Supervised learning.
                    disp('Sup2');
                else
                    % Unsupervised learning.
                    disp('Unsup2');
                end
            otherwise
                % Many input arguments.
                
                % Sizes verification.
                counters = zeros(size(k)); % Rows, columns and number of matrixes.
                for ii = 1:size(counters,1)
                    if isempty(varargin{k(ii)}) || size(varargin{k(ii)},1) < size(varargin{k(ii)},2)
                        error('Number of sample units must be greater than the dimensions.');
                    end
                    
                    counters(ii) = size(varargin{k(ii)},1);
                end
                
                % Decision between supervised or unsupervised learning.
                position = find(strcmp(varargin(:),'suppervised'));
                if ~isempty(position) && k(end) - position(1) > 1 && mod(k(end)-position(1),2) == 0 ...
                        && all(counters(k > position(1)) == counters(end))
                    % Supervised learning.
                    for jj = position(1)+1:2:k(end)
                        %obj = annarch(obj,varargin{k(jj)},varargin{k(jj+1)});
                        disp(size(varargin{jj}));
                    end
                elseif isempty(position)
                    % Unsupervised learning.
                    for jj = 1:size(k,1)
                        %obj = annarch(obj,varargin{k(jj)});
                        disp(size(varargin{k(jj)}));
                    end
                else
                    % Totaly unconsistent matrix sizes.
                    error('Unconsistent sample sizes.');
                end
        end
        
        
        H = obj;
    catch ERR
        H = ~EXT;
        ncl_err(obj.commons.udir,'flag_o: ',ERR.message);
    end
end
