function output = numel2(input)

%NUMEL2 Summary of this function goes here
%   Detailed explanation goes here


    output = 0;
    if iscell(input) || isnumeric(input) || isstruct(input) || isobject(input)
        output = numel(input);
    elseif ischar(input)
        output = 1;
    end
end
