function [EXT, varargout] = argsVal (strGuide, varargin)

% Validate arguments.


    % Exit status.
    EXT = false;
    
    % Import library.
    import('libflmgr.*');
    
    % sgfbbr
    try
        if ~nargin || ~isstruct(strGuide)
            error('Function ''argsval'' need a input arguments guide struct as the first argument.');
        end
        
        % Required input and output arguments counter.
        fds = fields(strGuide);
        counter = zeros(size(fds),'uint8');
        outcounter = 0;
        
        % Count arguments by it's classes.
        for jj = 1:numel(varargin)
            if any(strcmp(fds,class(varargin{jj})))
                counter(strcmp(fds,class(varargin{jj}))) ...
                = counter(strcmp(fds,class(varargin{jj}))) + 1;
                
                strGuide(1).(fds{strcmp(fds,class(varargin{jj}))}).positions ...
                    = cat(2,strGuide(1).(fds{strcmp(fds,class(varargin{jj}))}).positions,jj);
            end
        end
        
        
        for ii = 1:numel(fds)
            if ~(strGuide(1).(fds{ii}).number == 0 && strGuide(1).(fds{ii}).required == 0)
                % Limit number of valid inputs.
                if strGuide(1).(fds{ii}).number ...
                        && strGuide(1).(fds{ii}).number < strGuide(1).(fds{ii}).required
                    error(['Inconsistent ''strGuide'' for input argument of type ''' fds{ii} '''.']);
                elseif strGuide(1).(fds{ii}).number && counter(ii)
                    counter(ii) = min(strGuide(1).(fds{ii}).number,counter(ii));
                    strGuide(1).(fds{ii}).positions = strGuide(1).(fds{ii}).positions(1:counter(ii));
                end
                
                % Verify required input arguments presence.
                if strGuide(1).(fds{ii}).required ...
                        && ((strGuide(1).(fds{ii}).number == 0 && counter(ii)) ...
                        || (strGuide(1).(fds{ii}).number > 0 && strGuide(1).(fds{ii}).required > counter(ii)))
                    error(['Missing required argument for input arguments of type ''' fds{ii} '''.']);
                end
                
                % Verify conditions and positions numbers.
                if counter(ii) > numel(strGuide(1).(fds{ii}).conditions)
                    error(['Missing condition for input arguments of type ''' fds{ii} '''.']);
                end
                
                % Verify classes types, emptyness and templates.
                for jj = 1:counter(ii)
                    if isempty(varargin{strGuide(1).(fds{ii}).positions(jj)})
                        error(['Empty argument for input arguments of type ''' fds{ii} ...
                            ''', at position ' num2str(strGuide(1).(fds{ii}).positions(jj)) '.']);
                    end
                    
                    % Verify inputs arguments' conditions.
                    if ~eval(strGuide(1).(fds{ii}).conditions{jj});
                        error(['Condition not attended in input arguments of type ''' fds{ii} ...
                            ''', at position ' num2str(strGuide(1).(fds{ii}).positions(jj)) '.']);
                    end
                    
                    % Verify templates adequacy for 'struct' type.
                    if strcmp(fds{ii},'struct')
                        if counter(ii) > numel(strGuide(1).(fds{ii}).templates)
                            error(['Missing template in input arguments of type ''struct''' ...
                                ', at position ' num2str(strGuide(1).(fds{ii}).positions(jj)) '.']);
                        end
                        
                        if ~isempty(strGuide(1).(fds{ii}).templates{jj}) ...
                                && ~isequal(fields(strGuide(1).(fds{ii}).templates{jj}), ...
                                fields(varargin{strGuide(1).(fds{ii}).positions(jj)}))
                            error(['Unmatched template for input arguments of type ''struct''' ...
                                ', at position ' num2str(strGuide(1).(fds{ii}).positions(jj)) '.']);
                        end
                    end
                end
            end
            
            
            % Verify output arguments.
            if strGuide(2).(fds{ii}).required
                outcounter = outcounter + strGuide(2).(fds{ii}).required;
            end
        end
        
        if nargout-1 < outcounter
            error('Missing required output argument.');
        end
        
        % Do transformations on inputs to the outputs.
        for ii = 1:numel(fds)
            % Verify inputs arguments' conditions.
            %if ~eval(strGuide(2).(fds{ii}).conditions{jj});
            %    error(['Not attended condition in argument ' num2str(jj) ' of type ''' fds{ii} '''.']);
            %end
            
            % werfvw
        end
        
        
        % Returning code.
        EXT = strGuide;
        return;
    catch ERR
        if any(strcmp(varargin,'verbose'))
            screen(['argsval: ' ERR.message],'ferr','');
        end
        
        varargout(1:nargout-1) = {[]};
        return;
    end
    
    % Return a success value.
    EXT = ~EXT;
end
