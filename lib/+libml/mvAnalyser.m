function output = mvAnalyser(varargin)

% MVANALYSER - General multivariate analyser for parameters extraction.
%
% ---------------------------> MVANALYSER help <-------------------------------
% MVANALYSER - Analyse multivariate matrixes to extract parameters, detect
% outliers and test for multivariate hypotesys.
%
% Arguments usage:
%   Detailed explanation goes here.
%
% See also: tplt, astratto.
%
% Author: <a href="matlab:disp('Working link!');">José Leonel L. Buzzo</a>
% Last Modified: 01/04/2017
% -----------------------------------------------------------------------------


    % =======================> PREAMBLE <======================================
    
    % -----------------------> Macro Definitions ------------------------------
    % Exit status.
    %EXT = 0;
    
    % -----------------------> Library import ---------------------------------
    import('libflmgr.*');
    import('libml.*');
    
    % -----------------------> Variable declarations --------------------------
    % Significance level.
    alpha = 0.05;
    
    %  Data struct.
    data = struct(...
        'X',[],...
        'Y',[],...
        'Y_',[],...
        'E',[],...
        'B',[],...
        'B_',[],...
        'sigma',[],...
        'mean',[]);
    
    % Auxiliary parameters struct.
    params = struct(...
        'parametric',[],...
        'kurtosis',[],...
        'skewness',[],...
        'normality',[],...
        'homoskedasticity',[],...
        'n',[],...
        'q',[],...
        'p',[],...
        'mn',[],...
        'vSSt',[],...
        'vSSr',[],...
        'vSSe',[],...
        'SSt',[],...
        'SSr',[],...
        'SSe',[],...
        'MSr',[],...
        'MSe',[],...
        'Se',[],...
        'S',[],...
        'ev',[],...
        'm',[],...
        'N',[],...
        's',[],...
        'd',[],...
        'w',[],...
        't',[]);
    
    % Hypotesis test struct.
    H0 = struct(...
        'test','',...
        'value',0,...
        'df',[],...
        'pH0',0,...
        'F_value',0,...
        'F_df',[0 0],...
        'F_pH0',0);
    H0(5).test = '';
    
    % Model fit adequacy struct.
    mdl_fit = struct(...
        'coef','',...
        'value',0);
    mdl_fit(4).coef = '';
    
    % Output argument.
    output = [];
    
    
    % =======================> FUNCTION CODE <=================================
    
    try
        % Inputs consistency check.
        if nargin > 1 && size(varargin{1},1) == size(varargin{2},1) && ...
                size(varargin{2},1) > size(varargin{2},2) + 1
            
            % --- Data type adjustments (single to double).
            [X, Y] = dataConvert(varargin{1},varargin{2},'double');
            
            
            % --- Initial variables declarations.
            % Some auxiliary variables.
            n = size(X,1); % Number of units.
            q = size(X,2); % Width for X.
            p = size(Y,2); % Width for Y.
            mn = mean(Y)';
            
            % Degrees of freedom.
            vSSt = n - 1;
            vSSr = q;
            vSSe = n - q - 1;
            
            % Other params.
            m = (abs(q - p) - 1)/2;
            N = (n - q - p - 2)/2;
            s = min(p,q);
            d = max(p,vSSr);
            w = vSSe + vSSr - (p + vSSr + 1)/2;
            t = sqrt(((p*vSSr)^2 - 4)/(p^2 + vSSr^2 - 5));
            df1 = p*vSSr;
            df2 = w*t - (p*vSSr - 2);
            
            % --- General calculations for Least Mean Square model equation.
            % Adding the constant coeficient column.
            X = cat(2,ones(n,1),X);
            
            % Linear coeficients estimators.
            B_ = (X'*X)\X'*Y;
            
            % Estimates for Y.
            Y_ = X*B_;
            
            % Errors matrix.
            E = Y - Y_;
            
            % General estimators.
            SSt = Y'*Y - n*(mn*mn');
            SSr = B_'*X'*Y - n*(mn*mn');
            SSe = Y'*Y - B_'*X'*Y;
            % NOTE: Univariate case: SSt = SSe + SSr. In multivariate case: T = E + H.
            % Here, SSt = T, SSe = E and SSr = H.
            
            % Mean squares in univariate case.
            MSr = SSr/vSSr;
            MSe = SSe/vSSe;
            
            % Standartized covariance matrix for error.
            Se = SSe/vSSe;
            S = sqrt(diag(cov(E)));
            
            % Eigenvalues of (E^-1)*H for multivariate estimates.
            [~, ev] = eig(SSe\SSr);
            ev = diag(ev);
            
            
            % --- Overall regression tests: 'F' (univariate) or Wilk's 'A' (multivariate).
            if p == 1
                % General F param (univariate case).
                H0(1).test = 'F';
                H0(1).value = MSr/MSe;
                H0(1).df = [vSSr vSSe];
                H0(1).pH0 = 1 - fcdf(H0(1).F_value,H0(1).F_df(1),H0(1).F_df(2));
            else
                % Four params to base H0 rejection probability (multivariate case).
                % Wilk's lambda: A = |E|/|E + H|, for A(p,q,n-q-1).
                lambda = det(SSe)/det(SSe + SSr);
                
                H0(2).test = 'lambda';
                H0(2).value = lambda;
                H0(2).df = [p q n-q-1];
                H0(2).pH0 = 0;
                H0(2).F_value = (1 - lambda^(1/t))/(lambda^(1/t))*df1/df2;
                H0(2).F_df = [df1 df2];
                H0(2).F_pH0 = 1 - fcdf(H0(2).F_value,H0(2).F_df(1),H0(2).F_df(2));
                
                
                %lambda = det(SSe)/det(SSe + SSr);
                %F_lambda = (1 - lambda^(1/t))/(lambda^(1/t))*df1/df2;
                %pH0_Flambda = 1 - fcdf(F_lambda,df1,df2);
                
                % Roy's theta:
                theta = ev(1)/(1 + ev(1));
                H0(3).test = 'theta';
                H0(3).value = ev(1)/(1 + ev(1));
                H0(3).df = [];
                H0(3).pH0 = 0;
                H0(3).F_value = (vSSe - d - 1)*ev(1)/d;
                H0(3).F_df = [d vSSe-d-1];
                H0(3).F_pH0 = 1 - fcdf(H0(3).F_value,H0(3).F_df(1),H0(3).F_df(2));
                
                %theta = ev(1)/(1 + ev(1));
                %Ftheta = (vSSe - d - 1)*ev(1)/d;
                %pH0_Ftheta = 1 - fcdf(Ftheta,d,vSSe - d - 1);
                
                % Pillai's V:
                V = trace((SSe+SSr)\SSr);
                
                H0(4).test = 'V';
                H0(4).value = V;
                H0(4).df = [];
                H0(4).pH0 = 0;
                H0(4).F_value = (vSSe - p + s)*V/(d*(s - V));
                H0(4).F_df = [s*d s*(vSSe - p + s)];
                H0(4).F_pH0 = 1 - fcdf(H0(4).F_value,H0(4).F_df(1),H0(4).F_df(2));
                
                %V = trace((SSe+SSr)\SSr);
                %FV = (vSSe - p + s)*V/(d*(s - V));
                %pH0_FV = 1 - fcdf(FV,s*d,s*(vSSe - p + s));
                
                % Lawley-Hotelling U:
                U = sum(ev(1:s));
                
                H0(5).test = 'U';
                H0(5).value = U;
                H0(5).df = [];
                H0(5).pH0 = 0;
                H0(5).F_value = (s*(vSSe - p - 1) + 2)/(s*p*vSSr)*U;
                H0(5).F_df = [p*vSSr s*(vSSe - p - 1)+2];
                H0(5).F_pH0 = 1 - fcdf(H0(5).F_value,H0(5).F_df(1),H0(5).F_df(2));
                
                %U = sum(ev(1:s));
                %FU = (s*(vSSe - p - 1) + 2)/(s*p*vSSr)*U;
                %pH0_FU = 1 - fcdf(FU,p*vSSr,s*(vSSe - p - 1) + 2);
                
                % NOTE: It is better to base 'pH0' probability on Pillai's
                % 'V' value, given it's robustness for samples with equal
                % variances in 'Y', but Wilk's 'A' is more conservative.
                
                
                
                % Final probability value for H0 rejection.
                %if (pH0_Flambda < alpha && pH0_FV > alpha) || (pH0_Flambda > alpha && pH0_FV < alpha)
                %    pH0 = pH0_Flambda;
                %else
                %    pH0 = pH0_FV;
                %end
                
                % If 'pH0' rejects H0, p univariate F tests must be made on
                % each variable.
                % ---------------------------------------------------------
                
                % Model fit params to measure the relationship between predictors
                % and predicates.
                mdl_fit(1).coef = 'R2';
                mdl_fit(1).value = det(SSt\SSr);
                
                mdl_fit(2).coef = 'nu2lambda';
                mdl_fit(2).value = 1 - lambda;
                
                mdl_fit(3).coef = 'nu2theta';
                mdl_fit(3).value = theta;
                
                mdl_fit(4).coef = 'lambda_Lh';
                mdl_fit(4).value = (U/s)/(1 + U/s);
            end
            
            
            % --- Recursive subset selection of 'r' among a pool of 'k' 'X's,
            % based on R2, S2 and Cp (from Mallows) criteria.
            for k = 1:q
                r = 1;
                R2r = trace(SSt\SSr)/p;
                S2r = det(SSe/(n - r));
                
                treshold = ((n-r)/(n-k))^p;
                Cpr = det(SSe\SSe); % Must be |Ek^-1*Er|
                % NOTE: It must reach: Cpr <= [(n-r)/(n-k)]^p, for r X among k.
            end
            
            params = struct(...
                'parametric',[],...
                'kurtosis',[],...
                'skewness',[],...
                'normality',[],...
                'homoskedasticity',[],...
                'n',n,...
                'q',q,...
                'p',p,...
                'mn',mn,...
                'vSSt',vSSt,...
                'vSSr',vSSr,...
                'vSSe',vSSe,...
                'SSt',SSt,...
                'SSr',SSr,...
                'SSe',SSe,...
                'MSr',MSr,...
                'MSe',MSe,...
                'Se',Se,...
                'S',S,...
                'ev',ev,...
                'm',m,...
                'N',N,...
                's',s,...
                'd',d,...
                'w',w,...
                't',t);
            
            data.E = E;
            data.B_ = B_;
        else
            error('Invalid inputs.');
        end
    catch ERR
        error(['+libml.mvAnalyser: ' ERR.message]);
    end
    
    % Output argument.
    output = struct(...
        'data',data,...
        'params',params,...
        'H0',H0,...
        'fit',mdl_fit);
end
