function [EXT usr] = putusr(varargin)

% PUTUSR - Create or overwrite an user entry in the root's 'users.cfg' file.
%
% The inputs can be either:
%   An 'user' object;
%   Or the root's path (1st) with an 'user.uid' name (2nd) and a valid target
%   folder path (3rd) to initialize it's data after create or overwrite it's
%   entry.
%   
% To force overwrite, the flag '-f' must be supplied with the input
% arguments.


    % Library import.
    import('libbase.*');
    import('libflmgr.*');
    
    % Failure exit status.
    EXT = false;
    
    usr = user;
    
    
    try
        % Verifying input arguments.
        if nargin >= 1 && isa(varargin{1},'user') && exist(fullfile(varargin{1}.rdir,'usr','users.conf'),'file') == 2
            usr = varargin{1};
        elseif nargin == 2 && ischar(varargin{1}) && ~isempty(varargin{1}) && exist(fullfile(varargin{1},'usr','users.conf'),'file') ...
                && ischar(varargin{2})
            usr.uid = varargin{2};
            usr.ukey =  '';
            usr.udir = fullfile(pwd,usr.uid);
            usr.ufile = '';
            k = what(varargin{1});
            usr.rdir = k.path;
        elseif nargin > 2 && ischar(varargin{1}) && ~isempty(varargin{1}) && exist(fullfile(varargin{1},'usr','users.conf'),'file') ...
                && ischar(varargin{2}) && ischar(varargin{3}) && (exist(varargin{3},'dir') || strcmp(varargin{3},'-f'))
            usr.uid = varargin{2};
            usr.ukey =  '';
            if strcmp(varargin{3},'-f')
                usr.udir = fullfile(pwd,usr.uid);
            else
                k = what(varargin{3});
                usr.udir = fullfile(k.path,usr.uid);
            end
            usr.ufile = '';
            k = what(varargin{1});
            usr.rdir = k.path;
        else
            error('No valid inputs.');
        end
        
        % Entry validation to add a new user.
        % Function 'searchusr' must return 1 (failure status).
        if ~user.getusr(usr)
            [fl, msg] = fopen(fullfile(usr.rdir,'usr','users.conf'),'a');
            if ~isempty(msg), error('Can''t write user entry.'); end
            
            lines = filewrapper(usr);
            
            fprintf(fl,'<users>\n');
            for ii = 1:size(lines,1)
                fprintf(fl,'%s\n',lines{ii});
            end
            fprintf(fl,'</users>\n\n');
            
            fclose(fl);
            
            % Folder initializations.
            if ~exist(usr.udir,'dir')
                % Folder creation in fact.
                [stt msg] = mkdir(usr.udir);
                if ~isempty(msg)
                    error('Can''t initialyze user''s parent folder.');
                end
            end
            
            % Transfering some essential data to the user''s folder.
            stt = copyfile(fullfile(usr.rdir,'rpt'),fullfile(usr.udir,'rpt'));
            stt = mkdir(fullfile(usr.udir,'log'));
            stt = mkdir(fullfile(usr.udir,'cfg'));
            stt = copyfile(fullfile(usr.rdir,'cfg','default.conf'),fullfile(usr.udir,'cfg'));
            %!git init;
        elseif any(strcmp(varargin(:),'-f'))
            % Force entry overwriting.
            
            % Remove user entry and put it again, now actualized.
            if ~user.rmusr(usr) || ~user.putusr(usr);
                error('Can''t actualize user entry.');
            end
        else
            error(['User entry ''' usr.uid ''' already exist.'],'');
        end
        
        % Success exit status.
        EXT = ~EXT;
    catch ERR
        error(['+libbase.@user.putstr: ' ERR.message]);
    end
end
