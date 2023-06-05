classdef matRad_TotalVariance < OmegaObjectives.matRad_OmegaObjective
    %MATRAD_MINTOTALVARIANCE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name = 'Min. Total Variance';
        parameterNames = {};
        parameterTypes = {};
    end
    
    properties
        parameters = {};
        penalty = 1;
        robustness = 'PROB';
    end
    
    methods
        function obj = matRad_TotalVariance()
        end
        
        function f = computeTotalVarianceObjective(obj,totVariance,nVoxels)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            f = obj.penalty/nVoxels * totVariance;
        end
        
        
        function g = computeTotalVarianceGradient(obj,~,nVoxels)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            g = obj.penalty/nVoxels;
        end
    end
end

