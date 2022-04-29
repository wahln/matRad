classdef matRad_CarabeFernandezProtonModel < matRad_ParticleBioModel
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % Model Parameters according to http://www.tandfonline.com/doi/abs/10.1080/09553000601087176?journalCode=irab20
        p0   = 0.843; 
        p1   = 0.154;
        p2   = 2.686;
        p3   = 1.09;
        p4   = 0.006;
        p5   = 2.686;
    end
    
    properties(Constant = true)
       restrictModality = 'protons';
       
       requiredQuantities = {'LET'};
    end
    
    methods
        function obj = matRad_CarabeFernandezModel(machine)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
        end
        
        
        function [bixelAlpha,bixelBeta] = calcLQParameter(obj,vRadDepths,baseDataEntry,mTissueClass,vAlpha_x,vBeta_x,vABratio)         
            % range shift
            depths = baseDataEntry.depths + baseDataEntry.offset;
            
            bixelLET = matRad_interp1(depths,baseDataEntry.LET,vRadDepths);
            bixelLET(isnan(bixelLET)) = 0;
            
            RBEmax     = obj.p0 + ((obj.p1 * bixelLET )./ vABratio);
            RBEmin     = obj.p2 + (obj.p3  * sqrt(vABratio) .* bixelLET);
            bixelAlpha = RBEmax    .* vAlpha_x;
            bixelBeta  = RBEmin.^2 .* vBeta_x;
        end
    end
end

