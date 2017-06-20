function [EXT, output] = glossary(obj,varargin)

% Glossary function.


    % =======================> PREAMBLE <=======================================
    
    % --- Macro Definitions.
    % Success exit status.
    EXT = true;
    
    % --- Variable declarations.
    % Output.
    output = [];
    % Defaut return;
    ret = [];
    
    
    % =======================> FUNCTION CODE <==================================
    
    try
        % Independent commands acts only on the fist argument.
        switch varargin{1}
            case 'adduser'
                % Create and initialyse a new user's parent folder.
                
                % First came the user name followed by the path to his folder.
                if size(varargin,2) > 2 && ischar(varargin{2}) && ischar(varargin{3})
                    % Pick user name and path to folder.
                    usr = user;
                    uname = varargin{2};
                    pathh = varargin{3};
                    
                    if isempty(uname)
                        error('adduser: User name is missing.');
                    end
                    
                    if ~exist(pathh,'dir')
                        error(['adduser: Unnexistent path ''' pathh '''.']);
                    end
                    
                    if strcmp(pathh,obj.users.rdir)
                        errorr('Can''t overwrite root''s folder.');
                    end
                    
                    % User data initialization.
                    usr.uid = uname;
                    usr.ukey = '';
                    
                    k = what(pathh);
                    usr.udir = fullfile(k.path,uname);
                    usr.ufile = '';
                    usr.rdir = obj.users.rdir;
                    
                    % Try to create an user entry in root's 'users.txt' file.
                    if user.putusr(usr)
                        % Success initialization.
                        screen(['Successfull initialization of user folder ''.../' usr.uid '/''.'],'');
                    else
                        error(['adduser: User entry ''.../' usr.uid '/'' ready exist and can''t be overwritten.']);
                    end
                    
                    % Return.
                    ret = usr;
                else
                    error('adduser: User name is missing or has incorrect path.');
                end
            case 'clrlog'
                % Clear the project's 'log' file.
                
                if obj.log.clear && obj.log.create;
                    screen('Log file cleanned.','');
                    
                    % Return.
                    ret = EXT;
                else
                    error('Couldn''t clear ''log'' file.');
                end
            case 'interact'
                % Interactive mode (rustic interface).
                
                % Control criterium.
                ctrl = 1;
                
                % Adjust.
                k = {obj};
                
                % Input string.
                str = screen('Type ''exit'' or ''Ctrl^C'' to quit and ''-h'' for help.','');
                while ctrl
                    try
                        % Getting input string from user.
                        str = input([obj.software.program ' $ '],'s');
                        
                        args = regexp(strtrim(str),' ','split');
                        if any(strcmp(args{1},{'exit' '.' '..'}))
                            ctrl = 0;
                        elseif strcmp(args{1},'')
                            
                        else
                            % MANY ERRORS!!
                            k = no_flag(k{1},args{:});
                        end
                    catch ERR
                        k = {obj};
                        obj.log.note('no_flag: interact:',ERR.message);
                    end
                end
                
                % Return.
                ret = k{1};
            case 'login'
                % Load user data and log.
                
                % First came the user name followed by his password.
                if size(varargin,2) > 2 && ischar(varargin{2}) && ischar(varargin{3})
                    % Pick user name and path to folder.
                    uname = varargin{2};
                    passwd = varargin{3};
                    
                    if isempty(uname)
                        error('login: User name is missing.');
                    end
                    
                    % Get user data.
                    [ext, usr] = user.getusr(obj.users.rdir,uname);
                    
                    if ext
                        % Password verification.
                        if ~strcmp(usr.ukey,passwd)
                            error('login: Invalid password.');
                        else
                            % Transferring user data.
                            obj.log.note('login: ',['User changed to ''' usr.uid ''' at ' mat2str(clock) '.'],'off');
                            obj.log.terminate;
                            obj.users = usr;
                            
                            % Actualizing 'log'.
                            obj.log.usr = usr.uid;
                            obj.log.ldir = fullfile(usr.udir,'log');
                            obj.log.create;
                            
                            screen(['Loged on user ''' uname '''.'],'');
                        end
                    else
                        error(['login: Unnexistent user ''' uname '''.']);
                    end
                    
                    % Return.
                    ret = obj;
                else
                    error('login: User name is missing or has incorrect password.');
                end
            case 'mcbdolly'
                % Auto clonning program.
                
                %rsync...
            case 'meta'
                % To do meta thigs like internal redirections.
                
            case 'new'
                % Create new user's configuration file.
                
                if size(varargin,2) > 1 && ischar(varargin{2})
                    [pathh, fl, ext] = fileparts(varargin{2});
                    
                    if ~isempty(varargin{2}) && (isempty(pathh) ...
                            || (exist(pathh,'dir') && ~strcmp(pathh,'/'))) && ~isempty(fl)
                        file = fullfile(pathh,[fl ext]);
                        edit(file);
                    else
                        error('new: Unnexistent path or missing filename.');
                    end
                    
                    % Return.
                    ret = EXT;
                else
                    error('new: File name is missing or incorrect.');
                end
            case 'rmuser'
                % Remove user entry.
                
                % First came the user name followed by his password.
                if size(varargin,2) > 2 && ischar(varargin{2}) && ischar(varargin{3})
                    % Pick user name and path to folder.
                    uname = varargin{2};
                    passwd = varargin{3};
                    
                    if isempty(uname)
                        error('rmuser: User name is missing.');
                    end
                    
                    % Get user data.
                    [ext, usr] = user.getusr(obj.users.rdir,uname);
                    
                    if ext
                        % Password verification.
                        if ~strcmp(usr.ukey,passwd)
                            error('rmuser: Invalid password.');
                        elseif user.rmusr(usr)
                            screen(['User ''' uname ''' was removed.'],'');
                        end
                    else
                        error(['rmuser: Unnexistent user ''' uname '''.']);
                    end
                    
                    % Return.
                    ret = obj;
                else
                    error('rmuser: User name is missing or has incorrect password.');
                end
            case 'save'
                % Save project's object.
                
                if size(varargin,2) > 1 && ischar(varargin{2})
                    [pathh, fl, ext] = fileparts(varargin{2});
                    
                    if ~isempty(varargin{2}) && (isempty(pathh) || (exist(pathh,'dir') && ~strcmp(pathh,'/'))) ...
                            && ~isempty(fl) && (strcmp(ext,'.mat') || strcmp(ext,'.cfg'))
                        
                        file = fullfile(pathh,[fl ext]);
                        if strcmp(ext,'.mat')
                            % Write in native file type.
                            
                            % Update object's configuration file.
                            obj.users.ufile = file;
                            
                            % Saving.
                            save(file,'obj');
                        else
                            % Write in text file type.
                            
                            % Update object's configuration file.
                            obj.users.ufile = file;
                            
                            [fl, msg] = fopen(file,'w');
                            if ~isempty(msg), error(['Can''t save file ''' file '''.']); end
                            
                            % Write file. FIX!!
                            lines = filewrapper(obj);
                            fprintf(fl,['<!DOCTYPE ' obj.software.program 'ml>\n\n']);
                            fprintf(fl,['<' obj.software.program '>\n']);
                            for ii = 1:size(lines,1)
                                fprintf(fl,'%s\n',lines{ii});
                            end
                            fprintf(fl,['</' obj.software.program '>\n']);
                            fclose(fl);
                        end
                        
                        screen(['File successfully saved in ''' file '''.'],'');
                    elseif ~isempty(varargin{2}) && strcmp(varargin{2},'-user')
                        if strcmp(obj.commons.udir,' '), obj.commons.udir = ''; end
                        [~, ret] = glossary(obj,'save',fullfile(obj.commons.udir,'objfile.mat'));
                        [~, ret] = glossary(obj,'save',fullfile(obj.commons.udir,['configfile.' obj.meta.extension]));
                        
                        screen('File successfully saved in user''s parent folder.');
                    else
                        error('save: Unnexistent path or incompatible file type.');
                    end
                else
                    error('save: File name is missing or incorrect.');
                end
            case 'savedata'
                % Save project's data.
                
                if size(varargin,2) > 1 && ischar(varargin{2})
                    [pathh, fl, ext] = fileparts(varargin{2});
                    
                    if ~isempty(varargin{2}) && (isempty(pathh) || (exist(pathh,'dir') && ~strcmp(pathh,'/'))) ...
                            && ~isempty(fl) && (strcmp(ext,'.mat') || strcmp(ext,'.csv'))
                        
                        file = fullfile(pathh,[fl ext]);
                        if strcmp(ext,'.mat')
                            % Write in native file type.
                            
                            % Update object's data file.
                            obj.info.datafile = file;
                            data = obj.data;
                            
                            % Saving.
                            save(file,'data');
                        else
                            % Write in text '.csv' file type.
                            
                            % Update object's data file.
                            obj.info.datafile = file;
                            
                            [fl, msg] = fopen(file,'w');
                            if ~isempty(msg), error(['Can''t save file ''' file '''.']); end
                            % Write '.csv' format.
                            
                            fclose(fl);
                        end
                        
                        screen(['File successfully saved in ''' file '''.'],'');
                    elseif ~isempty(varargin{2}) && strcmp(varargin{2},'-user')
                        if strcmp(obj.commons.udir,' '), obj.commons.udir = ''; end
                        [~, ret] = glossary(obj,'savedata',fullfile(obj.commons.udir,'datafile.mat'));
                        
                        screen('File successfully saved in user''s parent folder.');
                    else
                        error('save: Unnexistent path or incompatible file type.');
                    end
                else
                    error('save: File name is missing or incorrect.');
                end
            case 'server'
                screen('Internal command ''server'' is under development.','');
                
                % Return.
                ret = EXT;
            case 'version'
                screen([obj.software.program ' version: ' obj.software.version '-' computer],'');
                
                % Return.
                ret = EXT;
            otherwise
                error(['''' varargin{1} ''' is a unknown command or a unnexistent file.']);
        end
        
        % Returning.
        output = ret;
    catch ERR
        EXT = ~EXT;
        output = [];
        obj.log.note('glossary: ',ERR.message);
    end
end
