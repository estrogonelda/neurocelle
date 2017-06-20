function output = getDataStr(varargin)

% GETDATA Summary of this function goes here
%   Detailed explanation goes here


    % Create 'data' structure.
    output = struct(...
        'inputs',[],...
        'targets',[],...
        'outputs',[],...
        'errors',[],...
        'extra',[],...
        'id',[]);
    
    
    if nargin == 0
        return;
    elseif nargin == 1 && isnumeric(varargin{1}) && ~isempty(varargin{1})
        output.inputs = varargin{1};
        
        % Data indentity initialization.
        num = num2str(round(1e8*rand));
        output.id = ['dat-' num(end:-1:end-5)];
        
    elseif nargin == 2 && isnumeric(varargin{1}) && ~isempty(varargin{1}) ...
            && isnumeric(varargin{2}) && size(varargin{2},1) == size(varargin{1},1)
        output.inputs = varargin{1};
        output.targets = varargin{2};
        
        % Data indentity initialization.
        num = num2str(round(1e8*rand));
        output.id = ['dat-' num(end:-1:end-5)];
        
    elseif nargin == 3 && isnumeric(varargin{1}) && ~isempty(varargin{1}) ...
            && isnumeric(varargin{2}) && size(varargin{2},1) == size(varargin{1},1) ...
            && isnumeric(varargin{3}) && size(varargin{3},1) == size(varargin{1},1)
        output.inputs = varargin{1};
        output.targets = varargin{2};
        output.outputs = varargin{3};
        
        % Data indentity initialization.
        num = num2str(round(1e8*rand));
        output.id = ['dat-' num(end:-1:end-5)];
        
    else
        % Error output: empty array.
        output = [];
    end
end
