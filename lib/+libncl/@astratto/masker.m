function output = masker(full_dsgn,desired_dsgn)

% -------------
%
%
%


    output = [];
    
    try
        % Testing inputs consistency.
        if ~(isnumeric(full_dsgn) && ~isempty(full_dsgn) && all(full_dsgn >= 0) && all(~mod(full_dsgn,1)) && size(full_dsgn,2) == 1 ...
                && isnumeric(desired_dsgn) && ~isempty(desired_dsgn) && all(desired_dsgn(:) >= 0) && all(~mod(desired_dsgn(:),1)) ... && size(desired_dsgn,2) == 1 ...
                && (size(full_dsgn,1) == size(desired_dsgn,1) || size(desired_dsgn,1) == 1))
            error('Invalid inputs.');
        end
        
        % Extract and adjust non maskerade params.
        full = double(full_dsgn);
        desired = double(desired_dsgn);
        
        if size(full,1) == size(desired,1)
            vct = zeros(1,size(desired,2),'uint32');
        else
            vct = zeros(size(full,1),size(desired,2),'uint32');
        end
        
        % Calculating indexes.
        for ii = 1:size(desired,2)
            acm = 0;
            if size(full,1) == size(desired,1) && all(desired(:,ii) <= full)
                for jj = size(full,1):-1:1
                    if jj == 1
                        acm = acm + desired(jj,ii);
                    else
                        acm = acm + (desired(jj,ii)-1)*prod(full(1:jj-1));
                    end
                end
                
                vct(ii) = acm;
            elseif size(full,1) ~= size(desired,1) && all(desired_dsgn(:) <= prod(full))
                acm = desired(ii);
                for jj = size(full,1):-1:1
                    if jj == 1
                        if acm
                            vct(jj,ii) = acm;
                        else
                            vct(jj,ii) = full(jj);
                        end
                    else
                        quocient = floor(acm/prod(full(1:jj-1)));
                        acm = mod(acm,prod(full(1:jj-1)));
                        
                        if quocient && acm
                            vct(jj,ii) = quocient + 1;
                        elseif quocient
                            vct(jj,ii) = quocient;
                        elseif acm
                            vct(jj,ii) = 1;
                        else % ~(quocient && acm) is true here!
                            vct(jj,ii) = full(jj);
                            acm = prod(full(1:jj-1));
                        end
                    end
                end
            else
                error('Inconsistent matrix elements.');
            end
        end
        
        % Return values.
        output = vct;
    catch ERR
        error(['@astratto.masker: ',ERR.message]);
    end
end
