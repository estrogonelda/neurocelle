function config(obj,varargin)

% ---------------------------> +LIBBASE.@ANIMA.CONFIG help <-------------------
% +LIBBASE.@ANIMA.CONFIG - The whole software structure definitions and
% loadings.
%
% See also: tplt, astratto.
%
% Author: José Leonel L. Buzzo.
% Last Modified: 11/06/2016.
% -----------------------------------------------------------------------------


    % =======================> PREAMBLE <======================================
    
    % -----------------------> Macro Definitions ------------------------------
    % Success exit status.
    %EXT = 0;
    
    % Make actual folder the root directory.
    RDIR = pwd;
    
    % -----------------------> Library import ---------------------------------
    import('libflmgr.*');
    
    
    % -----------------------> Variable declarations --------------------------
    % Structure with empty fields. The whole software metadata.
    str = struct(...
        'program','',...
        'id','',...
        'version','',...
        'license','',...
        'repository','',...
        'mcrpath','',...
        'rootpath','',...
        'cfgpath','',...
        'dftpath','',...
        'modlist','',...
        'sever_client','',...
        'keys','',...
        'proc_manager','',...
        'proj_manager','',...
        'mdl_manager','',...
        'sim_manager','',...
        'UI_manager','',...
        'rpt_manager','',...
        'draw_manager','');
    
    
    % =======================> FUNCTION CODE <==================================
    
    try
        % Testing input file consistency.
        if nargin > 1 ...
                && ischar(varargin{1}) && exist(varargin{1},'file') == 2 ...
                && any(strcmp(regexp(varargin{1},'\.','split'),'conf'))
            % Ordinary configuration file.
            k = fileopener(varargin{1},'-m','<software>','</software>');
            
            if ~isempty(k{1})
                str = filewrapper(str,k{1}(:,1));
            else
                error('Configuration file is wrong or corrupted.');
            end
        else
            % Alternative configuration.
            screen('Configuration file is missing. Default configuration was set.','');
            
            % Second tentative of a correct rootpath initialization.
            str.rootpath = RDIR;
            str.modlist = {};
        end
        
        
        % Return on object field.
        if ~isempty(str.rootpath)
            obj.software = str;
        else
            error('Invalid configuration file.');
        end
    catch ERR
        error(['+libbase.@anima.config: ' ERR.message]);
    end
end
