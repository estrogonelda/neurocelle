function H = flag_t(obj,varargin)

% Translate/convert object file(s) into its(') respective configuration
% file(s), and vise-versa.

    % Adjusting inputs.
    obj = varargin{1}{1};
    str = varargin{1}(2:end);
    
    exit_stt = 0;
    
    % Initialy, 'H' is set to the exit status 'exit_stt', that is, by default
    % the success value '0', changing inside the function, if needed.
    H = cell(size(str));
    for ii = 1:size(str,2)
        H{ii} = exit_stt;
        try
            if ischar(str{ii}) && ~isempty(regexp(str{ii},['\.' obj.program_extension '$'],'match'))
                % Lines are loaded from file, then they are translated in a struct.
                lines = fileopener(str{ii});
                if isempty(lines), error('Invalid input file.'); end
                
                ctrl = 1;
                while ctrl <= size(lines,1)
                    itfc = regexp(lines{ctrl},'(?<=xmlns=").*[^">;]','match');
                    if ~isempty(itfc), break; end
                    ctrl = ctrl + 1;
                end
                
                if ctrl > size(lines,1)
                    % If 'ctrl > size(lines,1)' the file 'str{ii}' is invalid.
                    error(['Unable to translate file ''' str{ii} '''.'],'');
                else
                    % Taking the load function name without the '.m' extension.
                    % File lines can be translated in an object.
                    H{ii} = filewrapper(feval(itfc{1}),lines);
                end
            elseif ischar(str{ii}) && ~isempty(regexp(str{ii},'\.mat$','match'))
                % Struct is loaded from file, then it is translated in lines.
                itfc = load(str{ii});
                fds = fields(itfc);
                H{ii} = filewrapper(itfc.(fds{1}));
            elseif iscell(str{ii})
                % Lines in workspace are translated in a struct.
                H{ii} = filewrapper(feval(obj.default_constructor_fcn),str{ii});
            elseif isstruct(str{ii})
                % Struct in workspace is translated in lines.
                H{ii} = filewrapper(str{ii});
            else
                error('Invalid flag input.');
            end
        catch ERR
            H{ii} = ~exit_stt;
            ncl_err('flag_t',ERR.message);
        end
    end
end
