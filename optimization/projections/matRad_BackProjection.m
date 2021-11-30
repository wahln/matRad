classdef matRad_BackProjection < handle
% matRad_BackProjection superclass for all backprojection algorithms 
% used within matRad optimzation processes
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Copyright 2019 the matRad development team. 
% 
% This file is part of the matRad project. It is subject to the license 
% terms in the LICENSE file found in the top-level directory of this 
% distribution and at https://github.com/e0404/matRad/LICENSES.txt. No part 
% of the matRad project, including this file, may be copied, modified, 
% propagated, or distributed except according to the terms contained in the 
% LICENSE file.
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
    properties (SetAccess = protected)
        wCache
        wCacheProb
        wGradCache  %different cache for optimal performance (if multiple evaluations of objective but not gradient are required)
        wGradCacheProb
        d
        wGrad
        wGradProb
        dExp
        dOmegaV
        vTot
    end
    
    properties 
        dij                 %reference to matRad dij struct (to enable local changes)
        scenarios    = 1    %Scenario indices to evaluate (used for 4D & robust/stochastic optimization)
        scenarioProb = 1    %Probability associated with scenario (for stochastic optimization)
    end

    
    methods
        function obj = matRad_BackProjection()
            obj.wCache = [];
            obj.wCacheProb = [];
            obj.wGradCache = [];
            obj.wGradCacheProb = [];
            obj.d = [];
            obj.dExp = [];
            obj.dOmegaV = [];
            obj.wGrad = [];            
            obj.wGradProb = [];
            obj.vTot = [];
        end       
        
        function obj = compute(obj,dij,w)
            if ~isequal(obj.wCache,w)
                obj.d = obj.computeResult(dij,w);
                obj.wCache = w;                
            end
        end
        
        function obj = computeProb(obj,dij,w)
            if ~isequal(obj.wCacheProb,w)
                [obj.dExp,obj.dOmegaV,obj.vTot] = obj.computeResultProb(dij,w);
            end
        end
               
        function obj = computeGradient(obj,dij,doseGrad,w)
            if ~isequal(obj.wGradCache,w)
                obj.wGrad = obj.projectGradient(dij,doseGrad,w);
                obj.wGradCache = w;
            end
        end
        
        function obj = computeGradientProb(obj,dij,doseGrad,vOmegaGrad,w)
            if ~isequal(obj.wGradCacheProb,w)
                obj.wGradProb = obj.projectGradientProb(dij,doseGrad,vOmegaGrad,w);
                obj.wGradCacheProb = w;
            end
        end
        
        function d = GetResult(obj)
            d = obj.d;
        end
        
        function [dExp,dOmegaV,vTot] = GetResultProb(obj)
            dExp = obj.dExp;
            dOmegaV = obj.dOmegaV;
            vTot = obj.vTot;
        end

        function wGrad = GetGradient(obj)
            wGrad = obj.wGrad;
        end
        
        function wGrad = GetGradientProb(obj)
            wGrad = obj.wGradProb;
        end
        
        function d = computeResult(obj,dij,w)
            d = cell(size(dij.physicalDose));
            d(obj.scenarios) = arrayfun(@(scen) computeSingleScenario(obj,dij,scen,w),obj.scenarios,'UniformOutput',false);
        end
        
        function [dExp,dOmegaV,vTot] = computeResultProb(obj,dij,w)
            if isfield(dij,'physicalDoseExp')
                dExp = cell(size(dij.physicalDoseExp));
                [dExp(obj.scenarios),dOmegaVTmp,vTotTmp] = arrayfun(@(scen) computeSingleScenarioProb(obj,dij,scen,w),obj.scenarios,'UniformOutput',false);
                dOmegaV = cell(size(dij.physicalDoseOmega));
                vTot = cell(size(dij.physicalDoseOmega));
                dOmegaV(:,obj.scenarios) = dOmegaVTmp{:};
                vTot(:,obj.scenarios) = vTotTmp{:};
            else
                dExp = [];
                dOmegaV = [];
                vTot = [];
            end
        end
        
        function wGrad = projectGradient(obj,dij,doseGrad,w)
            wGrad = cell(size(dij.physicalDose));
            wGrad(obj.scenarios) = arrayfun(@(scen) projectSingleScenarioGradient(obj,dij,doseGrad,scen,w),obj.scenarios,'UniformOutput',false);         
        end
        
        function wGrad = projectGradientProb(obj,dij,dExpGrad,dOmegaVgrad,w)
            wGrad = cell(size(dij.physicalDose));
            wGrad(obj.scenarios) = arrayfun(@(scen) projectSingleScenarioGradientProb(obj,dij,dExpGrad,dOmegaVgrad,scen,w),obj.scenarios,'UniformOutput',false);
        end
    end
   
    
    %These should be abstract methods, however Octave can't parse them. As soon 
    %as Octave is able to do this, they should be made abstract again 
    methods %(Abstract)
        function d = computeSingleScenario(obj,dij,scen,w)
            error('Function needs to be implemented');
        end
        
        function wGrad = projectSingleScenarioGradient(obj,dij,doseGrad,scen,w)
            error('Function needs to be implemented');
        end
        
        function [dExp,dOmegaV,vTot] = computeSingleScenarioProb(obj,dij,scen,w)
            %warning('');
        end
        
        function [dExp,dOmegaV,vTot] = projectSingleScenarioGradientProb(obj,dij,dExpGrad,dOmegaVgrad,scen,w)
            %warning('');
        end
    end
    
    methods (Static)
        function optiFunc = setBiologicalDosePrescriptions(optiFunc,alphaX,betaX)
            %Does nothing in a usual normal setting but return the original
            %optiFunc
        end
    end
end

