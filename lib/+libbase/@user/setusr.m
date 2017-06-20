function [EXT usr] = setusr(varargin)

% SETUSR - Create or overwrite an user entry in the root's 'users.cfg' file.
%
% The inputs can be either:
%   An 'user' object;
%   Or the root's path (1st) with an 'user.uid' name (2nd) and a valid target
%   folder path (3rd) to initialize it's data after create or overwrite it's
%   entry.


    % Library import.
    import('libbase.*');
    import('libflmgr.*');
    
    % Failure exit status.
    EXT = false;
    
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
        
        if ~getusr(rdir,uname)
            
        end
        
        EXT = ~EXT;
    catch ERR
        error(['+libbase.@user.setusr: ',ERR.message]);
    end
end
