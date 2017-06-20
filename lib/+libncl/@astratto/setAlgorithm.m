function setAlgorithm(obj,varargin)

% SETDATA Summary of this function goes here
%   Detailed explanation goes here


    try
        % Insert data.
        switch nargin-1
            case 0
                
            case 1
                obj.data.inputs = eval(varargin{1});
            case 2
                obj.data.inputs = varargin{1};
                obj.data.targets = varargin{2};
            case 3
                obj.data.inputs = varargin{1};
                obj.data.targets = varargin{2};
                obj.data.outputs = varargin{3};
                obj.data.errors = obj.data.targets - obj.data.outputs;
            case 4
                obj.data.inputs = varargin{1};
                obj.data.targets = varargin{2};
                obj.data.outputs = varargin{3};
                obj.data.errors = obj.data.targets - obj.data.outputs;
                obj.data.statistics = obj.setstats(varargin{4});
            otherwise
                error('Invalid number of inputs.');
        end
        
        % Data indentity initialization.
        num = num2str(round(1e8*rand));
        obj.data.id = ['dat-' num(end:-1:end-5)];
    catch ERR
        error(['@astratto.setAlgorithm: ' ERR.message]);
    end
end
