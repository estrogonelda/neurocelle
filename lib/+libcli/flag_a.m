function output = flag_a(obj,varargin)

% ---------------------------> FLAG_A help <------------------------------------
% FLAG_A - General statistics flag.
%
% Arguments usage:
%   
%   If no object argument is supplied, the statistics are returned on the
%   default object, otherwise it will be returned on the supplied one.
%   
% See also: no_flag.
%
% Author: José Leonel L. Buzzo.
% Last Modified: 11/06/2016.
% ------------------------------------------------------------------------------


    % =======================> PREAMBLE <=======================================
    
    % --- Macro Definitions.
    % Success exit status.
    %EXT = 0;
    
    % --- Library import.
    import('libcli.*');
    import('libflmgr.*');
    import('libncl.*');
    
    % --- Variable declarations.
    % Output declaration.
    output = [];
    
    % Control param.
    ret = [];
    
    
    % =======================> FUNCTION CODE <==================================
    
    try
        % Counting and qualifing input arguments.
        argcount = flagwrapper(varargin{:});
        
        % Flag's decision tree.
        for ii = 1:4
            k = find(argcount == ii);
            ksz = size(k,1);
            if ~ksz, continue; end
            
            switch ii
                case 1
                    % Numeric data.
                    switch ksz
                        case 1
                            % One input matrix, unsupervided learnning.
                            if ~isempty(varargin{k})
                                ret = obj;
                                disp('Unsupervised');
                            else
                                error('Empty matrix.');
                            end
                        case 2
                            % Two input matrix, supervided learnning.
                            if size(varargin{k(1)},1) == size(varargin{k(2)},1) ...
                                    && ~isempty(varargin{k(1)}) && ~isempty(varargin{k(2)})
                                obj.projects.models.setdata(varargin{1:2});
                                obj.projects.models.setobj;
                                obj.projects.models.setstats;
                                
                                ret = obj;
                            else
                                error('Input matrixes are empty or have diferent sizes.');
                            end
                        otherwise
                            error('Too many input arguments.');
                    end
                case 2
                    % Character data.
                    
                    % Elapsed time.
                    time = tic;
                    tm = 0;
                    
                    % Processing file input.
                    if loadprj(obj,varargin{k})
                        % Make a backup of the projects.
                        try
                            projects = obj.projects;
                            save(fullfile(obj.users.udir,'tmp',['bkp_' obj.users.uid]),'projects');
                        catch ERR
                            error(['Couldn''t save project file ''bkp_' obj.users.uid ''': ' ERR.message]);
                        end
                        
                        % User feedback.
                        screen(['Projects'' loadings complete in ' num2str(toc(time)-tm) ' seconds.'],'',obj.log.verbosity);
                        tm = toc(time);
                        
                        % After load the models by configuration files, they
                        % must be runned.
                        for jj = 1:numel(obj.projects)
                            % Identifying current project.
                            if ~isempty(obj.projects(jj).info)
                                screen(['Project ' num2str(jj) '/' num2str(numel(obj.projects)) ': ' obj.projects(jj).info.title '.'],'',obj.log.verbosity);
                            end
                            
                            for kk = 1:numel(obj.projects(jj).models)
                                % Identifying current model.
                                if ~isempty(obj.projects(jj).models(kk).info)
                                    screen(['Model ' num2str(kk) '/' num2str(numel(obj.projects(jj).models)) ': ' obj.projects(jj).models(kk).info.problem '.'],'',obj.log.verbosity);
                                end
                                
                                if ~isempty(obj.projects(jj).models(kk).id) && ~isempty(obj.projects(jj).models(kk).data.id)
                                    % Running model.
                                    obj.projects(jj).models(kk).setobj('');
                                else
                                    % Empty model or missing data.
                                    screen(['Empty model or missing data in project ' num2str(jj) ', model ' num2str(kk) '.'],'',obj.log.verbosity);
                                end
                            end
                        end
                    else
                        screen(['Couldn''t load project ''' varargin{k} '''.'],'',obj.log.verbosity);
                    end
                    
                    % User feedback.
                    screen(['Projects'' processes complete in ' num2str(toc(time)-tm) ' seconds.'],'',obj.log.verbosity);
                    %tm = toc(time);
                    
                    % Saving and compressing files.
                    for jj = 1:numel(obj.projects)
                        if ~isempty(obj.projects(jj).info.title)
                            projects = obj.projects(jj);
                            save(obj.projects(jj).info.title,'projects');
                            %['tar cf ' obj.projects(jj).info.title '.tar ' obj.projects(jj).info.title '.mat']
                            system(['tar cf ' obj.projects(jj).info.title '.tar ' obj.projects(jj).info.title '.mat']);
                        end
                    end
                    
                    ret = obj;
                case 3
                    % Cell data.
                    
                case 4
                    % Object data.
                    
                    % Processing object input.
                    if size(k,1) == 2
                        % Two input objects.
                        ret(2) = varargin{k(2)};
                        ret(1) = varargin{k(1)};
                    elseif size(k,1) == 1
                        % One input object.
                        ret = varargin{k};
                    else
                        error('Too many input arguments.');
                    end
                otherwise
            end
        end
        
        % Return.
        output = ret;
    catch ERR
        obj.log.note('flag_a: ',ERR.message);
    end
end


function EXT = loadprj(obj,varargin)

% LOADPRJ - Load the project's fields with it's modules.


    % --- Library import.
    import('libcli.*');
    import('libflmgr.*');
    import('libncl.*');
    
    % Default failure value for exit status.
    EXT = false;
    
    if nargin == 1
        % Allocate empty project.
        obj.modules = cat(1,obj.modules,obj.loadmod(obj.software.proj_manager));
        if ~isempty(obj.modules{end})
            obj.projects = cat(1,obj.projects,obj.modules{end});
        else
            return;
        end
    else
        count = false(nargin-1,1);
        for ii = 1:nargin-1
            if exist(varargin{ii},'file') == 2
                count(ii) = true;
            end
        end
        
        % Insert new 'progetto' modulo to modules' list. Must insert the
        % user's name in the 'meta' 'user' field.
        if any(count) && isempty(obj.loadmod('-N',obj.software.proj_manager))
            obj.modules = cat(1,obj.modules,{feval(obj.software.proj_manager,varargin{count})});
            obj.projects = obj.modules{end};
        elseif any(count)
            % Concatenate.
            position = obj.loadmod('-N',obj.software.proj_manager);
            ob = feval(obj.software.proj_manager,varargin{count});
            obj.modules{position}(end+1:end+size(ob,2)) = ob;
            obj.projects = obj.modules{position};
        else
            return;
        end
    end
    
    % Return.
    EXT = ~EXT;
end
