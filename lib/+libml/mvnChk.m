function [H, b1, b2, mtx, idx, Huniv, Puniv] = mvnChk(varargin)

% ---------------------------> NCL help <--------------------------------------
% MVNCHECK - Check if input matrix was taken from a multivariate normal
% distribution.
%
% Author: <a href="matlab:disp('It is a working link!');">José Leonel L. Buzzo</a>
% Last Modified: 11/06/2016
% -----------------------------------------------------------------------------


    % =======================> PREAMBLE <======================================
    
    % --- Macro Definitions.
    % Exit status.
    %EXT = false;
    
    
    % --- Variable declarations.
    % Significance level for all the tests.
    alpha = 0.05;
    
    % Input options. 'opt' is the remove outliers option [('') | -r].
    opt1 = '';
    opt2 = '';
    
    % Output options.
    % Overall hypothesis test:
    %   H0: accept the n-variate normality assumption; (return 0 in this case)
    %   H1: reject it (returns 1).
    H = [];
    % Skewness and Kurtosis params.
    b1 = [];
    b2 = [];
    % Return matrix, eventually with no outliers (use '-r' flag);
    mtx = [];
    % Index of outliers' position in the input matrix rows.
    idx = [];
    % Univariate hypotesis contraparts.
    Huniv = [];
    % Univariate probabilities contraparts.
    Puniv = [];
    
    
    % =======================> FUNCTION CODE <=================================
    
    try
        % Some concistency checks.
        if ~nargin || ~(isnumeric(varargin{1}) && ~isempty(varargin{1}) && size(varargin{1},1) > 3)
            error('Invalid inputs.');
        end
        
        % Distribution general parameters.
        n = size(varargin{1},1);
        p = size(varargin{1},2);
        mtx = zeros(n,p);
        idx = true(n,1);
        Huniv = ones(1,p);
        Puniv = zeros(1,p);
        
        % Univariate normality assessment.
        for ii = 1:p
            % Testing for univariate normality with chi2 test. 'chi2gof' returns
            % 0 if it couldn't reject the null hypothesis of normality, and
            % returns 1 otherwise.
            %[Huniv(ii), Puniv(ii)] = adtest(varargin{1}(:,ii),'Alpha',alpha);
        end
        
        % Remove outliers, default is ''.
        if any(strcmp(varargin,'-r'))
            opt1 = '-r';
        end
        
        % Choose to show a Q-Q plot or not.
        if any(strcmp(varargin,'plot'))
            opt2 = 'plot';
        end
        
        % If all univariate distributions are normal, test for multivariate
        % normality.
        [H, b1, b2, mtx, idx] = check(varargin{1},alpha,opt1,opt2);
    catch ERR
        error(['mvnCheck: ' ERR.message]);
    end
end


function [H, b1, b2, mtx, outliers] = check(mtx, alpha, opt1, opt2)

% Internal check.


    % Failure return status;
    H = [];
    
    % --- Testing with standard distances first.
    
    % Preallocating memory.
    n = size(mtx,1);
    p = size(mtx,2);
    D2 = zeros(n,1);
    u = zeros(n,1);
    g = zeros(n);
    y = zeros(n,p);
    outliers = false(n,1);
    mn = mean(mtx);
    Sinv = cov(mtx)^-1;
    % Parameters for mardia's test.
    b1 = []; % N-variate Skewness.
    b2 = []; % N-variate Kurtosis.
    
    
    for ii = 1:n
        k = mtx(ii,:) - mn;
        D2(ii) = k*Sinv*k'; % Distance in the n-space for the ith element.
    end
    
    % If 'u' has a beta-like distribution, then 'mtx' has a normal
    % n-variate distribution.
    idx = sortrows([(1:n)' (n/(n-1)^2).*D2],2);
    u = idx(:,2);
    quantiles = ((1:n)'-1/2)/n;
    
    % 'u' must be distributed like a 'beta' distribution with params
    % 'a' = p/2 and 'b' = (n-p-1)/2, respectively.
    a = p/2;
    b = (n-p-1)/2;
    v = betainv(quantiles,a,b);
    
    % Alternative way to calcule a Beta distribution parameters.
    %alph = (p-2)/2*p;
    %beta = (n-p-3)/(2*(n-p-1));
    %v = ((1:n)'-alph)/(n-alph-beta+1)
    
    
    % Marking non outliers indexes.
    outliers = u > betainv(1-alpha,a,b);
    
    
    % --- Testing with Mardia's approach.
    SIGMA = zeros(p);
    for ii = 1:n
        y(ii,:) = mtx(ii,:) - mn;
        SIGMA = SIGMA + y(ii,:)'*y(ii,:)/n;
    end
    SIGMA = SIGMA^-1;
    
    for jj = 1:n
        for ii = 1:n
            g(ii,jj) = y(ii,:)*SIGMA*y(jj,:)'; % Distance in the n-space for the ith element.
        end
    end
    b1 = (1/n^2)*sum(g(:).^3);
    b2 = (1/n)*sum(diag(g).^2);
    
    % Values 'z1' are distributed like a Chi2 distribution with 'df' degrees of freedom.
    z1 = b1*(p+1)*(n+1)*(n+3)/(6*((n+1)*(p+1)-6));
    
    % Values 'z1' and 'z2' are N(0,1).
    z2 = (b2 - p*(p+2))/sqrt(8*p*(p+2)/n);
    z3 = (b2 - p*(p+2)*(n+p+1)/n)/sqrt(8*p*(p+2)/(n-1));
    df = p*(p+1)*(p+2)/6;
    szAdjust = z3;
    if n > 400
        szAdjust = z2;
    end
    
    % Debug code.
    %disp([chi2inv(0.95,df) z1 z2 z3 b1 b2]);
    
    % Final skewness and kurtosis test.
    if z1 < chi2inv(0.95,df) && (szAdjust > norminv(0.025) && z2 < norminv(0.975))
        H = 0;
    else
        % H0 Hypotesis rejection!
        H = 1;
    end
    
    aux = sum(outliers);
    num = aux;
    outliers(:) = false;
    outliers(end-num+1:end) = true;
    
    % Q-Q_plot with outliers detection (if wanted).
    if strcmp(opt2,'plot')
        hdl = plot(v,v,'g',u,v,'b.',u(outliers),v(outliers),'r.');
        set(hdl(3),'MarkerSize',20);
        %title(['Multivariate (n=' num2str(n) ') Q-Q plot for normality assessment and outlier detection.']);
        title(['Q-Qplot para teste de normalidade multivariada (n = ' num2str(n) ', p = ' num2str(p) ') e outliers.']);
        xlabel('Estatistica u [u = (n/(n-1)^2).*D2]');
        ylabel('Estatistica v [v = betainv(quantiles,a,b)]');
        grid on;
        legend([hdl(1) hdl(2) hdl(3)],'v = u','Non-Outliers','Outliers','Location','SouthEast');
    end
    
    % Adjust outliers indexes.
    %aux = sum(outliers);
    outliers(:) = false;
    outliers(idx(end-aux+1:end,1)) = true;
    
    % Remove all outliers (if wanted).
    if strcmp(opt1,'-r')
        mtx = mtx(~outliers,:);
    end
end
