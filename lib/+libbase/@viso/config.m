function config(obj,varargin)

% CONFIG Summary of this function goes here
%   Detailed explanation goes here


    % Library import.
    import('libflmgr.*');
    
    fds = properties(obj);
    for ii = 1:size(fds,1)
        try
            k = fileopener(varargin{1},'-m',['<' fds{ii} '>'],['</' fds{ii} '>']);
            ret = [];
            
            switch fds{ii}
                case 'info'
                    ret = struct(...
                        'problem','',...
                        'configfile','',...
                        'datafile','',...
                        'objfile','',...
                        'pre_processfcn','',...
                        'processfcn','',...
                        'post_processfcn','');
                    
                    if ~isempty(k{1})
                        ret = filewrapper(ret,k{1}(:,1));
                    end
                case 'defaults'
                    
                case 'meta'
                    % It must be denied to the user to configure the object's
                    % 'meta' field by configuration file.
                    
                    k = fileopener(obj.meta.dftfile,'-m','<interfaces>','</interfaces>');
                    k = fileopener(k{1}(:,1),'-m','<meta>','</meta>');
                    
                    if ~isempty(k{1})
                        ret = filewrapper(obj.meta,k{1}(:,1));
                    end
                case 'id'
                    % It must be denied to the user to configure the object's
                    % 'id' field by configuration file.
                otherwise
                    continue;
            end
            
            obj.(fds{ii}) = ret;
        catch ERR
            %ERR.message
            %error(['+libbase.@viso: ' ERR.message]);
        end
    end
end
