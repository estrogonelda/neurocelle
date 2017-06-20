classdef statclass

% Statistics object.


    properties
        anlType
        tranformFcn
        % --- Raw data.
        X
        T
        Y
        E
        % --- Covariances and Correlations matrixes.
        % Inputs.
        Sx
        Rx
        % Targets.
        St
        Rt
        % Outputs.
        Sy
        Ry
        % Errors.
        Se
        Re
        % --- Other params.
        n
        k
        B_
        SSt
        SSr
        SSe
        df
        MSr
        MSe
        test
        p
        % --- Relations.
        R2
        R2adj
        R2pred
        PRESS
        mse
        e
        % --- Outliers analysis.
        D
        leverage
        lof
    end
    
    methods
        function obj = statclass(varargin)
            if nargin
                try
                    % Inputs adjustment.
                    argcount = ones(nargin,1);
                    
                    % Inputs verification and counting.
                    for ii = 1:nargin
                        % Value 1 for numeric arguments (dafeult).
                        if isa(varargin{ii},class(obj))
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
                    ki = find(argcount == 2);
                    if size(ki,1) == 2
                        % Two input objects.
                        obj(2) = varargin{ki(2)};
                        obj(1) = varargin{ki(1)};
                    elseif size(ki,1) == 1
                        % One input object.
                        obj = varargin{ki};
                    end
                    
                    ki = find(argcount == 1);
                    switch size(ki,1)
                        case 0
                            % Work on objects only.
                            if ~any(argcount == 2)
                                error('No valid input arguments supplied.');
                            end
                        case 1
                            %One input matrix.
                            
                            % Square matrix verification.
                            if iscorrelation(varargin{ki})
                                % Test on correlation matrix.
                                disp('corr');
                            elseif iscovariance(varargin{ki})
                                % Test on covariance matrix.
                                disp('cov');
                            elseif size(varargin{ki},1) >= size(varargin{ki},2)
                                % Calculate mean, std & cov, normalizations transformations,
                                % corr, T2, MANOVA and PCA.
                                disp('test');
                            else
                                error('Number of sample units must be greater than the dimensions.');
                            end
                        case 2
                            % Two sample matrixes.
                            
                            % Singularity verification.
                            if isempty(varargin{ki(1)}) || isempty(varargin{ki(2)}) ...
                                || size(varargin{ki(1)},1) < size(varargin{ki(1)},2) ...
                                || size(varargin{ki(2)},1) < size(varargin{ki(2)},2)
                                
                                error('Number of sample units must be greater than the dimensions.');
                            end
                            
                            if size(varargin{ki(1)},1) ~= size(varargin{ki(2)},1) ...
                                && size(varargin{ki(1)},2) ~= size(varargin{ki(2)},2)
                                
                                % Test on totaly diferent sample matrixes.
                                disp('Totaly diferent.');
                            elseif size(varargin{ki(1)},1) == size(varargin{ki(2)},1) ...
                                && size(varargin{ki(1)},2) ~= size(varargin{ki(2)},2)
                                
                                % MRA, CCA, DA, ANN.
                                disp('Preditions.');
                            elseif size(varargin{ki(1)},1) ~= size(varargin{ki(2)},1) ...
                                && size(varargin{ki(1)},2) == size(varargin{ki(2)},2)
                                
                                % Unbalanced T2, PA.
                                disp('Umbalanced two sample.');
                            elseif any(strcmp(varargin(argcount == 3),'paired'))
                                % T2, PA.
                                disp('Paired two sample.');
                            elseif iscovariance(varargin{ki(1)}) && iscovariance(varargin{ki(2)})
                                % MANCOVA.
                                disp('Covariance.');
                            else
                                % Balanced and unpaired T2, PA.
                                disp('Balanced and unpaired two sample.');
                            end
                        otherwise
                            % Many input arguments.
                            
                            % Singularity and sizes verification.
                            counters = zeros(size(ki,1),4); % Rows, columns and number of matrixes.
                            for ii = 1:size(counters,1)
                                if isempty(varargin{ki(ii)}) || size(varargin{ki(ii)},1) < size(varargin{ki(ii)},2)
                                    error('Number of sample units must be greater than the dimensions.');
                                end
                                
                                counters(ii,1) = size(varargin{ki(ii)},1);
                                counters(ii,2) = size(varargin{ki(ii)},2);
                                counters(ii,3) = iscovariance(varargin{ki(ii)});
                                counters(ii,4) = iscorrelation(varargin{ki(ii)});
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
                catch ERR
                    % notify here.
                    error(['statclass: ' ERR.message]);
                end
            end
        end
        
        % --- Other graphic functions.
        function obj = parammkr(obj,varargin)
            obj = mstats.parammkr(obj,varargin{:});
        end
    end
end
