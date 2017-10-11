function varargout = ncl(varargin)

% NCL - Generic interface handle for 'anima' objects.
%
% ---------------------------> NCL help <--------------------------------------
% NCL - Generic interface handle for 'anima' objects.
%
% Arguments usage:
%   
%   If nargout == 0 && nargin == 0,
%       open a new configuration file to edit;
%       
%   If nargout == 0 && nargin > 0,
%       execute and/or convert the specified command(s) or file(s). Can't
%       return handle(s), so it can't load objects this way;
%       
%   If nargout > 0 && nargin == 0,
%       load the default configuration file and return it's object(s)
%       handle(s);
%       
%   If nargout > 0 && nargin > 0,
%       execute, convert and/or load the given input command(s) or file(s)
%       and returns it's respective object(s) handle(s) or exit status.
%       
%   Note: Invalid arguments cause a break with an error message and a '1'
%   exit status value.
%
% Flags options usage:
%   
%   no flag,
%       the default bahavior is to load the specified configuration file(s)
%       and return its(') handle(s). If they do not exist, then an empty
%       array will be returned;
%   -c,
%       run the specified command(s) on the ready loaded object(s);
%   -e,
%       open the specified configuration file(s) to edit. If they do not
%       exist, they can be created;
%   -g,
%       load the specified object file(s) in graphical mode and return its(')
%       handles(s). If they do not exist, then an empty array will be
%       returned;
%   -h,
%       display this help text;
%   -n,
%       open new configuration file(s) with the specified names. If they
%       already exist, they can be overwriten;
%   -o,
%       load the specified object file(s) and return its(') handles(s).
%       If they do not exist, then an empty array will be returned;
%   -t,
%       convert object file(s) in configuration file(s) and vice-versa.
%       The source is loaded and saved on the target;
%   -x,
%       kill the process.
%
% See also: tplt, astratto.
%
% Author: <a href="matlab:disp('Working link!');">José Leonel L. Buzzo</a>
% Last Modified: 01/04/2017
% -----------------------------------------------------------------------------


    % =======================> PREAMBLE <======================================
    
    % -----------------------> Macro Definitions ------------------------------
    % Success exit status.
    EXT = 0;
    
    % Program's name.
    PNAME = 'neurocelle';
    
    % Program's prefix.
    PFX = 'ncl';
    
    % Program's title
    TITLE = 'NEUROCELLE';
    
    % Program's subtitle
    SUBTITLE = 'A Machine Learning Approach!';
    
    % Default root directory: Must be an absolute path.
    RDIR = fullfile('/home/leonel/Dropbox/Scientific/Programing/Matlab Ultimate - Leonel/Matlab Laboratory/',PNAME);
    
    % Configuration file ('neurocelle.conf') and Defaults file ('defaults.conf')
    % paths.
    % The configuration file is essencial for the program to run.
    CFG = fullfile(RDIR,'cfg',[PNAME '.conf']);
    %DFT = fullfile(RDIR,'cfg','defaults.conf');
    
    % Adjusting path to libraries.
    addpath(fullfile(RDIR,'bin'));
    addpath(fullfile(RDIR,'lib'));
    
    
    % -----------------------> Library import ---------------------------------
    %import('libbase.*');
    import('libcli.*');
    import('libflmgr.*');
    %import('libml.*');
    import('libncl.*');
    
    % -----------------------> Variable declarations --------------------------
    % Elapsed time.
    time = tic;
    %tm = 0;
    
    % Control param.
    ctrl = 1;
    
    % Verbosity switch: Status feedback only in presence of the verbose flag ('-v').
    verb = 'off';
    
    % Flags array.
    flags = {...
        '-a',@flag_a;
        '-c', @flag_c;
        '-e', @flag_e;
        '-g', @flag_g;
        '-h', @flag_h;
        '-i', @flag_i;
        '-n', @flag_n;
        '-o', @flag_o;
        '-p', @flag_p;
        '-r', @flag_r;
        '-R', @flag_R;
        '-s', @flag_s;
        '-t', @flag_t;
        '-v', @flag_v;
        '-x', @flag_x};
    
    cmds = {...
        '-c', @flag_c;
        '-e', @flag_e;
        '-g', @flag_g;
        '-h', @flag_h;
        '-i', @flag_i;
        '-n', @flag_n;
        '-o', @flag_o;
        '-p', @flag_p;
        '-r', @flag_r;
        '-R', @flag_R;
        '-s', @flag_s;
        '-t', @flag_t;
        '-x', @flag_x};
    
    
    % =======================> FUNCTION CODE <=================================
    
    try
        % Verbosity switch.
        if any(strcmp(varargin,'-v')), verb = ''; end
        
        % --- GREETINGS.
        screen(greetings(TITLE,SUBTITLE,[datestr(clock) ' - v0.1']),'var',verb);
        %screen(['''' PNAME ''' launched at ' datestr(clock) '.'],'',verb);
        
        % --- INITIAL LOADINGS.
        % The main program object: 'PNAME'.
        obj = feval(PNAME,CFG);
        obj.flags = flags;
        obj.cmds = cmds;
        obj.log.verbosity = verb;
        ctrl = 0;
        
        % NOTE: The 'user' and 'err' objects can only be created by default
        % loading, so 'err' are associated with an user at creation time.
        % They can't be loaded by a configuration file.
        
        % --- RUN!
        % Create 'log' file.
        obj.log.create;
        
        % Status feedbak.
        screen(['Main object''s loadings complete in ' num2str(toc(time)) ' seconds.'],'',verb);
        
        % Run in batch mode! (Enter the interface with the '-i' flag)
        [varargout{1:nargout}] = tplt(obj,varargin{:});
        
        % Finish 'log' file.
        obj.log.terminate;
        
        % Status feedbak.
        screen(['Overall spent time: ' num2str(toc(time)) ' seconds.'],'',verb);
    catch ERR
        % See error message.
        ERR.message
        
        % --- ERROR CATCH.
        if ctrl
            % Create 'log' file in crash case.
            %obj.log.create;
            %obj.log.note([PNAME ': '], 'Crash when loading defaults.');
            screen(['Crash on loading: ' ERR.message],'ferr',verb);
        else
            % Finishing 'log' file.
            obj.log.note([PNAME ': '],ERR.message);
            obj.log.terminate;
        end
        
        % Exiting with a failure value.
        [varargout(1:nargout)] = {~EXT};
        
        % Status feedbak.
        screen(['Overall spent time: ' num2str(toc(time)) ' seconds.'],'',verb);
    end
    
    % Status feedbak.
    screen(['Finished run at ' datestr(clock) '.'],'',verb);
end
