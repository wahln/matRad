classdef matRad_McNamaraProtonModel < matRad_ParticleBioModel
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        %McNamara parameters according to https://www.ncbi.nlm.nih.gov/pubmed/26459756
        p0   = 0.999064;     
        p1   = 0.35605;
        p2   = 1.1012;
        p3   = -0.0038703;
    end
    
    properties(Constant = true)
       restrictModality = 'protons';
       
       requiredQuantities = {'LET'};
    end
    
    methods
        function obj = matRad_McNamaraProtonModel(machine)
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

