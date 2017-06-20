classdef sinergio < libbase.modulo

% +LIBBASE.@SINERGIO Summary of this class goes here
%   Detailed explanation goes here


    properties
        ponga1
        ponga2
    end
    
    methods
        % --- Constructor function.
        function obj = sinergio(varargin)
            try
                if nargin
                    % Library import.
                    import('libflmgr.*');
                    
                    % Module indentity initialization.
                    num = num2str(round(1e7*rand));
                    obj.id = ['sgo-' num(end:-1:end-4)];
                end
            catch ERR
                error(['+libbase.@sinergio: ' ERR.message]);
            end
        end
    end
end
