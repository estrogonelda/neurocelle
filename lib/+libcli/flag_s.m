function output = flag_s(obj,varargin)

% ---------------------------> FLAG_S help <------------------------------------
% FLAG_S - General statistics flag.
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
    %EXT = 0;
    
    % --- Variable declarations.
    % Control param.
    ret = [];
    
    % Others. Can receive up to two object and/or string arguments.
    argcount = ones(nargin-1,1);
    
    
    % =======================> FUNCTION CODE <==================================
    try
        % Inputs adjustment.
        args = nargin - 1;
        
        % Inputs verification and counting.
        for ii = 1:args
            % Value 1 for numeric arguments (dafeult).
            if isa(varargin{ii},class(obj)) % statclass here.
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
            ret(2) = varargin{k(2)};
            ret(1) = varargin{k(1)};
        elseif size(k,1) == 1
            % One input object.
            ret = varargin{k};
        end
        
        k = find(argcount == 1);
        switch size(k,1)
            case 0
                % Work on objects only.
                if ~any(argcount == 2)
                    error('No valid input arguments supplied.');
                end
            case 1
                %One sample matrix.
                
                % Square matrix verification.
                if iscorrelation(varargin{k})
                    % Test on correlation matrix.
                    disp('corr');
                elseif iscovariance(varargin{k})
                    % Test on covariance matrix.
                    disp('cov');
                elseif size(varargin{k},1) >= size(varargin{k},2)
                    % Calculate mean, std & cov, normalizations transformations,
                    % corr, T2, MANOVA and PCA.
                    disp('test');
                    
                    ret = statclass;
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
                
                if size(varargin{k(1)},1) ~= size(varargin{k(2)},1) ...
                    && size(varargin{k(1)},2) ~= size(varargin{k(2)},2)
                    
                    % Test on totaly diferent sample matrixes.
                    disp('Totaly diferent.');
                elseif size(varargin{k(1)},1) == size(varargin{k(2)},1) ...
                    && size(varargin{k(1)},2) ~= size(varargin{k(2)},2)
                    
                    % MRA, CCA, DA, ANN.
                    disp('Preditions.');
                elseif size(varargin{k(1)},1) ~= size(varargin{k(2)},1) ...
                    && size(varargin{k(1)},2) == size(varargin{k(2)},2)
                    
                    % Unbalanced T2, PA.
                    disp('Umbalanced two sample.');
                elseif any(strcmp(varargin(argcount == 3),'paired'))
                    % T2, PA.
                    disp('Paired two sample.');
                elseif iscovariance(varargin{k(1)}) && iscovariance(varargin{k(2)})
                    % MANCOVA.
                    disp('Covariance.');
                else
                    % Balanced and unpaired T2, PA.
                    disp('Balanced and unpaired two sample.');
                end
            otherwise
                % Many input arguments.
                
                % Singularity and sizes verification.
                counters = zeros(size(k,1),4); % Rows, columns and number of matrixes.
                for ii = 1:size(counters,1)
                    if isempty(varargin{k(ii)}) || size(varargin{k(ii)},1) < size(varargin{k(ii)},2)
                        error('Number of sample units must be greater than the dimensions.');
                    end
                    
                    counters(ii,1) = size(varargin{k(ii)},1);
                    counters(ii,2) = size(varargin{k(ii)},2);
                    counters(ii,3) = iscovariance(varargin{k(ii)});
                    counters(ii,4) = iscorrelation(varargin{k(ii)});
                end
                
                if all(counters(1,1) == counters(:,1:2))
                    % Square matrixes. Covariances or correlations.
                    disp('Square.');
                elseif all(counters(1,1) == counters(:,1)) && all(counters(1,2) == counters(:,2)) ...
                        && any(strcmp(varargin(argcount == 3),'paired'))
                    % Paired sample matrixes.
                    disp('Paired.');
                elseif all(counters(1,1) == counters(:,1)) && all(counters(1,2) == counters(:,2))
                    % Balanced and unpaired sample matrixes.
                    disp('Balanced.');
                elseif all(counters(1,1) == counters(:,1))
                    % Predictions, desn't exist here.
                    disp('Predictions.');
                elseif all(counters(1,2) == counters(:,2))
                    % MANOVA.
                    disp('MANOVA.');
                else
                    % Totaly unconsistent matrix sizes.
                    error('Unconsistent sample sizes.');
                end
        end
        
        % Return.
        output = ret;
    catch ERR
        output = [];
        obj.log.note('flag_s: ',ERR.message);
    end
end
