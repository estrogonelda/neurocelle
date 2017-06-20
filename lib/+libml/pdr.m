function [pmtx, mn, sd] = pdr(varargin)

%PDR Summary of this function goes here
%   'opt' can be '' or '-m', for multivariate padronization.


    % Significance level.
    alpha = 0.05;
    
    try
        if isempty(varargin{1}) || ~isnumeric(varargin{1})
            error('invalid input matrix.');
        end
        
        mtx = varargin{1};
        pmtx = zeros(size(mtx));
        n = size(mtx,1);
        %p = size(mtx,2);
        
        % Choose to Standatize or de-Standartize 'mtx' with the flag '-d'.
        if nargin == 1
            % Standartize 'mtx'.
            mn = mean(mtx);
            sd = std(mtx);
            
            for ii = 1:n
                pmtx(ii,:) = (mtx(ii,:)-mn)./sd;
            end
        elseif nargin > 3 && any(strcmp(varargin{2},'-d')) && ...
                ~isempty(varargin{3}) && isnumeric(varargin{3}) && ...
                ~isempty(varargin{4}) && isnumeric(varargin{4})
            % De-standartize 'mtx'.
            mn = varargin{3};
            sd = varargin{4};
            
            for ii = 1:n
                pmtx(ii,:) = mtx(ii,:).*sd + mn;
            end
        else
            error('Invalid number of input arguments.');
        end
    catch ERR
        error(['pdr: ' ERR.message]);
    end
end
