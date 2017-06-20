function setobj(obj,varargin)

%SETOBJ Summary of this function goes here
%   Detailed explanation goes here


    try
        if nargin == 1
            % Memory allocation.
            obj.objects(numel2(obj.algorithms),numel2(obj.params.general.model_type)).oid = ...
                [obj.mid '-obj-' num2str(round(1e4*rand))];
        else
            % Library importing.
            import('libml.*');
            
            % Adusting models list.
            alg = obj.algorithms;
            mdl = obj.params.general.model_type;
            if ischar(alg), alg = {alg}; end
            if ischar(mdl), mdl = {mdl}; end
            for jj = 1:numel2(mdl)
                for ii = 1:numel2(alg)
                    'dre'
                    [ii jj]
                    switch mdl{jj}
                        case 'regression'
                            obj.objects(ii,jj).design = .05;
                            obj.objects(ii,jj).params_names = {'ponga' 'mierd' 'as'};
                            obj.objects(ii,jj).params_data = [1 2 5];
                            obj.objects(ii,jj).records = [];
                        case 'ann'
                            % ARCHmkr can be called in two ways:
                            %   With an object arguments;
                            %   With a struct, a design vector and a design
                            %   unit.
                            dsgn_vct = obj.params.general.design_vct;
                            dsgn_vct(~obj.params.general.design_mask) = 1;
                            dsgn_vct(1,:) = obj.params.general.design_vct(1,:);
                            
                            % Calling with struct argument.
                            obj.objects(ii,jj) = ARCHmkr(obj.params.ann,dsgn_vct,obj.params.general.design_archs{ii});
                            
                            % Object identification.
                            obj.objects(ii,jj).oid = ...
                                [obj.mid '-obj-' num2str(round(1e4*rand))];
                            obj.objects(ii,jj).type = [obj.params.ann.ann_type ' ann'];
                        case 'svm'
                            2
                        case 'bayesian'
                            3
                        case 'markov_chain'
                            
                        case 'fuzzy'
                            6
                        otherwise
                            % Custom.
                            4
                    end
                end
            end
        end
    catch ERR
        error(['@astratto.setobj: ',ERR.message]);
    end
end
