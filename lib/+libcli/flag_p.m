function H = flag_p(obj,varargin)

% Make PCA on inputs that can be:
%   A matrix (variables per columns);
%   An object specified in a configuration file;
%   A cell with a matrix and a option ('cov' or 'corr') inside;
%   A struct or an 'astratto' object data.


    % Setting return status.
    EXT = 0;
    
    % Initialy, 'H' is set to the exit status 'exit_stt', that is, by default
    % the success value '0', changing inside the function, if needed.
    H = cell(nargin-1,1);
    for ii = 1:nargin-1
        H{ii} = EXT;
        try
            % Feel the input.
            if isnumeric(varargin{ii})
                % PCA on a input matrix.
                disp('ah')
                [PC EigVals Escr ExpVar T2] = pcamkr(varargin{ii});
            elseif ischar(varargin{ii}) && exist(varargin{ii},'file')
                % PCA on a struct or object loaded from a configuration file.
                disp('aobb');
            elseif iscell(varargin{ii})
                % PCA on a matrix inside a cell with aditional options.
                varargin{ii}{1}
                [PC EigVals Escr ExpVar T2] = pcamkr(varargin{ii}{1},varargin{ii}{2});
            elseif isstruct(varargin{ii}) || isa(varargin{ii},'astratto')
                % PCA on a struct or object data.
                disp('foiii');
            else
                error('Invalid type or number of input arguments.');
            end
            
            H{ii} = obj;
        catch ERR
            H{ii} = ~EXT;
            ncl_err('flag_p: ',ERR.message);
        end
    end
end
