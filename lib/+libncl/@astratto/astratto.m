classdef astratto < libbase.modulo

% General model data object.


    properties
        info
        data
        statistics
        parameters
        objects
        defaults
    end
    
    methods
        % --- Object constructor.
        function obj = astratto(varargin)
            try
                if nargin
                    % Library import.
                    import('libflmgr.*');
                    
                    % >>> NOTE: 'astratto' models can't be nested. <<<
                    % Counting total number of projects.
                    num = 0; position = 0;
                    lines = fileopener(varargin{:},'-m','<models>','</models>');
                    for ii = 1:nargin, num = num + size(lines{ii},2); end
                    
                    % Preallocating memory.
                    obj(max(1,num)) = libncl.astratto;
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
                                obj(position).id = ['ato-' num(end:-1:end-5)];
                            end
                        end
                    end
                end
            catch ERR
                error(['+libncl.@astratto: ',ERR.message]);
            end
        end
        
        % --- Member functions.
        % Handle objects don't need return arguments.
        setinfo(obj,varargin)
        setdata(obj,varargin)
        setobj(obj,varargin)
        setstats(obj,varargin)
        output = designer(obj,full_dsgn,design,param)
    end
    
    methods (Static)
        output = condition(str,var)
        output = masker(full_dsgn,desired_dsgn)
        output = analyser(varargin);
    end
end
