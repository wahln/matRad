function c = matRad_constraintFunctions(optiProb,w,dij,cst)
% matRad IPOPT callback: constraint function for inverse planning 
% supporting max dose constraint, min dose constraint, min mean dose constraint, 
% max mean dose constraint, min EUD constraint, max EUD constraint, 
% max DVH constraint, min DVH constraint 
% 
% call
%   c = matRad_constraintFunctions(optiProb,w,dij,cst)
%
% input
%   optiProb:   option struct defining the type of optimization
%   w:          bixel weight vector
%   dij:        dose influence matrix
%   cst:        matRad cst struct
%
% output
%   c:          value of constraints
%
% References
%   -
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Copyright 2016 the matRad development team.
%
% This file is part of the matRad project. It is subject to the license
% terms in the LICENSE file found in the top-level directory of this
% distribution and at https://github.com/e0404/matRad/LICENSES.txt. No part
% of the matRad project, including this file, may be copied, modified,
% propagated, or distributed except according to the terms contained in the
% LICENSE file.
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% get current dose / effect / RBExDose vector
%d = matRad_backProjection(w,dij,optiProb);
optiProb.BP.compute(dij,w);
d = optiProb.BP.GetResult();

% Initializes constraints
cDose = [];
cOmega = [];

% compute objective function for every VOI.
for  i = 1:size(cst,1)
    
    % Only take OAR or target VOI.
    if ~isempty(cst{i,4}{1}) && ( isequal(cst{i,3},'OAR') || isequal(cst{i,3},'TARGET') )
        
        % loop over the number of constraints for the current VOI
        for j = 1:numel(cst{i,6})
            
            constraint = cst{i,6}{j};
            
            % only perform computations for constraints
            % if ~isempty(strfind(obj.type,'constraint'))
            if isa(constraint,'DoseConstraints.matRad_DoseConstraint')
                
                % rescale dose parameters to biological optimization quantity if required
                constraint = optiProb.BP.setBiologicalDosePrescriptions(constraint,cst{i,5}.alphaX,cst{i,5}.betaX);
                
                % if conventional opt: just add constraints of nominal dose
                %if strcmp(cst{i,6}(j).robustness,'none')
                
                %d_i = d{1}(cst{i,4}{1});
                
                %c = [c; matRad_constFunc(d_i,cst{i,6}(j),d_ref)];
                   
                
                switch constraint.robustness
                    case 'none' % if conventional opt: just sum objectives of nominal dose
                        d_i = d{1}(cst{i,4}{1});                        
                        cDose = [cDose; constraint.computeDoseConstraintFunction(d_i)];
                    case 'PROB' % if prob opt: sum up expectation value of objectives
                        
                        %Not supported so far
                        matRad_cfg.dispError('Robustness setting %s not supported!',constraint.robustness);
                        
                        if ~exist('dExp','var')
                            optiProb.BP.computeProb(dij,w);
                            [dExp,~,vTot] = optiProb.BP.GetResultProb();
                        end
                        
                        d_i = dExp{1}(cst{i,4}{1});
                        cDose = [cDose; constraint.computeDoseConstraintFunction(d_i)];
                    otherwise
                        matRad_cfg.dispError('Robustness setting %s not supported!',constraint.robustness);
                end
                
                
                % if rob opt: add constraints of all dose scenarios
                %{
                elseif strcmp(cst{i,6}(j).robustness,'probabilistic') || strcmp(cst{i,6}(j).robustness,'VWWC') || strcmp(cst{i,6}(j).robustness,'COWC')
                
                for k = 1:options.numOfScenarios
                    
                    d_i = d{k}(cst{i,4}{1});
                    
                    c = [c; matRad_constFunc(d_i,cst{i,6}(j),d_ref)];
                    
                end
                
                
            else
                %}
            elseif isa(constraint,'OmegaConstraints.matRad_OmegaConstraint')
                % rescale dose parameters to biological optimization quantity if required
                constraint = optiProb.BP.setBiologicalDosePrescriptions(constraint,cst{i,5}.alphaX,cst{i,5}.betaX);
                robustness = constraint.robustness;                
                
                %Force PROB
                switch robustness
                    case 'PROB'
                        if ~exist('vTot','var')
                            optiProb.BP.computeProb(dij,w);
                            [dExp,~,vTot] = optiProb.BP.GetResultProb();
                        end
                        cOmega = [cOmega; constraint.computeTotalVarianceConstraint(vTot{i,1},numel(cst{i,4}{1}))];
                        %f = f + p * w' * dOmega{i,1};
                    otherwise
                        matRad_cfg.dispError('Robustness setting %s not supported for Omega-Objectives!',robustness);
                end
            else
                %Do Nothing    
            end % if we are a constraint
            
        end % over all defined constraints & objectives
        
    end % if structure not empty and oar or target
    
end % over all structures

c = [cDose; cOmega];
