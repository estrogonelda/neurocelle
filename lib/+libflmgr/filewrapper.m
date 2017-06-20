function ret = filewrapper(varargin)

% ---------------------------> FILEWRAPPER help <-------------------------------
% FILEWRAPPER - Generic interface object creator. Work on only one file
% each time.
%
% Must implement the hability of manipulate an array of input files and, or
% return them to the output variables or return to the standart output.
% ------------------------------------------------------------------------------


    % =======================> PREAMBLE <=======================================
    
    % --- Macro Definitions.
    % Success exit status.
    EXT = true;
    
    % --- Library import.
    import('libflmgr.*');
    
    % --- Variable declarations.
    % Control param.
    ret = [];
    
    
    % =======================> FUNCTION CODE <==================================
    
    try
        opt = '';
        
        switch nargin
            case 0
                error('Invalid number of input arguments. Must be nargin > 0.');
            case 1
                if (isstruct(varargin{1}) || isobject(varargin{1})) && ~isempty(varargin{1})
                    opt = 'deload';
                    obj = varargin{1};
                else
                    error('Invalid object input argument. It must be a non-empty structure.');
                end
            case 2
                if (isstruct(varargin{1}) || isobject(varargin{1})) && ~isempty(varargin{1}) && iscell(varargin{2}) && ~isempty(varargin{2})
                    opt = 'load';
                    obj = varargin{1};
                    data = varargin{2};
                else
                    error('Invalid input arguments. It must be a structure first and a cell.');
                end
            otherwise
                % To translate only one file, there must be a third irrelevant
                %input argument of type char beyond the file.
                if (isstruct(varargin{1}) || isobject(varargin{1})) && ~isempty(varargin{1}) && ischar(varargin{2}) && strcmp(varargin{2},'-t')
                    opt = 'translate';
                    obj = varargin{1};
                    data = varargin(3:end);
                else
                    error('Invalid input arguments.');
                end
        end
        
        
        switch opt
            case 'load'
                % Load object from the configuration file.
                for ii = 1:size(data,1)
                    [obj, ~] = obj_loader(obj,data{ii},'overwrite');
                end
                
                ret = obj;
            case 'deload'
                % Return cell array from the loaded object.
                ret = obj_deloader(obj);
            case 'translate'
                % Return an exit status of a file writting.
                res = cell(size(data,2),1);
                for ii = 1:size(data,2)
                    if ischar(data{ii}) && ~isempty(data{ii})
                        % Translating a file.
                        res{ii} = obj_translator(obj,fileopener(data{ii}));
                    elseif iscell(data{ii}) && ~isempty(data{ii})
                        % Translating a cell.
                        res{ii} = obj_translator(obj,data{ii});
                    elseif isstruct(data{ii}) && ~isempty(data{ii})
                        % Translating a structure.
                        res{ii} = obj_translator(obj,filewrapper(data{ii}));
                    else
                        res{ii} = ~EXT;
                    end
                end
                
                if size(res,1) > 1
                    ret = res;
                else
                    ret = res{1};
                end
            otherwise
                % Invalid option.
                error('Invalid option.');
        end
    catch ERR
        error(['filewrapper: ',ERR.message]);
    end
end


