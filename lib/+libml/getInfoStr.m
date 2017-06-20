function output = getInfoStr(varargin)

% GETDATA Summary of this function goes here
%   Detailed explanation goes here


    % --- Information data.
    output = struct(...
        'problem','',...
        'configfile','',...
        'datafile','',...
        'objfile','',...
        'pre_processfcn','',...
        'processfcn','',...
        'post_processfcn','');
    
    
    if nargin == 0
        return;
    else
        % Error output: empty array.
        output = [];
    end
end
