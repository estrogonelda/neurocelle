function str = greetings(varargin)

% drfvwe


    % Library import.
    import('libflmgr.*');
    
    stdWidth = 79;
    stdChar = '*';
    nl = sprintf('\n');
    str = '';
    
    %title = 'NEUROCELLE';
    %subtitle = 'A Machine Learning Approach!';
    %vs = 'v0.1';
    title = varargin{1};
    subtitle = varargin{2};
    vs = varargin{3};
    
    
    % Greretings string construction.
    str = [str printWidth(stdWidth, stdChar) nl];
    str = [str '*' printWidth(29, ' ') title printWidth(stdWidth-(30+size(title, 2)+1), ' ') '*' nl];
    str = [str '*' printWidth(19, ' ') subtitle printWidth(stdWidth-(20+size(subtitle, 2)+1), ' ') '*' nl];
    str = [str printWidth(stdWidth, stdChar) nl];
    str = [str printWidth(stdWidth-size(vs, 2), ' ') vs nl];
end
