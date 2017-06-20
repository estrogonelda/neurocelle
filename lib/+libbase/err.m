classdef err < event.EventData & handle

% ERR Summary of this class goes here
%   Detailed explanation goes here


    properties
        usr
        ldir
        errsrc
        errmsg
        defstr
        verbosity
        show_sign
        listener
    end
    
    events
        wood
    end
    
    methods
        % --- Constructor function.
        function obj = err(varargin)
            try
                if nargin
                    % Library import.
                    import('libbase.*');
                    
                    if isa(varargin{1},'user')
                        obj.usr = varargin{1}.uid;
                        obj.ldir = fullfile(varargin{1}.udir,'log');
                        obj.errsrc = '';
                        obj.errmsg = '';
                        obj.defstr = '';
                        obj.verbosity = '';
                        obj.show_sign = 'ferr';
                    else
                        error('Input must be an ''user'' object. Can''t initialize ''err'' object.');
                    end
                end
            catch ERR
                error(['+libbase.@err: ' ERR.message]);
            end
            
            addlistener(obj,'wood',@propagate);
        end
        
        
        % --- Member functions.
        function status = clear(obj)
            % Failure return status.
            status = false;
            
            obj.errsrc = 'clear';
            obj.errmsg = '';
            
            % Propagate error action.
            notify(obj,'wood');
            
            % Success return status.
            status = ~status;
        end
        
        function status = create(obj)
            % Failure return status.
            status = false;
            
            obj.errsrc = 'create';
            obj.errmsg = sprintf('\t\t\t\t\tRunned in %s, by %s.\n',mat2str(clock),obj.usr);
            %obj.show_sign = '';
            
            % Propagate error action.
            notify(obj,'wood');
            
            % Success return status.
            status = ~status;
        end
        
        function status = begin(obj,prj)
            % Failure return status.
            status = false;
            
            obj.errsrc = 'begin';
            obj.errmsg = [empty_width(standard_width,'=') '\n' ...
                sprintf('\t\t\t\t\t<-- ''%s'' errors -->\n',prj)];
            %obj.show_sign = '';
            
            % Propagate error action.
            notify(obj,'wood');
            
            % Success return status.
            status = ~status;
        end
        
        function status = end(obj,prj)
            % Library import.
            import('libflmgr.*');
            
            % Failure return status.
            status = false;
            
            obj.errsrc = 'end';
            obj.errmsg = [sprintf('Finished at %s.\n',mat2str(clock)) ...
                empty_width(standard_width,'=') '\n'];
            %obj.show_sign = '';
            
            % Propagate error action.
            notify(obj,'wood');
            
            % Success return status.
            status = ~status;
        end
        
        function status = terminate(obj)
            % Failure return status.
            status = false;
            
            obj.errsrc = 'terminate';
            obj.errmsg = sprintf('Finished run in %s!\n',mat2str(clock));
            %obj.show_sign = '';
            
            % Propagate error action.
            notify(obj,'wood');
            
            % Success return status.
            status = ~status;
        end
        
        function status = note(obj,varargin)
            
            % Failure return status.
            status = false;
            
            % Analysing error context.
            switch nargin-1
                case 1
                    obj.errsrc = varargin{1};
                case 2
                    obj.errsrc = varargin{1};
                    obj.errmsg = [obj.errsrc varargin{2}];
                case 3
                    obj.errsrc = varargin{1};
                    obj.errmsg = [obj.errsrc varargin{2}];
                    obj.show_sign = varargin{3};
                otherwise
                    obj.errmsg = 'Unknow error source.';
            end
            
            % Propagate error action.
            notify(obj,'wood');
            
            % Success return status.
            status = ~status;
        end
    end
end


% --- Class related function to propagate error actions.
function propagate(obj,event)

    % Library import.
    import('libflmgr.*');
    
    % Decide.
    opt = '';
    if strcmp(obj.errsrc,'clear')
        opt = 'w';
    else
        opt = 'a';
    end
    
    % Concatenate on a run entry on log file.
    [fl, msg] = fopen(fullfile(obj.ldir,'err.log'),opt);
    if ~isempty(msg)
        % In the screen.
        screen([msg ' ''err.log''.'],obj.show_sign,obj.verbosity);
    elseif opt == 'w'
        fclose(fl);
    else
        % Write on log file.
        fprintf(fl,'%s\n',obj.errmsg);
        fclose(fl);
    end
    
    % Send error message to standard error.
    if ~any(strcmp({'clear','create','begin','end','terminate','note'},obj.errsrc))
        screen(obj.errmsg,obj.show_sign,obj.verbosity);
    end
end
