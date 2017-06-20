function res = fileopener(varargin)

% ---------------------------> FILEOPENER help <--------------------------------
% FILEOPENER - Generic interface object creator.
%
% Must implement the hability of manipulate an array of input files and, or
% return them to the output variables or return to the standart output.
% ------------------------------------------------------------------------------


    % =======================> PREAMBLE <=======================================
    
    % --- Macro Definitions.
    % Success exit status.
    %EXT = 0;
    
    % --- Library import.
    import('libflmgr.*');
    
    % --- Variable declarations.
    % Default return value;
    res = {};
    
    % Message parameter.
    show_msg = 'off';
    
    % =======================> FUNCTION CODE <==================================
    
    try
        % Input arguments verification. Here, '-m' is a match flag.
        if nargin && (~any(strcmp(varargin,'-m')) || (find(strcmp(varargin,'-m')) == size(varargin,2)-2 && find(strcmp(varargin,'-m')) > 1))
            % Allocating memory for the return cell;
            if any(strcmp(varargin,'-m'))
                res = cell(nargin-3,1);
            else
                res = cell(nargin,1);
            end
        else
            error('Incorrect use of the ''-m'' flag or ''nargin == 0''.');
        end
        
        
        for ii = 1:size(res,1)
            % Inputs verification.
            if iscell(varargin{ii})
                % Sub cell pattern extraction.
                if any(strcmp(varargin,'-m')) && size(varargin{ii},2) == 1
                    % Finding '-m' flag.
                    mposition = find(strcmp(varargin,'-m'));
                    matchln = varargin([mposition+1 mposition+2]);
                    
                    % Trimming empty cells from tail.
                    dim = 0;
                    for jj = 1:size(varargin{ii},1)
                        if ~ischar(varargin{ii}{jj}), dim = jj-1; break; end
                        dim = jj;
                    end
                    
                    % Sub extraction.
                    p_res = subextract(varargin{ii}(1:dim),matchln,ii,show_msg);
                else
                    % No extraction.
                    p_res = varargin{ii};
                end
            elseif ischar(varargin{ii})
                % File existence verification.
                if exist(varargin{ii},'file') ~= 2
                    screen(['File ''' varargin{ii} ''' does not exist.'],'',show_msg);
                    res{ii} = [];
                    continue;
                end
                
                % File openning verification.
                [fl, msg] = fopen(varargin{ii},'r');
                if msg
                    screen(['Unable to open file ''' varargin{ii} '''.'],'',show_msg);
                    res{ii} = [];
                    continue;
                end
                
                % Line counting, from beginning to the end.
                jj = 0;
                str = fgetl(fl);
                while ischar(str) % str ~= -1
                    jj = jj + 1;
                    str = fgetl(fl);
                end
                % Rewind file.
                fseek(fl,0,'bof');
                
                % Reading all file lines.
                p_res = cell(jj,1);
                jj = 0;
                str = fgetl(fl);
                while ischar(str) % str ~= -1
                    p_res{jj+1} = strtrim(str);
                    jj = jj + 1;
                    str = fgetl(fl);
                end
                
                % Closing file.
                fclose(fl);
                
                % --- Returning matches, if requested;
                if any(strcmp(varargin,'-m'))
                    % Finding '-m' flag.
                    mposition = find(strcmp(varargin,'-m'));
                    matchln = varargin([mposition+1 mposition+2]);
                    
                    % Sub extraction.
                    p_res = subextract(p_res,matchln,ii,show_msg);
                end
            else
                % Invalid inputs.
                screen(['Argin ', num2str(ii), ' doesn''t represent a valid file.'],'',show_msg);
                p_res = [];
            end
            
            res{ii} = p_res;
        end
    catch ERR
        error(['fileopener: ',ERR.message]);
    end
end

function sub = subextract(lines,pattern,argnum,show_msg)


    % --- Library import.
    import('libflmgr.*');
    
    sub = [];
    
    if isempty(lines)
        return;
    end
    
    matchctr = zeros(size(lines),'uint8');
    control = 0;
    acm = 0;
    for jj = 1:size(lines,1);
        if ~isempty(regexp(lines{jj},pattern{1},'match')) && control == 0
            control = 1;
            acm = acm + 1;
        elseif ~isempty(regexp(lines{jj},pattern{2},'match'))
            matchctr(jj) = acm;
            control = 0;
        end
        
        if control
            matchctr(jj) = acm;
        end
    end
    
    % Verifyinf tags consistency in the ftarget file.
    if control
        screen('Inconsistent configuration file.','',show_msg);
        return;
    end
    
    count = 0;
    for jj = 1:acm
        count = max(count,sum(matchctr == jj));
    end
    
    % Returnnning in separate cells.
    sub = cell(count,acm);
    for jj = 1:acm
        % Horizontal cell of vertical cell matches.
        sub(1:sum(matchctr == jj),jj) = lines(matchctr == jj);
    end
    
    if isempty(sub)
        screen(['Unmached patterns in argument ' num2str(argnum) '.'],'',show_msg);
        sub = [];
    end
end