function [obj ret_status] = obj_loader(obj,line,opt)

    % There are three options: overwrite, array and match.
    
    % --- Library import.
    import('libflmgr.*');
    
    % Debug code.
    %disp(obj); disp(line); disp('sd');
    
    % Status of an assignment.
    ret_status = '';
    
    % Ignore commentaries and blank lines.
    if isempty(line) || line(1) == '%'
        return;
    end
    fds = fields(obj);
    
    % Array of objects.
    if size(obj,2) > 1
        ii = 1:size(obj,2);
        if ~strcmp(opt,'match')
            opt = 'array'; % Do not overwrite fields.
        elseif ~isempty(regexp(line,'#','match'))
            ln = regexp(line,'#','split');
            if str2num(ln{1}) > 0 && str2num(ln{1}) <= max(ii);
                ii = str2num(ln{1});
            else
                % Can't exceed 'obj' size.
                return;
            end
            line = ln{2};
        end
        
        % Recursive field query.
        for ii = ii
            [obj(ii) ret_status] = obj_loader(obj(ii),line,opt);
            if ~isempty(ret_status), break; end
        end
        
        return;
    end
    
    for jj=1:length(fds)
        % Must continue only if it matches a object fields in
        % the beginning of a line, that is a entire word before the equal sign.
        if isstruct(obj.(fds{jj})) || isobject(obj.(fds{jj}))
            % Match evaluation.
            if strcmp(opt,'match') && ~isempty(regexp(line,['^' fds{jj}],'match'))
                % If there is a nested object, must return the currect
                % index of it.
                ln = regexp(line,'\.','split');
                num = regexp(ln{1},'\d','match');
                if size(ln,2) == 1
                    % Missing sub field. Do nothing.
                    %continue;
                elseif ~isempty(num)
                    % Currect, index and sub field.
                    % A metacharacter composition.
                    line = [cell2mat(num) '#' strjoin(ln(2:end),'.')];
                elseif size(obj.(fds{jj}),2) > 1
                    % Missing index in a struct array (num is empty). Do
                    % nothing.
                    %continue;
                else
                    % A sub field in a simple nested struct.
                    line = strjoin(ln(2:end),'.');
                end
            end
            
            % Skipping read-olny properties.
            ctrl = true;
            info = metaclass(obj.(fds{jj}));
            for kk = 1:size(info.PropertyList,1)
                if ~strcmp(info.PropertyList(kk).SetAccess,'public')
                    ctrl = ~ctrl;
                    break;
                end
            end
            
            % Recursive field query.
            if isstruct(obj.(fds{jj})) || ctrl
                [obj.(fds{jj}) ret_status] = obj_loader(obj.(fds{jj}),line,opt);
            else
                % Specific class SetAccess function.
            end
            
            % Here, it would verify any previous assignment to avoid
            % unecessary loops, but to verify it is an expensivier procedure.
            if ~isempty(ret_status)
                return;
            end
        elseif ~any(strcmp(fds{jj},strtrim(regexp(line,['^' fds{jj} '\>.?'],'match'))))
            % Ignore unexistent fields.
            continue;
        elseif strcmp(opt,'match')
            % Returning only the matched line.
            ret_status = obj.(fds{jj});
            return;
        elseif ~isempty(obj.(fds{jj})) && ~strcmp(opt,'overwrite')
            % Do not overwrite field.
            % Do nothing.
        else
            % True loading. NOTE: Here, strtrim deblanks each string.
            retcell = strtrim(regexp(regexp(line,'(?<==[\s*])(.*)[^;]','match'),',','split'));
            
            % Correcting retcell type. Must be a cell only in case of existence
            % of commas separating the raw data.
            if isempty(retcell)
                retcell = ' '; % Space bar.
            elseif sum(size(retcell{1})) <= 2 % There must be 'size == 1'.
                retcell = cell2mat(retcell{1});
            else
                % For n-D arrays of cell.
                retcell = retcell{1};
            end
            
            % Returning the matched line.
            obj.(fds{jj}) = retcell;
            ret_status = obj.(fds{jj});
            return;
        end
    end
end

