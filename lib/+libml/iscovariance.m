function status = iscovariance(mtx)

% Verify wether a input matrix is simetric or not.


    % Failure exit status.
    status = 0;
    
    % Validity verification.
    if ~isempty(mtx) && issimetric(mtx)% && all(mtx(:) >= 0)
        % Success return status;
        status = 1;
    end
end
