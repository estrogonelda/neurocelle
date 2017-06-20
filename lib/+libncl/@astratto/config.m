function config(obj,varargin)

% CONFIG Summary of this function goes here
%   Detailed explanation goes here


    % Library import.
    import('libflmgr.*');
    import('libml.*');
    
    fds = properties(obj);
    for ii = 1:size(fds,1)
        try
            k = fileopener(varargin{1},'-m',['<' fds{ii} '>'],['</' fds{ii} '>']);
            ret = [];
            
            switch fds{ii}
                case 'info'
                    ret = getInfoStr;
                    
                    if ~isempty(k{1})
                        ret = filewrapper(ret,k{1}(:,1));
                    end
                case 'data'
                    ret = getDataStr;
                case 'statistics'
                    ret = getStatStr;
                case 'parameters'
                    ret = getParamStr;
                    
                    if ~isempty(k{1})
                        ret(1:size(k{1},2)) = getParamStr;
                        
                        % Sequencial params loadings.
                        for jj = 1:size(k{1},2)
                            ret(jj) = filewrapper(getParamStr,k{1}(:,jj));
                            ret(jj) = filewrapper(getParamStr(ret(jj).general.model_type,ret(jj).general.design_type),k{1}(:,jj));
                        end
                    end
                case 'objects'
                    ret = getObjStr;
                    ret(1:size(obj.parameters,2)) = getObjStr;
                case 'defaults'
                    % It must be denied to the user to configure the object's
                    % 'defaults' field by configuration file.
                    
                    % Extract information from default configuration file.
                    k = fileopener(obj.meta.dftfile,'-m','<models>','</models>');
                    k = fileopener(k{1}(:,1),'-m','<defaults>','</defaults>');
                    k_info = fileopener(k{1}(:,1),'-m','<info>','</info>');
                    k_stat = fileopener(k{1}(:,1),'-m','<statistics>','</statistics>');
                    k_param = fileopener(k{1}(:,1),'-m','<parameters>','</parameters>');
                    
                    if ~isempty(k{1})
                        % Information data.
                        if ~isempty(k_info{1})
                            info = filewrapper(getInfoStr,k_info{1}(:,1));
                        else
                            info = getInfoStr;
                        end
                        
                        % Statistics data.
                        if ~isempty(k_stat{1})
                            stat = filewrapper(getStatStr,k_stat{1}(:,1));
                        else
                            stat = getStatStr;
                        end
                        
                        % Parameters data.
                        if ~isempty(k_param{1})
                            param(1:size(k_param{1},2)) = getParamStr;
                            
                            % Sequencial params loadings.
                            for jj = 1:size(k_param{1},2)
                                param(jj) = filewrapper(getParamStr,k_param{1}(:,jj));
                                param(jj) = filewrapper(getParamStr(param(jj).general.model_type,param(jj).general.design_type),k_param{1}(:,jj));
                            end
                        else
                            param = getParamStr;
                        end
                        
                        % Complete default data structure.
                        ret = struct(...
                            'info',info,...
                            'statistics',stat,...
                            'parameters',param);
                    else
                        ret = struct(...
                            'info',getInfoStr,...
                            'statistics',getStatStr,...
                            'parameters',getParamStr);
                    end
                case 'meta'
                    % It must be denied to the user to configure the object's
                    % 'meta' field by configuration file.
                    
                    k = fileopener(obj.meta.dftfile,'-m','<models>','</models>');
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
            %error(['@astratto.config: ',ERR.message]);
        end
    end
end
