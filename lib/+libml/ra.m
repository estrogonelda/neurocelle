function output = ra(varargin)

% MRAMKR - Make Multivariate Multiple Regression Analisys (parametric or not)
% and model fit diagnostics.



    % Import 'libml' library.
    import libml.*;
    
    try
        % Inputs consistency check.
        if nargin > 1 && size(varargin{1},1) == size(varargin{2},1) && ...
                size(varargin{2},1) > size(varargin{2},2) + 1
            
            % --- Data type adjustments (single to double).
            [X, Y] = dataConvert(varargin{1},varargin{2},'double');
            
            
            % --- Initial variables declarations.
            % Some auxiliary variables.
            n = size(varargin{1},1); % Number of units.
            q = size(varargin{1},2); % Width for X.
            p = size(varargin{2},2); % Width for Y.
            mn = mean(Y)';
            
            % Degrees of freedom.
            vT = n - 1;
            vH = q;
            vE = n - q - 1;
            
            % Other params.
            alpha = 0.05;
            m = (abs(q - p) - 1)/2;
            N = (n - q - p - 2)/2;
            s = min(p,q);
            d = max(p,vH);
            w = vE + vH - (p + vH + 1)/2;
            t = sqrt(((p*vH)^2 - 4)/(p^2 + vH^2 - 5));
            df1 = q*vH;
            df2 = w*t - (p*vH - 2);
            
            % Hypotesis tests params.
            F = 0;      % General F param.
            A = 0;      % Wilk's param.
            theta = 0;  % Roy's param.
            V = 0;      % Pillai's param.
            U = 0;      % Lawley-Hotelling param.
            pH0 = 0;    % Overall H0 rejection probability.
            
            % Model fit params.
            R2 = 0;
            nu2A = 0;
            nu2theta = 0;
            Alh = 0;
            
            
            % --- General calculations for Least Mean Square model equation.
            % Adding the constant coeficient column.
            X = cat(2,ones(n,1),X);
            
            % Linear coeficients estimators.
            B_ = (X'*X)\X'*Y;
            
            % Estimates for Y.
            Y_ = X*B_;
            
            % Errors matrix.
            e = Y - Y_;
            
            % General estimators.
            T = Y'*Y - n*(mn*mn');
            H = B_'*X'*Y - n*(mn*mn');
            E = Y'*Y - B_'*X'*Y;
            % NOTE: Univariate case: SSt = SSe + SSr. In multivariate case: T = E + H.
            % Here, SSt = T, SSe = E and SSr = H.
            
            % Standartized covariance matrix for error.
            Se = E/vE;
            S = sqrt(diag(cov(e)));
            
            % Mean squares in univariate case.
            MSr = H/vH;
            MSe = E/vE;
            
            % Eigenvalues of (E^-1)*H for multivariate estimates.
            [~, ev] = eig(E\H);
            ev = diag(ev);
            
            
            % --- Overall regression tests: 'F' (univariate) or Wilk's 'A' (multivariate).
            if p == 1
                % 'F' based H0 rejection probability (univariate case).
                F = MSr/MSe;
                
                % Final probability value for H0 rejection.
                pH0 = 1 - fcdf(F,vH,vE);
            else
                % Four params to base H0 rejection probability (multivariate case).
                % Wilk's A: A = |E|/|E + H|, for A(p,q,n-q-1).
                A = det(E)/det(E + H);
                
                FA = (1 - A^(1/t))/(A^(1/t))*df1/df2;
                pH0_FA = 1 - fcdf(FA,df1,df2);
                
                % Roy's test theta:
                theta = ev(1)/(1 + ev(1));
                
                Ftheta = (vE - d - 1)*ev(1)/d;
                pH0_Ftheta = 1 - fcdf(Ftheta,d,vE - d - 1);
                
                % Pillai's test V:
                V = trace((E+H)\H);
                
                FV = (vE - p + s)*V/(d*(s - V));
                pH0_FV = 1 - fcdf(FV,s*d,s*(vE - p + s));
                
                % Lawley-Hotelling
                U = sum(ev(1:s));
                
                FU = (s*(vE - p - 1) + 2)/(s*p*vH)*U;
                pH0_FU = 1 - fcdf(FU,p*vH,s*(vE - p - 1) + 2);
                
                % Final probability value for H0 rejection.
                if (pH0_FA < alpha && pH0_FV > alpha) || (pH0_FA > alpha && pH0_FV < alpha)
                    pH0 = pH0_FA;
                else
                    pH0 = pH0_FV;
                end
                % NOTE: It is better to base 'pH0' probability on Pillai's
                % 'U' value, given it's robustness for samples with equal
                % variances in 'Y', but Wilk's 'A' is more conservative.
                
                
                % If 'pH0' rejects H0, p univariate F tests must be made on
                % each variable.
                % ---------------------------------------------------------
                
                % Model fit params to measure the relationshi between predictors
                % and predicates.
                R2 = det(T\H); % Coficient of mutiple determination.
                nu2A = 1 - A;
                nu2theta = theta;
                Alh = (U/s)/(1 + U/s);
            end
            
            
            % --- Recursive subset selection of 'r' among a pool of 'k' 'X's,
            % based on R2, S2 and Cp (from Mallows) criteria.
            for k = 1:q
                r = 1;
                R2r = trace(T\H)/p;
                S2r = det(E/(n - r));
                
                treshold = ((n-r)/(n-k))^p;
                Cpr = det(E\E); % Must be |Ek^-1*Er|
                % NOTE: It must reach: Cpr <= [(n-r)/(n-k)]^p, for r X among k.
            end
            
            
            output = struct(...
                'X',X,...
                'Y',Y,...
                'Y_',Y_,...
                'e',e,...
                'B_',B_,...
                'n',n,...
                'p',p,...
                'q',q,...
                'm',m,...
                'N',N,...
                's',s,...
                'T',T,...
                'H',H,...
                'E',E,...
                'MSr',MSr,...
                'MSe',MSe,...
                'Se',Se,...
                'S',S,...
                'F',F,...
                'A',A,...
                'theta',theta,...
                'V',V,...
                'U',U,...
                'R2',R2,...
                'nu2A',nu2A,...
                'nu2theta',nu2theta,...
                'Alh',Alh,...
                'k',k,...
                'R2r',R2r,...
                'S2r',S2r,...
                'Cpr',Cpr,...
                'pH0',pH0);
            
        else
            error('Invalid inputs.');
        end
    catch ERR
        error(['+libml.ra: ',ERR.message]);
    end
end

            %{
            % Params.
            sig_2 = SSe/vE;
            S = sqrt(MSe); % Standard error of the regression.
            R2 = SSr/SSt;
            R2adj = 1 - (vT/vE)*(1 - R2);
            
            % Standardized.
            e_stdi = e./S;
            % Studentized.
            H_e = X/(X'*X)*X';
            
            Cov_e = sig_2*(eye(size(H_e,1))-H_e);
            %e_rj = e./sqrt(sig_2*(1 - diag(H)));
            e_studi = e./sqrt(diag(Cov_e));
            % PRESS.
            PRESS = sum((e./(1 - diag(H_e))).^2);
            R2pred = 1 - PRESS/SSt;
            Sr = ((n-k-1)*MSe - (e.^2)./(1-diag(H_e)))./(n-k-2);
            e_rstudi = e./sqrt(Sr.*(1 - diag(H_e)));
            p = sum(diag(H_e));
            e_leverage = ((e_studi.^2).*diag(H_e))./(1-diag(H_e))/p;
            
            % Residual plot.
            %stem(e);
            
            
            % --- Significance and CIs for the coeficients.
            tB_j = zeros(size(B_));
            SSrB_j = zeros(size(B_));
            C = inv(X'*X);
            CIB_j = zeros(size(B_,1),2);
            stdB_j = sqrt(sig_2*diag(C));
            for i = 1:size(B_,1) % Beginning from 2 to avoid the constant coeficient.
                if size(B_,1) < 2, break; end
                
                if i ~= 1
                    % Extra sum of squares.
                    Xj = X(:,1:size(X,2)~=i);
                    XB_j = (Xj'*Xj)\Xj'*Y;
                    SSrB_j(i) = SSr - XB_j'*Xj'*Y + sum(Y)^2/n;
                end
                
                % Partial F test or t test for one coeficient.
                tB_j(i) = B_(i)/sqrt(sig_2*C(i,i));
            end
            pB_j = tpdf(tB_j,n-k-1);
            SSrB_j(1) = SSr - sum(SSrB_j);
            
            t = 0; p = 1;
            while p > 0.05, t = t + 0.01; p = tpdf(t,n-k-1); end
            CIB_j(:,1) = B_ - t*sqrt(sig_2*diag(C));
            CIB_j(:,2) = B_ + t*sqrt(sig_2*diag(C));
            
            % --- New response predictions.
            Ypred = zeros(size(Y,1),2);
            for i = 1:size(Y,1)
                % CI for future predictions.
                Ypred(i,1) = Y_(i) - t*sqrt(sig_2*(1+X(i,:)*C*X(i,:)'));
                Ypred(i,2) = Y_(i) + t*sqrt(sig_2*(1+X(i,:)*C*X(i,:)'));
                Ypred_exp = 'Ypred(i,2) = Y_(i) + t*sqrt(sig_2*(1+X(i,:)*C*X(i,:)''));';
                
                % CI for mean response.
                Y_mean(i,1) = Y_(i) - t*sqrt(sig_2*(X(i,:)*C*X(i,:)'));
                Y_mean(i,2) = Y_(i) + t*sqrt(sig_2*(X(i,:)*C*X(i,:)'));
                Y_mean_exp = 'Y_mean(i,2) = Y_(i) + t*sqrt(sig_2*(X(i,:)*C*X(i,:)''));';
            end
            
            adequacy = sum(Y_ > Ypred(:,1) & Y_ < Ypred(:,2));
            %}
