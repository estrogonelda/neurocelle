function output = loadmod(obj,varargin)

% +LIBBASE.@ANIMA.LOADMOD - Load 'anima' modules.


    % =======================> PREAMBLE <======================================
    
    % --- Macro Definitions.
    % ----------------------
    
    % --- Library import.
    import('libncl.*');
    import('libbase.*'); % Library 'libbase' can't take precedence.
    
    % --- Variable declarations.
    % Output.
    output = [];
    
    
    % =======================> FUNCTION CODE <=================================
    
    try
        % With '-H' flag, 'loadmod' returns the respective modulo handler.
        if nargin - 1 > 1 && ischar(varargin{1}) && any(strcmp(varargin{1},{'-H' '-N'})) && ischar(varargin{2})
            for ii = 1:size(obj.modules,1)
                if strcmp(varargin{1},'-H') && strcmp(class(obj.modules{ii}),varargin{2})
                    output = obj.modules{ii};
                    return;
                elseif strcmp(class(obj.modules{ii}),varargin{2})
                    output = ii;
                    return;
                end
            end
            
            % Unnexistent modulo.
            output = [];
            return;
        end
        
        
        H = cell(nargin-1,1);
        for ii = 1:size(H,1)
            try
                % The 'lib' folder must be in path and the module name must be in the software's
                % modules list.
                if any(strcmp(varargin{ii},obj.software.modlist)) ...
                        && (exist(fullfile(obj.software.rootpath,'lib/+libbase',['@' varargin{ii}],varargin{ii}),'file') == 2 ...
                        || exist(fullfile(obj.software.rootpath,'lib/+libncl',['@' varargin{ii}],varargin{ii}),'file') == 2)
                    
                    H{ii} = feval(varargin{ii},obj.software.dftpath);
                    
                    % Module load validation and user to module vinculation.
                    if ~isempty(H{ii}) && isempty(H{ii}.id)
                        error(['Invalid configuration file for module ''' varargin{ii} '''.']);
                    else
                        H{ii}.meta.user = obj.users.uid;
                    end
                else
                    error('Unnexistent module library.');
                end
            catch ERR
                ERR.message
                H{ii} = [];
                %error(['@anima.loadmod: ' ERR.message]);
            end
        end
        
        
        output = H;
    catch ERR
        error(['+libbase.@anima.loadmod: ' ERR.message]);
    end
end