function retcell = obj_deloader(obj)

    retcell = {};
    fds = fields(obj);
    
    if isa(obj,'err')
        %return;
    end
    
    % Recursively digging inside the object.
    for ii = 1:size(fds,1)
        if (isstruct(obj.(fds{ii})) || isobject(obj.(fds{ii}))) && size(obj.(fds{ii}),2) == 1
            retcell = cat(1,retcell,['<' fds{ii} '>']);
            retcell = cat(1,retcell,obj_deloader(obj.(fds{ii})));
            retcell = cat(1,retcell,['</' fds{ii} '>']);
        elseif (isstruct(obj.(fds{ii})) || isobject(obj.(fds{ii}))) && size(obj.(fds{ii}),2) > 1
            for jj = 1:size(obj.(fds{ii}),2)
                retcell = cat(1,retcell,['<' fds{ii} '>']);
                retcell = cat(1,retcell,obj_deloader(obj.(fds{ii})(jj)));
                retcell = cat(1,retcell,['</' fds{ii} '>']);
            end
        elseif iscell(obj.(fds{ii}))
            if isempty(obj.(fds{ii}))
                retcell = cat(1,retcell,'{};');
            elseif iscellstr(obj.(fds{ii}))
                cell = '';
                for jj = 1:size(obj.(fds{ii}),2)
                    cell = cat(2,cell,obj.(fds{ii}){jj},',');
                end
                cell(end) = ';';
                retcell = cat(1,retcell,cat(2,[fds{ii} ' = '],cell));
            else
                retcell = cat(1,retcell,[fds{ii} ' = {']);
                for jj = 1:size(obj.(fds{ii}),1)
                    if ~isempty(obj.(fds{ii}){jj})
                        retcell = cat(1,retcell,['<' class(obj.(fds{ii}){jj}) '>']);
                        retcell = cat(1,retcell,obj_deloader(obj.(fds{ii}){jj}));
                        retcell = cat(1,retcell,['</' class(obj.(fds{ii}){jj}) '>']);
                    else
                        % Empty atribute or field.
                        retcell = cat(1,retcell,'[]');
                    end
                end
                retcell = cat(1,retcell,'};');
            end
        elseif ishandle(obj.(fds{ii}))
            disp('handle');
            retcell = cat(1,retcell,[fds{ii} ' = ;']);
        else
            if isempty(obj.(fds{ii}))
                % Empty atribute or field.
                retcell = cat(1,retcell,[fds{ii} ' = [];']);
            elseif isnumeric(obj.(fds{ii})) && size(obj.(fds{ii}),1) == 1
                % Converting numbers to strings.
                retcell = cat(1,retcell,{[fds{ii} ' = ' num2str(obj.(fds{ii})) ';']});
            elseif strcmp(obj.(fds{ii}),' ')
                % Cutting off the space in pseudo-empty fields.
                retcell = cat(1,retcell,{[fds{ii} ' = ;']});
            else
                try
                    retcell = cat(1,retcell,{[fds{ii} ' = ' obj.(fds{ii}) ';']});
                catch
                    % FIX HERE!
                    retcell = cat(1,retcell,[fds{ii} ' = [NAN];']);
                end
            end
        end
    end
    
    if size(fds,1) == 0
        retcell = '';
    end
end

function r = obj_translator(obj,lines)

    % Default sucess value.
    r = '';
    
    if isempty(obj) || isempty(lines)
        r = {};
        return;
    end
    
    % Extracting coded variables from the input lines.
    % This left a space at the end of the word.
    vars = regexp(lines,'\$\w*[\.?(\(\d\))?(\.\w*)?]*','match');
    varsfcn = regexp(lines,'\$''.*''\s*','match'); % Function evaluating.
    for ii = 1:size(lines,1)
        % Must ignore empty and commentary lines.
        if ~isempty(chomp(vars{ii})) && ~strcmp(lines{ii}(1),'%')
            % Translating line per line.
            if size(vars{ii},2) > 1
                v_tmp = cell(1,size(vars{ii},2));
                for jj = 1:size(vars{ii},2)
                    [null v_tmp{jj}] = obj_loader(obj,chomp(vars{ii}{jj}),'match');
                    
                    if isempty(v_tmp{jj})
                        v_tmp{jj} = vars{ii}{jj};
                    elseif iscell(v_tmp{jj})
                        v_tmp{jj} = strjoin(v_tmp{jj},', ');
                    end
                end
                v = v_tmp;
            else
                [null v] = obj_loader(obj,chomp(vars{ii}{1}),'match');
                
                if iscell(v)
                    v = strjoin(v,', ');
                end
            end
            
            if isnumeric(v)
                v = num2str(v);
            end
            
            % Must be a char string or cell.
            if ~isempty(v)
                lines{ii} = strjoin(regexp(lines{ii},'\$\w*[\.?(\(\d\))?(\.\w*)?]*','split'),v);
            end
        end
    end
    
    r = lines;
end
