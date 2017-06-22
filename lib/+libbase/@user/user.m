classdef user < handle

% ---------------------------> USER help <--------------------------------------
% USER - Create, load or remove an 'user' object. Root's path must aways come
% in 'varargin{1}' and an eventual flag in 'varargin{2}'.
%
% See also: tplt, astratto.
%
% Author: <a href="matlab:disp('It is a working link!');">José Leonel L. Buzzo</a>
% Last Modified: 11/06/2016
% ------------------------------------------------------------------------------


    properties
        uid
        ukey
        udir
        ufile
        pid
        rdir
    end
    
    methods
        % --- Constructor function.
        function obj = user(varargin)
            try
                if nargin
                    if ischar(varargin{1}) && ~isempty(varargin{1}) ...
                            && exist(fullfile(varargin{1},'usr','users.conf'),'file') == 2
                        % Root's directory absolute path.
                        k = what(varargin{1});
                        RDIR = k.path;
                        
                        % Initialization switch: Create a new user, load an
                        % existent one or create a default 'Anonimous' user
                        % with the '-a' flag.
                        
                        if nargin == 1
                            % --- Default user creation: 'udir == rootpath'.
                            
                            obj.uid = 'Anonimous';
                            obj.ukey = '';
                            obj.udir = RDIR; % It's a special case.
                        elseif nargin == 2 && ischar(varargin{2}) && ~isempty(varargin{2})
                            % --- Default user creation: 'udir == rootpath'.
                            
                            obj.uid = varargin{2};
                            obj.ukey = '';
                            obj.udir = RDIR; % It's a special case.
                        elseif nargin == 3 ...
                                && ischar(varargin{2}) && ~isempty(varargin{2}) ...
                                && ischar(varargin{3}) && ~isempty(varargin{3}) ...
                                && exist(fullfile(varargin{3}),'dir') == 7
                            % --- Ordinary user creation, by root path, name,
                            % and folder path.
                            k = what(varargin{3});
                            
                            % A new user.
                            obj.uid = varargin{2};
                            obj.ukey = '';
                            obj.udir = k.path;
                        else
                            error('Invalid inputs, user couldn''t be loaded.');
                        end
                        
                        % Set root directory.
                        obj.rdir = RDIR;
                        
                        % Write user entry, except for 'Anonimous' user.
                        ~strcmp(obj.uid,'Anonimous') && ~obj.putusr(obj,'-f');
                    else
                        obj = libbase.user;
                    end
                end
            catch ERR
                error(['+libbase.@user: ' ERR.message]);
            end
        end
    end
    
    methods (Static)
        % --- Static member functions.
        [EXT, usr] = setusr(varargin)
        [EXT, usr] = getusr(varargin)
        [EXT, usr] = putusr(varargin)
        [EXT, usr] = rmusr(varargin)
    end
end
