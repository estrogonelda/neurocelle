classdef anima < handle

% +LIBBASE.@ANIMA - Summary of this class goes here
%   Detailed explanation goes here


    properties
        users
    end
    
    properties% (Hidden)
        software
        modules
        processes
        interfaces
        log
        id
    end
    
    properties (Hidden)
        flags
        cmds
    end
    
    methods
        % --- Constructor function.
        function obj = anima(varargin)
            try
                if nargin
                    
                end
            catch ERR
                error(['+libbase.@anima: ' ERR.message]);
            end
        end
        
        % --- Member functions.
        checkout(obj,varargin)
        config(obj,varargin)
        validate(obj,varargin)
        output = loadmod(obj,varargin)
    end
end
