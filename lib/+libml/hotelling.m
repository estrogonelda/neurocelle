function [T2, pH0, lambda, R2] = hotelling(mtx1,mtx2,mn,option,alpha)

% Hotelling's T2 test.


    % vsd
    try
        % Inputs verification.
        if ~isempty(mtx1) && ((~isempty(mtx2) && size(mtx1,1) ~= size(mtx2,1)) ...
                || (isempty(mtx2) && isempty(mn)) )
            error('Invalid inputs.');
        end
        
        % General parameters.
        p = size(mtx1,2);
        n1 = size(mtx1,1);
        S1 = cov(mtx1);
        mn1 = mean(mtx1);
        v = n1 - 1;
        R2 = [];
        lambda = [];
        
        % Two sample mean comparison.
        if ~isempty(mtx2) && ~strcmp(option,'paired')
            n2 = size(mtx2,1);
            S2 = cov(mtx2);
            mn2 = mean(mtx2);
            v = n1 + n2 - 2;
            
            if n1 + n2 - 2 <= p
                error('Too few elements in sample.');
            end
            
            % Pooled covariance matrix.
            Spl = (1/(n1 + n2 - 2))*((n1 - 1)*S1 + (n2 - 1)*S2); 
        end
        
        
        % Returnings.
        if strcmp(option,'paired')
            % Paired sample comparisons.
            
            % Distance matrix.
            d = mtx1 - mtx2;
            mnd = mean(d);
            Sd = zeros(p);
            
            for ii = 1:n1
                Sd = Sd + (d(ii,:) - mnd)'*(d(ii,:) - mnd);
            end
            Sd = (1/(n1 - 1))*Sd;
            
            % Hotelling's T2 coeficient.
            T2 = n1*mnd/Sd*mnd';
            
            % Wilk's lambda coeficient to multivariate association, realted
            % to T2.
            lambda = v/(T2 + v);
            
            
            % Squared multiple correlation, related to T2.
            R2 = T2/(T2 + v);
        else
            if isempty(mtx2)
                % One sample test.
                T2 = n1*(mn1 - mn)/S1*(mn1 - mn)';
                
                % In one sample, there is a perfect multivariate association
                % between the sample and itself.
                lambda = 1;
                R2 = 1;
            else
                % Two sample test.
                
                % Hotelling's T2 coeficient.
                T2 = (n1*n2/(n1+n2))*(mn1 - mn2)/Spl*(mn1 - mn2)';
                
                % Wilk's lambda coeficient to multivariate association, realted
                % to T2.
                lambda = v/(T2 + v);
                
                % Squared multiple correlation, related to T2.
                R2 = T2/(T2 + v);
            end
        end
        
        
        if isempty(alpha), alpha = 0.05; end
        v1 = p;
        v2 = v - p + 1;
        F = (v2/(v*p))*T2;
        
        % Final 'pH0' probability.
        pH0 = 1 - fcdf(F,v1,v2);
    catch ERR
        error(['+libml.hotelling: ' ERR.message]);
    end
end
