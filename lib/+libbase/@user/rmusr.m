function [EXT, usr] = rmusr(varargin)

% RMUSR - Remove an user entry from the root's 'users.cfg' file and return it.
%
% The inputs can be either:
%   An 'user' obj;
%   Or a valid configuration file (1st) with the target user name (2nd) in it.


    % Library import.
    import('libbase.*');
    import('libflmgr.*');
    
    % Failure exit status.
    EXT = 0;
    
    usr = user;
    
    try
        % Verifying input arguments.
        if nargin == 1 && isa(varargin{1},'user') && exist(fullfile(varargin{1}.rdir,'usr','users.conf'),'file')
            uname = varargin{1}.uid;
            cfgfile = fullfile(varargin{1}.rdir,'usr','users.conf');
            rdir = varargin{1}.rdir;
        elseif nargin == 2 && ischar(varargin{1}) && ~isempty(varargin{1}) && exist(fullfile(varargin{1},'usr','users.conf'),'file') ...
                && ischar(varargin{2})
            % Search for a user name in the 'users.cfg' at the root directory.
            uname = varargin{2};
            cfgfile = fullfile(varargin{1},'usr','users.cfg');
            rdir = varargin{1};
        else
            error('No valid inputs.');
        end
        
        % Search for the specified user entry in 'users.txt' file.
        [ii, usr] = user.getusr(rdir,uname);
        
        % Search for the specified user entry in 'users.txt' file.
        if ii
            lines = fileopener(cfgfile,'-m','<users>','</users>');
            if size(lines,2) == 1, lines = {lines}; end
            
            dim = size(lines{ii},1);
            
            % Iterate over entries.
            lines = fileopener(cfgfile);
            for ii = 1:size(lines,1)
                if ~isempty(regexp(lines{ii},uname,'match'))
                    break;
                end
            end
            
            % Rewrite file without the removed user.
            lines = lines([1:ii-2 ii+dim-1:end]);
            [fl, msg] = fopen(cfgfile,'w');
            if ~isempty(msg), error('Can''t rewrite user entry.'); end
            for ii = 1:size(lines,1)
                fprintf(fl,'%s\n',lines{ii});
            end
            fclose(fl);
            
            EXT = ~EXT;
        else
            %error('Unnexistent user entry. Cant''t remove it.');
        end
    catch ERR
        error(['+libbase.@user.rmusr: ',ERR.message]);
    end
end
