classdef neurocelle < libbase.anima

% +LIBNCL.@NEUROCELLE - Create a 'neurocelle' object for simulation processes.


    properties
        projects
    end
    
    methods
        % --- Constructor function.
        function obj = neurocelle(varargin)
            try
                if nargin
                    % Software essential loadings.
                    obj.config(varargin{:});
                    
                    % Validation of properties' values.
                    obj.validate;
                    
                    % Software runtime indentity initialization.
                    num = num2str(round(1e8*rand));
                    obj.id = ['ncl-' num(end:-1:end-5)];
                end
            catch ERR
                error(['+libncl.@neurocelle: ' ERR.message]);
            end
        end
        
        % --- Member functions.
        %checkout(obj,varargin)
        %config(obj,varargin)
        validate(obj,varargin)
    end
end
