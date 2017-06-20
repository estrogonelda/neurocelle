classdef progetto < libbase.modulo

% +LIBNCL.@PROGETTO - Top most process object.


    properties
        % User specific data.
        info
        defaults
        models
        simulations
        UIs
        reports
        drawings
    end
    
    methods
        function obj = progetto(varargin)
            try
                if nargin
                    % Library import.
                    import('libflmgr.*');
                    
                    % >>> NOTE: 'progetto' models can't be nested. <<<
                    % Counting total number of projects.
                    num = 0; position = 0;
                    lines = fileopener(varargin{:},'-m','<projects>','</projects>');
                    for ii = 1:nargin, num = num + size(lines{ii},2); end
                    
                    % Preallocating memory.
                    obj(max(1,num)) = libncl.progetto;
                    for ii = 1:nargin
                        % Modules must be initialized with configuration files or param cells.
                        if (ischar(varargin{ii}) && exist(varargin{ii},'file') == 2 ...
                                && (any(strcmp(regexp(varargin{ii},'\.','split'),'conf')) ...
                                || any(strcmp(regexp(varargin{ii},'\.','split'),'xml'))) ) ...
                                || iscell(lines{ii})
                            % Multiple initialization.
                            for jj = 1:size(lines{ii},2)
                                position = position + 1;
                                
                                % Ordinary pre configurations.
                                obj(position).config(lines{ii}(:,jj));
                                
                                % Validation of properties' values.
                                obj(position).validate;
                                
                                % Module indentity initialization.
                                num = num2str(round(1e8*rand));
                                obj(position).id = ['pgt-' num(end:-1:end-5)];
                            end
                        end
                    end
                end
            catch ERR
                error(['+libncl.@progetto: ' ERR.message]);
            end
        end
        
        % --- Member functions.
    end
end
