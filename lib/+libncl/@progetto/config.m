function config(obj,varargin)

% +LIBNCL.@PROGETTO.CONFIG Summary of this function goes here
%   Detailed explanation goes here


    % Library import.
    import('libflmgr.*');
    import('libncl.*');
    
    fds = properties(obj);
    for ii = 1:size(fds,1)
        try
            k = fileopener(varargin{1},'-m',['<' fds{ii} '>'],['</' fds{ii} '>']);
            ret = [];
            
            switch fds{ii}
                case 'id'
                    % It must denied to the user to configurate the object's
                    % 'id' field by configuration file.
                case 'meta'
                    % It must denied to the user to configurate the object's
                    % 'meta' field by configuration file.
                    
                    k = fileopener(obj.meta.dftfile,'-m','<projects>','</projects>');
                    k = fileopener(k{1}(:,1),'-m','<meta>','</meta>');
                    
                    if ~isempty(k{1})
                        ret = filewrapper(obj.meta,k{1}(:,1));
                    end
                case 'info'
                    ret = struct(...
                        'title','',...
                        'authors','',...
                        'emails','',...
                        'institution','',...
                        'date','',...
                        'files','',...
                        'signature','');
                    
                    if ~isempty(k{1})
                        ret = filewrapper(ret,k{1}(:,1));
                    end
                case 'defaults'
                    % It must denied to the user to configurate the object's
                    % 'defaults' field by configuration file.
                    
                    % --- Information data.
                    ret = struct(...
                        'title','',...
                        'authors','',...
                        'emails','',...
                        'institution','',...
                        'date','',...
                        'files','',...
                        'signature','');
                    
                    k = fileopener(obj.meta.dftfile,'-m','<projects>','</projects>');
                    k = fileopener(k{1}(:,1),'-m','<defaults>','</defaults>');
                    
                    if ~isempty(k{1})
                        ret = filewrapper(ret,k{1}(:,1));
                    end
                case 'models'
                    mdls = cell(size(k{1},2),1);
                    for jj = 1:size(mdls,1)
                        mdls{jj} = k{1}(:,jj);
                    end
                    ret = feval('astratto',mdls{:});
                case 'simulations'
                    mdls = cell(size(k{1},2),1);
                    for jj = 1:size(mdls,1)
                        mdls{jj} = k{1}(:,jj);
                    end
                    ret = feval('vero',mdls{:});
                case 'UIs'
                    mdls = cell(size(k{1},2),1);
                    for jj = 1:size(mdls,1)
                        mdls{jj} = k{1}(:,jj);
                    end
                    ret = feval('viso',mdls{:});
                case 'reports'
                    mdls = cell(size(k{1},2),1);
                    for jj = 1:size(mdls,1)
                        mdls{jj} = k{1}(:,jj);
                    end
                    ret = feval('parlo',mdls{:});
                case 'drawings'
                    mdls = cell(size(k{1},2),1);
                    for jj = 1:size(mdls,1)
                        mdls{jj} = k{1}(:,jj);
                    end
                    ret = feval('dfvfvwerv',mdls{:});
                otherwise
                    continue;
            end
            
            obj.(fds{ii}) = ret;
        catch ERR
            %ERR.message
            %error(['+libncl.@progetto.config: ' ERR.message]);
        end
    end
end
