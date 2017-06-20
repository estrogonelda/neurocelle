function output = no_flag(obj,varargin)

% ---------------------------> NO_FLAG help <----------------------------------
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
% -----------------------------------------------------------------------------


    % =======================> PREAMBLE <======================================
    
    % --- Macro Definitions.
    % Success exit status.
    %EXT = true;
    
    % --- Library import.
    import('libcli.*');
    import('libflmgr.*');
    import('libncl.*');
    
    % --- Variable declarations.
    % Outputs cell.
    output = cell(nargin-1,1);
    % Defaut return;
    ret = [];
    % Loop control.
    ii = 1;
    
    
    % =======================> FUNCTION CODE <=================================
    
    % Initialy, 'H' is set to the exit status 'exit_stt', that is, by default
    % the success value '0', changing inside the function, if needed.
    while ii <= nargin-1
        try
            % Feel the input.
            switch class(varargin{ii})
                case 'double'
                    % Run data directly from input. The default is to make a
                    % full statistical analysis on any given data.
                    ret = obj.flags{strcmp(obj.flags(:,1),'-s'),2}(obj,varargin{ii});
                case 'char'
                    % File name input.
                    if exist(varargin{ii},'file') == 2
                        % Load object from a file (only extensions '.mat' and '.zst').
                        
                        % Feeling file type by extension.
                        [pathh, file, ext] = fileparts(varargin{ii});
                        
                        switch ext
                            case '.mat'
                                % Load object from an object or a data file.
                                vars = load(varargin{ii});
                                fds = fields(vars);
                                
                                if size(fds,1) == 1
                                    % Object file: Must Overwrite 'obj' with the
                                    % loaded struct.
                                    
                                    if isa(vars.(fds{1}),class(obj))
                                        % Load from an object (direct load on 'obj').
                                        ret = vars.(fds{1});
                                    elseif isnumeric(vars.(fds{1})) || isa(vars.(fds{1}),'dataset')
                                        % Load from 'numeric' data.
                                        ret = obj.flags{strcmp(obj.flags(:,1),'-s'),2}(obj,vars.(fds{1}));
                                    else
                                        error(['Can''t load object type ''' class(vars.(fds{1})) ''' this way.']);
                                    end
                                else
                                    % Disperse data file.
                                    k = cell(size(fds));
                                    for jj = 1:size(fds,1)
                                        k{jj} = vars.(fds{jj});
                                    end
                                    
                                    ret = obj.flags{strcmp(obj.flags(:,1),'-s'),2}(obj,k{:});
                                end
                            case '.csv'
                                % Load from text file.
                                mtx = csvread(fullfile(pathh,[file ext]));
                                ret = obj.flags{strcmp(obj.flags(:,1),'-s'),2}(obj,mtx);
                            case '.xls'
                                % Load from 'xls' file.
                                [num, ~, ~] = xlsread(fullfile(pathh,[file ext]),'','','basic');
                                ret = obj.flags{strcmp(obj.flags(:,1),'-s'),2}(obj,num);
                                % FIX HERE!
                            case '.conf'
                                % Load object from the configuration file (direct load on 'obj').
                                k = fileopener(fullfile(pathh,[file ext]),'-m','<projects>','</projects>');
                                ret = progetto(k{1}(:,1));
                            case '.xml'
                                % Load object from a 'xml' configuration file (direct load on 'obj').
                                k = fileopener(fullfile(pathh,[file ext]),'-m','<projects>','</projects>');
                                ret = progetto(k{1}(:,1));
                            case '.tex'
                                % Load report data.
                                ret = obj.flags{strcmp(obj.flags(:,1),'-r'),2}(obj,fullfile(pathh,[file ext]));
                            case '.txt'
                                % Load text data to edit.
                                ret = edit(fullfile(pathh,[file ext]));
                            case '.m'
                                % Evaluate script file (direct load on 'obj').
                                addpath(pathh);
                                ret = feval(file);
                                rmpath(pathh);
                            case '.sh'
                                % Evaluate a shell script file.
                                error('Can''t run a shell script this way.');
                            case ''
                                % Evaluate a shell script file.
                                error('Can''t run a shell script this way.');
                            otherwise
                                error(['Unsuported file type ''' ext '''.']);
                        end
                    elseif exist(varargin{ii},'var')
                        % Workspace var name input.
                        ret = obj.flags{strcmp(obj.flags(:,1),'-s'),2}(obj,varargin{ii});
                    else
                        % Internal command name input.
                        
                        % Calculating argument displacements for each command.
                        cmds = {'adduser',2;
                            'backup',1;
                            'clrlog',0;
                            'fix',0;
                            'install',1;
                            'interact',0;
                            'login',2;
                            'mcbdolly',1;
                            'meta',-1;
                            'new',1;
                            'rmuser',2;
                            'save',1
                            'savedata',1;
                            'server',1
                            'version',0};
                        
                        k = strcmp(cmds(:,1),varargin{ii});
                        if any(k) && size(varargin,2) >= ii+cmds{k,2}
                            [r, ret] = glossary(obj,varargin{ii:ii+cmds{k,2}});
                        else
                            [r, ret] = glossary(obj,varargin{ii});
                        end
                        
                        % Iteration adjustment.
                        if r
                            % A currect command execution.
                            ii = ii + cmds{k,2};
                        elseif size(varargin,2) > ii && any(k) && ~any(strcmp(cmds(:,1),varargin{ii+1}))
                            % An error on command execution with iteration adjustment.
                            aux = ii;
                            for jj = ii+1:ii+cmds{k,2};
                                if size(varargin,2) > ii && ~any(strcmp(cmds(:,1),varargin{ii+1}))
                                    ii = jj;
                                else
                                    break;
                                end
                            end
                            error(['Inconsistent internal commmand ''' varargin{aux} '''.']);
                        else
                            % An error on command execution.
                            error(['Inconsistent internal commmand ''' varargin{ii} '''.']);
                        end
                    end
                case 'cell'
                    % Run statistics on cell data.
                    if iscellstr(varargin{ii})
                        ret = obj.flags{strcmp(obj.flags(:,1),'-a'),2}(obj,varargin{ii}{:});
                    else
                        
                    end
                case 'struct'
                    % Run statistics on struct data.
                    screen('''struct'' arguments type are not supported.','');
                case 'dataset'
                    % Run statistics on struct data.
                    screen('''dataset'' arguments type are not supported.','');
                case class(obj)
                    % Run statistics on the default format object data.
                    disp('obj');
                otherwise
                    error('Invalid input arguments.');
            end
            
            % Currect return.
            output{ii} = ret;
        catch ERR
            output{ii} = [];
            obj.log.note('no_flag: ',ERR.message);
        end
        
        ii = ii + 1;
    end
    
    % Supress empty returns.
    %ret = false(size(output));
    %for ii = 1:size(output,1)
    %    if ~isempty(output{ii})
    %        ret(ii) = true;
    %    end
    %end
    
    %output = output(ret);
end
