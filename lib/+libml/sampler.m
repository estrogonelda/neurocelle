function output = sampler(num,prop,rep,opt)

% SAMPLER - Summary of this function goes here
%   Detailed explanation goes here


    % =======================> PREAMBLE <=======================================
    
    % --- Macro Definitions.
    % Success exit status.
    %EXT = 0;
    
    
    % --- Library importing.
    import('libml.*');
    
    
    % --- Variable declarations.
    % Output declaration.
    output = {};
    
    % Pick the state of the random seed generator.
    prev_seed = rng('shuffle');
    
    % The 'opt' argument is used to allow repetitions or not.
    
    
    if nargin == 3
        conditions = false(4,1);
        conditions(1) = nargin == 3;
        conditions(2) = isnumeric(num) && numel(num) == 1 && ~mod(num,1) && num > 0;
        conditions(3) = ((isnumeric(prop) && size(prop,1) == 1 && sum(prop) <= 1 && all(prop > 0) && all(floor(num*prop) > 0)) ...
                || (isnumeric(prop) && size(prop,1) == 1 && sum(prop) <= num && all(prop > 0) && all(~mod(prop,1))) );
        conditions(4) = isnumeric(rep) && numel(rep) == 1 && ~mod(rep,1) && rep > 0;
    end
    
    
    % =======================> FUNCTION CODE <==================================
    
    try
        if all(conditions)
            % Allocating memory.
            output = cell(1,numel(prop));
            
            % Shuffling an original vector of values.
            vct = zeros(rep,num);
            for ii = 1:rep
                vct(ii,:) = randperm(num,num);
            end
            
            % Mount output.
            if sum(prop) <= 1
                % Decimal proportions.
                k = zeros(1,numel(prop));
                [~, major] = max(prop*num - floor(prop*num));
                for ii = 1:numel(prop)
                    if ii == major
                        output{ii} = zeros(rep,ceil(prop(ii)*num));
                        k(ii) = ceil(prop(ii)*num);
                    else
                        output{ii} = zeros(rep,floor(prop(ii)*num));
                        k(ii) = floor(prop(ii)*num);
                    end
                    
                    output{ii} = vct(:, sum(k(1:ii-1))+1:sum(k(1:ii)) );
                end
            else
                for ii = 1:numel(prop)
                    vct(ii,:) = randperm(num,num);
                    output{ii} = zeros(rep,prop(ii));
                    output{ii} = vct(:, sum(prop(1:ii-1))+1:sum(prop(1:ii)) );
                end
            end
        else
            error('Invalid inputs.');
        end
    catch ERR
        error(['+libml.sampler: ' ERR.message]);
    end
    
    % Restore random seed generator to it's original state.
    rng(prev_seed);
end
