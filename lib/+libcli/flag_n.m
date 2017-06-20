function H = flag_n(varargin)

% Open new file(s) to edit. Overwrite if choosen so.

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
            if ischar(str{ii}) && exist(str{ii},'file') ~= 2
                % Open a new file to edit.
                edit(str{ii});
            elseif ischar(str{ii})
                % Confirm before overwrite file.
                qst = input(['File ''' str{ii} ''' already exists. Overwrite it? [y,N] '],'s');
                if any(strcmp(qst,{'Y' 'y'}))
                    edit(str{ii});
                end
            else
                error('Invalid flag input.');
            end
        catch ERR
            H{ii} = ~exit_stt;
            ncl_err('flag_n',ERR.message);
        end
    end
end
