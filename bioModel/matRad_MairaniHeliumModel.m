classdef matRad_MairaniHeliumModel < matRad_ParticleBioModel
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % data driven parametrization of helium ions https://iopscience.iop.org/article/10.1088/0031-9155/61/2/888 
        %Quadratic Exponential Fit
        qe_p0 = 1.36938e-1;   
        qe_p1 = 9.73154e-3;
        qe_p2 = 1.51998e-2;
        
        %TODO: Possibility to select fits below:
        %Quadratic Fit
        q_p0 = 2.145e-1;
        q_p1 = 8.53959e-4;
        
        %Linear Quadratic Fit
        lq_p0 = 1.42057e-1;
        lq_p1 = 2.91783e-1;
        lq_p2 = 9.525e-4;
        
        %Linear Exponential Fit
        le_p0 = 1.5384e-1;
        le_p1 = 2.965e-1;
        le_p2 = -4.90821e-3;
    end
    
    properties(Constant = true)
       restrictModality = 'protons';
       
       requiredQuantities = {'LET'};
    end
    
    methods
        function obj = matRad_MairaniHeliumModel(machine)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
        end
        
        
        function [bixelAlpha,bixelBeta] = calcLQParameter(obj,vRadDepths,baseDataEntry,~,vAlpha_x,vBeta_x,vABratio)         
            % range shift
            depths = baseDataEntry.depths + baseDataEntry.offset;
            
            bixelLET = matRad_interp1(depths,baseDataEntry.LET,vRadDepths);
            bixelLET(isnan(bixelLET)) = 0;
        
            % the linear quadratic fit yielded the best fitting result
            RBEmax = obj.quadraticExponentialFit(obj,bixelLET,vABratio);
            
            RBEmin = 1; % no gain in using fitted parameters over a constant value of 1
            
            bixelAlpha = RBEmax    .* vAlpha_x;
            bixelBeta  = RBEmin.^2 .* vBeta_x;
        end
               
    end
    
    methods (Access = private)
        function RBEmax = quadraticFit(obj,bixelLET,vABratio)
            % quadratic fit
            f       = obj.q_p1 .* bixelLET.^2;
            RBEmax  = 1 + obj.q_p0  + vABratio.^-1 .* f;
        end
        
        function RBEmax = linearQuadraticFit(obj,bixelLET,vABratio)
            % linear quadratic fit
            f      = obj.lq_p1 * bixelLET - obj.lq_p2*bixelLET.^2;
            RBEmax = 1 + ((obj.lq_p0 + (vABratio.^-1)) .* f);
        end
        
        function RBEmax = linearExponentialFit(obj,bixelLET,vABratio)
            % linear exponential fit
            f      = (obj.le_p1 * bixelLET) .* exp(obj.le_p2 * bixelLET);
            RBEmax = 1 + ((obj.le_p0  + (vABratio.^-1)) .* f);
        end
        
        function RBEmax = quadraticExponentialFit(obj,bixelLET,vABratio)
            % quadratic exponential fit
            f      = (obj.qe_p1 * bixelLET.^2) .* exp(-obj.qe_p2 * bixelLET);
            RBEmax = 1 + ((obj.qe_p0  + (vABratio.^-1)) .* f);
        end
    end
end

