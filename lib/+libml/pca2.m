%function [coeff,score,latent,tsquared,explained,mu] = pca()
function [PC EV SCR EXP_VAR PVAL T2] = pca2(varargin)

% ---------------------------> PCA help <------------------------------------
% PCA- Principal Components Analysis maker!!
%
%   Here 'mtx' must be disposed with variables per columns and units per
%   rows.
%   
%   Note: 'opt' can be 'padronize' or anything else. Choose 'padronize' to
%   contruct the Principal Component matrix based on the correlation matrix
%   of 'mtx'.
%
% Author: <a href="matlab:disp('It is a working link!');">José Leonel L. Buzzo</a>
% Last Modified: 11/06/2016
% ------------------------------------------------------------------------------


    % =======================> PREAMBLE <=======================================
    
    % Macro definitions.
    % ------------------
    
    % --- Variable declarations.
    opt = '';
    
    % Library 'libml' import to use 'pdr' function.
    import libml.*;
    
    % =======================> FUNCTION CODE <==================================
    
    try
        % Some concistency checks.
        if ~nargin || ~(isnumeric(varargin{1}) && ~isempty(varargin{1}) && size(varargin{1},1) > 3)
            error('Invalid inputs.');
        end
        
        % Input matrix atributes;
        n = size(varargin{1},1);
        p = size(varargin{1},2);
        
        % --- Memory allocation.
        % Principal Components matrix.
        PC = zeros(p, 'single');
        % Eigenvalues vector.
        EV = zeros(p, 1, 'single');
        % Scores.
        SCR = zeros(n, p, 'single');
        % Explained Variance vector.
        EXP_VAR = zeros(p, 1, 'single');
        % Significance level per component.
        PVAL = zeros(p, 1, 'single');
        % Hotelling's T2.
        T2 = zeros(n, 1, 'single');
        % Auxiliar variable.
        aux = zeros(p, p + 1,'single');
        
        
        % Option validity.
        if any(strcmp(varargin,'padronize'))
            opt = 'padronize';
        end
        
        % Choosing how to construct the Principal Componets matrix.
        if strcmp(opt,'padronize')
            % From correlation matrix on padronized values.
            [PC, PVAL] = corr(varargin{1});
            [PC, vals] = eig(PC);
        else
            % From covariance matrix on the raw values.
            [PC, vals] = eig(cov(varargin{1}));
        end
        
        % Taking eigenvalues.
        EV = diag(vals);
        
        % Adjustments on the PC and EV order. Sorting in decreasing order.
        aux = sortrows(cat(2, PC', EV), -(p + 1));
        PC = aux(:, 1:end-1)';
        EV = aux(:, end);
        
        % Explained variance.
        EXP_VAR = EV./sum(EV);
        
        % Chooose the k first eigenvectors that explains more than 95% of
        % total variability in data.
        [~, k] = max(diff(EXP_VAR,2));
        k = min(k+2,size(find(cumsum(EXP_VAR) < 0.95), 1)+1);
        
        % Scree plot.
        %plot(1:p,EXP_VAR);
        
        % User can choose to retain all principal components in output with
        % the flag '-all'.
        if any(strcmp(varargin,'all'))
            k = p;    
        end
        
        % Scores.
        if strcmp(opt,'padronize')
            SCR = (PC(:,1:min(k,p))'*pdr(varargin{1})')';
        else
            SCR = (PC(:,1:min(k,p))'*varargin{1}')';
        end
    catch ERR
        error(['pca: ', ERR.message]);
    end
end
