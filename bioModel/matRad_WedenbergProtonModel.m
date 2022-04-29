classdef matRad_WedenbergProtonModel < matRad_ParticleBioModel
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % Model Parameters according to https://www.ncbi.nlm.nih.gov/pubmed/22909391
        p0   = 1;
        p1   = 0.434;
        p2   = 1;
    end
    
    properties (Constant = true)
       restrictModality   = 'protons';
       
       requiredQuantities = {'LET'};
    end
    
    methods
        function obj = matRad_WedenbergModel(machine)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
        end
        
        
        function [bixelAlpha,bixelBeta] = calcLQParameter(obj,vRadDepths,baseDataEntry,mTissueClass,vAlpha_x,vBeta_x,vABratio)         
            % range shift
            depths = baseDataEntry.depths + baseDataEntry.offset;
            
            bixelLET = matRad_interp1(depths,baseDataEntry.LET,vRadDepths);
            bixelLET(isnan(bixelLET)) = 0;
                            
            RBEmax     = this.p0 + ((this.p1 * bixelLET )./ vABratio);
            RBEmin     = this.p2;
            bixelAlpha = RBEmax    .* vAlpha_x;
            bixelBeta  = RBEmin.^2 .* vBeta_x;
        end
    end
end

