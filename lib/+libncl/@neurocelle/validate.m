function validate(obj,varargin)

% +LIBNCL.@NEUROCELLE.VALIDATE - Summary of this function goes here
%   Detailed explanation goes here


    % Importing libraries.
    import('libbase.*');
    
    try
        % --- User specific loadings.
        obj.users = user(obj.software.rootpath,'Anonimous'); % Can't get an error here.
        obj.log = err(obj.users); % Write 'log' file.
        
        % --- Essential Modules loadings.
        % Processes control module.
        obj.modules = cat(1,obj.modules,obj.loadmod(obj.software.proc_manager));
        obj.processes = obj.modules{end};
        
        % Interfaces control module.
        obj.modules = cat(1,obj.modules,obj.loadmod(obj.software.UI_manager));
        obj.interfaces = obj.modules{end};
    catch ERR
        error(['+libncl.@neurocelle.validate: ' ERR.message]);
    end
end
