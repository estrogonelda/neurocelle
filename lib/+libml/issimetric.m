function status = issimetric(mtx)

% Verify wether a input matrix is simetric or not.


    % Failure return status.
    status = 0;
    
    % Control param.
    ctrl = true;
    
    % Square verification.
    if ~isempty(mtx) && size(mtx,1) == size(mtx,2)
        for ii = 2:size(mtx,1);
            if ~all(floor(mtx(ii,1:ii-1)*1e4) == floor(mtx(1:ii-1,ii)'*1e4)), ctrl = ~ctrl; break; end
        end
        
        % Success return status;
        if ctrl
            status = 1;
        end
    end
end
