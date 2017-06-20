function output = designer(obj,full_dsgn,design,param)

% DESIGNER - Summary of this function goes here
%   Detailed explanation goes here


    % Output.
    output = [];
    
    num = 1;
    if ~isempty(param)
        num = obj.parameters(param).general.num_iterations;
    end
    
    % Adjust input.
    algs = {'random' 'exaustive' 'designed'};
    if ~any(strcmp(algs,design))
        design = 'random';
    end
    
    try
        switch design
            case 'random'
                % With repetitions.
                output = sort(randi(prod(full_dsgn),[1 min(num,prod(full_dsgn))],'uint32'));
                % Without repetitions.
                %output = uint32(randperm(prod(full_dsgn),prod(full_dsgn)));
            case 'exaustive'
                output = uint32(1:min(num,prod(full_dsgn)));
            case 'designed'
                % Mounting design factors extracting the ones which have
                % only one level. And, there most be at least one factor
                % with more than one level.
                aux_dsgn = ff2n(size(full_dsgn,1) - sum(full_dsgn == 1)) + 1;
                k = find(full_dsgn == 1);
                dsgn = ones(size(aux_dsgn,1),size(full_dsgn,1),'uint32');
                
                count = 1;
                for jj = 1:size(full_dsgn,1)
                    if any(jj == k(:))
                        continue;
                    end
                    
                    dsgn(:,jj) = aux_dsgn(:,count);
                    count = count + 1;
                end
                dsgn = astratto.masker(full_dsgn,dsgn');
                
                % Returns.
                output = dsgn(1:min(obj.params.general.num_iterations,size(dsgn,2)));
            otherwise
                % Search for a custom designer function.
                output = uint32([]);
        end
    catch ERR
        error(['@astratto.designer: ',ERR.message]);
    end
end
