function H = flag_g(varargin)

% Load object file(s) in graphical mode.

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
            if ischar(str{ii})
                % Loading from file.
                [path name ext] = fileparts(str{ii});
                if ~isempty(regexp(ext,['\.' obj.program_extension],'match'))
                    % Trying to load a configuration file.
                    [nofl c e g h n o itfc x] = feval(obj.program_name,'-t',str{ii});
                    itfc = itfc{1};
                elseif ~isempty(regexp(ext,'\.mat','match'))
                    % Trying to load an object file.
                    itfc = load(str{ii});
                    fds = fields(itfc);
                    % The loadable object must be in the first field.
                    itfc = itfc.(fds{1});
                else
                    error('Invalid file extension.');
                end
                
                H{ii} = feval(obj.default_loader_fcn,itfc,'-gui');
            elseif isstruct(str{ii})
                % Loading from structure in workspace.
                H{ii} = feval(obj.default_loader_fcn,str{ii},'-gui');
            else
                error('Invalid flag input.');
            end
        catch ERR
            H{ii} = ~exit_stt;
            ncl_err('flag_g',ERR.message);
        end
    end
end
