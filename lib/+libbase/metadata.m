classdef metadata < handle

% Metadata object.


    properties
        name
        extension
        rootdir = '/home/leonel/Dropbox/Scientific Initiation/Matlab Ultimate - Leonel/Matlab Laboratory/machine-workbench/neurocelle/';
        dftfile = '/home/leonel/Dropbox/Scientific Initiation/Matlab Ultimate - Leonel/Matlab Laboratory/machine-workbench/neurocelle/cfg/default.conf';
        user = 'Anonimous';
    end
    
    methods
        % --- Constructor function.
        function obj = metadata(varargin)
            try
                if nargin
                    % Something.
                end
            catch ERR
                error(['+libbase.@metadata: ' ERR.message]);
            end
        end
    end
end
