function [EXT, usr] = getusr(varargin)

% GETUSR - Search for an user entry in root's 'users.cfg' file and return it.
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
            
        elseif nargin == 2 && ischar(varargin{1}) && ~isempty(varargin{1}) && ...
                exist(fullfile(varargin{1},'usr','users.conf'),'file') && ...
                ischar(varargin{2})
            % Search for a user name in the 'users.cfg' at the root directory.
            uname = varargin{2};
            cfgfile = fullfile(varargin{1},'usr','users.conf');
            
        else
            error('No valid inputs.');
        end
        
        
        % Search for the specified user entry in 'users.txt' file.
        lines = fileopener2(cfgfile,'-m','<users>','</users>');
        
        % Iterate over entries.
        for ii = 1:size(lines{1},2)
            if strcmp(regexp(lines{1}{2,ii},uname,'match'),uname)
                usr = filewrapper(usr,lines{1}(:,ii));
                EXT = ii;
                return;
            end
        end
        
        usr = [];
    catch ERR
        error(['+libbase.@user.getusr: ' ERR.message]);
    end
end
