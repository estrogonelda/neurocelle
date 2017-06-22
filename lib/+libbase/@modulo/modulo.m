classdef modulo < handle

% +LIBBASE.@MODULO Summary of this class goes here
%   Detailed explanation goes here


    properties
        meta
        id
    end
    
    methods
        % --- Constructor function.
        function obj = modulo(varargin)
            try
                % Library import.
                import('libbase.*');
                
                % Modules must be initialized with configuration file paths.
                if nargin
                    
                end
                
                % Metadata must be initialized by default.
                obj.meta = metadata(varargin{:});
            catch ERR
                error(['+libbase.@modulo: ' ERR.message]);
            end
        end
        
        % --- Member functions.
        % Handle objects don't need return arguments.
        config(obj,varargin)
        validate(obj,varargin);
        loader(obj,varargin);
    end
    
    methods (Static)
        output = supervisor(value,truth_list,condition,val_type,ret_num,varargin)
    end
end
