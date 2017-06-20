classdef vero < libbase.modulo
    %VERO Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        % --- Object constructor.
        function obj = vero(varargin)
            try
                if nargin
                    % Library import.
                    import('libflmgr.*');
                    
                    % >>> NOTE: 'vero' models can't be nested. <<<
                    % Counting total number of projects.
                    num = 0; position = 0;
                    lines = fileopener(varargin{:},'-m','<simulations>','</simulations>');
                    for ii = 1:nargin, num = num + size(lines{ii},2); end
                    
                    % Preallocating memory.
                    obj(max(1,num)) = libncl.vero;
                    for ii = 1:nargin
                        % Modules must be initialized with configuration files or param cells.
                        if (ischar(varargin{ii}) && exist(varargin{ii},'file') == 2 ...
                                && any(strcmp(regexp(varargin{ii},'\.','split'),'conf'))) ...
                                || iscell(lines{ii})
                            % Multiple initialization.
                            for jj = 1:size(lines{ii},2)
                                position = position + 1;
                                
                                % Ordinary pre configurations and post-validation
                                % of object's properties values.
                                obj(position).config(lines{ii}(:,jj));
                                
                                % Validation of properties' values.
                                obj(position).validate;
                                
                                % Module indentity initialization.
                                num = num2str(round(1e7*rand));
                                obj(position).id = ['vro-' num(end:-1:end-4)];
                            end
                        end
                    end
                end
            catch ERR
                error(['+libncl.@vero: ',ERR.message]);
            end
        end
        
        % --- Member functions.
    end
end
