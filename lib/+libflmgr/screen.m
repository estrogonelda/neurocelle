function out = screen(varargin)

% ---------------------------> SCREEN help <-----------------------------------
% SCREEN - SCREEN display messages on the screen in neurocelle programs.
%
% Note: screen(str,[]) prints an empty line.
%
% Author: José Leonel L. Buzzo.
% Last Modified: 11/01/2016.
% -----------------------------------------------------------------------------


    % =======================> PREAMBLE <======================================
    
    % --- Library importations ---
    import('libflmgr.*');
    
    % --- Macro Definitions ---
    % -------------------------
    
    % --- Variable declarations ---
    str = '';
    opt = '';
    dsp = '';
    cmd_tag = '';
    
    standard_width = 79;
    standard_indent = 4;
    out = printWidth(standard_width,' '); % An empty line with 81 width.
    out_fcn = 'fprintf';
    out_fcn_param = 1; % Standard output file identifier.
    out_type = '';
    
    
    % =======================> FUNCTION CODE <=================================
    
    if nargin == 1
        str = varargin{1};
    elseif nargin == 2 %&& ischar(varargin{2})
        str = varargin{1};
        opt = varargin{2};
    elseif nargin == 3 && ischar(varargin{3})
        str = varargin{1};
        opt = varargin{2};
        dsp = varargin{3};
    elseif nargin == 4 && ischar(varargin{3}) && ischar(varargin{4})
        str = varargin{1};
        opt = varargin{2};
        dsp = varargin{3};
        cmd_tag = varargin{4};
    else
        error('Invalid input arguments.');
    end
    
    
    try
        % Verifying 'str' and 'opt' type.
        if ~strcmp(opt,'var') && ~(ischar(str) || isnumeric(str))
            dsp = 'off';
        end
        
        % Choosing how to display messages in the screen.
        switch opt
            case 'res'
                % Result message.
                
                % Here, it comes indented 8 spaces and must supress 'cmd_tag'.
                %out_fcn = 'fprintf';
                %out_fcn_param = 1;
                out_type = printWidth(standard_indent,' ');
            case 'twrn'
                % True Warning message.
                
                out_fcn = 'warning';
                out_fcn_param = 'Control:parameterNotSymmetric';
                %out_type = 'Warning: ';
                
                % Subtracting 'Warning: ' string.
                standard_width = standard_width - 9;
            case 'fwrn'
                % Fake Warning message.
                
                %out_fcn = 'warning';
                out_fcn_param = 1;
                out_type = 'Warning: ';
            case 'terr'
                % True Error message.
                
                out_fcn = 'error';
                out_fcn_param = 0; % Trick code.
                %out_type = 'Error: ';
            case 'ferr'
                % Fake Error message.
                
                %out_fcn = 'error';
                out_fcn_param = 2; % Standard error file identifier.
                out_type = 'Error: ';
            case 'var'
                % Specia approach for variables display.
                
                %out_fcn = 'fprintf';
                %out_fcn_param = 1;
                %out_type = '';
                
                out = str;
            otherwise
                % Status Process message, with normal display.
        end
        
        
        % Assembling final message, except for a 'var' type.
        if strcmp(opt,'var') && ~strcmp(dsp,'off')
            % A built-in standart display function for general variables.
            disp(out);
        elseif ~strcmp(opt,'var')
            if isnumeric(str)
                out = num2str(str);
                
                k = '';
                sz = size([cmd_tag, out_type],2);
                for ii = 1:size(out,1)
                    k = cat(1,k,[cmd_tag, out_type]);
                end
                
                out = cat(2,k,out(:,1:min( standard_width - sz,size(out,2) )));
                if size(out,2) > standard_width, out = out(:,1:standard_width); end
            elseif ischar(str)
                k = regexp(str,'\\n','split');
                
                sz = size([cmd_tag, out_type],2);
                for ii = 1:numel(k)
                    out(ii,1:min( standard_width, size(k{ii},2) + sz )) ...
                        = [cmd_tag out_type k{ii}(1:min( standard_width - sz, size(k{ii},2) ))];
                end
            end
            
            out = strjoin(cellstr(out)','\n');
        end
        
        
        % Early return in some cases.
        if strcmp(dsp,'off') || strcmp(opt,'var'), return; end
    catch ERR
        % Error in 'opt'.
        out = '';
        out_fcn = 'fprintf';
        out_fcn_param = 1; % Standard output file identifier.
    end
    
    
    % Printing to the screen.
    if out_fcn_param
        feval(out_fcn,out_fcn_param,[out '\n']);
    else
        error(out);
    end
end
