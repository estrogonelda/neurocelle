function output = condition(str,x)

% CONDITION - Summary of this function goes here
%   Here, 'var' must be a 'char' type.


    output = false;
    
    try
        output = eval(str);
    catch ERR
        %ERR.message
    end
end
