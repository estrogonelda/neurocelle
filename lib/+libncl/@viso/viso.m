classdef viso < libbase.modulo
    %VISO Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        info
        layout
        actions
        defaults
    end
    
    methods
        % --- Object constructor.
        function obj = viso(varargin)
            try
                if nargin
                    % Library import.
                    import('libflmgr.*');
                    
                    % >>> NOTE: 'viso' models can't be nested. <<<
                    % Counting total number of projects.
                    num = 0; position = 0;
                    lines = fileopener(varargin{:},'-m','<interfaces>','</interfaces>');
                    for ii = 1:nargin, num = num + size(lines{ii},2); end
                    
                    % Preallocating memory.
                    obj(max(1,num)) = libncl.viso;
                    for ii = 1:nargin
                        % Modules must be initialized with configuration files or param cells.
                        if (ischar(varargin{ii}) && exist(varargin{ii},'file') == 2 ...
                                && any(strcmp(regexp(varargin{ii},'\.','split'),'conf'))) ...
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
                                obj(position).id = ['vso-' num(end:-1:end-5)];
                            end
                        end
                    end
                end
            catch ERR
                error(['+libncl.@viso: ',ERR.message]);
            end
        end
        
        % --- Member functions.
        % Handle objects don't need return arguments.
        config(obj,varargin)
        validate(obj,varargin);
    end
end
