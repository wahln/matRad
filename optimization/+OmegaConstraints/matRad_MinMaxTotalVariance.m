classdef matRad_MinMaxTotalVariance < OmegaConstraints.matRad_OmegaConstraint
    %MATRAD_MINTOTALVARIANCE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name = 'Min/Max Total Variance';
        parameterNames = {'\sum{v}^{min}', '\sum{v}^{max}'};
        parameterTypes = {'totalVariance','totalVariance'};
    end
    
    properties
        parameters = {0,5};
        robustness = 'PROB';
    end
    
    methods
        function obj = matRad_MinMaxTotalVariance(minVariance,maxVariance)
            %If we have a struct in first argument
            if nargin == 1 && isstruct(minVariance)
                inputStruct = minVariance;
                initFromStruct = true;
            else
                initFromStruct = false;
                inputStruct = [];
            end
            
            %Call Superclass Constructor (for struct initialization)
            obj@OmegaConstraints.matRad_OmegaConstraint(inputStruct);
            
            %now handle initialization from other parameters
            if ~initFromStruct               
                if nargin >= 2 && isscalar(maxVariance)
                    obj.parameters{2} = maxVariance;
                end
                
                if nargin >= 1 && isscalar(minVariance)
                    obj.parameters{1} = minVariance;
                end
            end
        end
        
        function c = computeTotalVarianceConstraint(obj,totVariance,nVoxels)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            c = totVariance;
        end
        
        
        function j = computeTotalVarianceJacobian(obj,totVariance,nVoxels)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            j = 1;
        end
        
        %Returns upper bound(s) / max value(s) for constraint function(s)
        %Needs to be implemented in sub-classes.
        function cu           = upperBounds(obj)
          cu = obj.parameters{2};          
        end
        
        %Returns lower bound(s) / min value(s) for constraint function(s)
        %Needs to be implemented in sub-classes.
        function cl           = lowerBounds(obj)                
          cl = obj.parameters{1};
        end
    end
end

