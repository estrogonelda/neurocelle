function status = iscorrelation(mtx)

% Verify wether a input matrix is simetric or not.


    % Failure return status.
    status = 0;
    
    % Validity verification.
    if ~isempty(mtx) && issimetric(mtx) && all(diag(mtx) == 1) && all(mtx(:) <= 1) && all(mtx(:) >= -1)
        % Success return status;
        status = 1;
    end
end
