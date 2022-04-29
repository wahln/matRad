classdef matRad_TopasConfigPhotons < MatRad_TopasConfig
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here

    properties
        modules = {'g4em-standard_opt4'};

        infilenames = struct('geometry','TOPAS_matRad_geometry.txt.in',...
            'surfaceScorer','TOPAS_scorer_surfaceIC.txt.in',...
            'doseScorer','TOPAS_scorer_dose.txt.in',...
            'schneider_materialsOnly','TOPAS_SchneiderConverterMaterialsOnly.txt.in',...
            'schneider_full','TOPAS_SchneiderConverter.txt.in',...
            'virtualGaussian','TOPAS_beamSetup_photonVirtualGaussian.txt.in');
    end

    methods
        function writeFieldHeader(obj,fID,fieldIx)
            matRad_cfg = MatRad_Config.instance(); %Instance of matRad configuration class
            
            fprintf(fID,'u:Sim/HalfValue = %d\n',0.5);
            fprintf(fID,'u:Sim/SIGMA2FWHM = %d\n',2.354818);
            fprintf(fID,'u:Sim/FWHM2SIGMA = %d\n',0.424661);
            fprintf(fID,'\n');
            
            fprintf(fID,'d:Sim/ElectronProductionCut = %f mm\n',obj.electronProductionCut);
            fprintf(fID,'s:Sim/WorldMaterial = "%s"\n',obj.worldMaterial);
            fprintf(fID,'\n');
            
            fprintf(fID,'includeFile = %s\n',obj.outfilenames.patientParam);
            fprintf(fID,'\n');
            
            fname = fullfile(obj.thisFolder,obj.infilenames.geometry);
            matRad_cfg.dispInfo('Reading Geometry from %s\n',fname);
            world = fileread(fname);
            fprintf(fID,'%s\n\n',world);
        end
        
        function writeStfFieldsBixel(obj,ct,stf,baseData)
            nParticlesPerBixel = 1e6;
            
            switch obj.modeHistories
                case 'num'
                    obj.fracHistories = obj.numHistories ./ sum(nParticlesTotalBixel);
                case 'frac'
                    obj.numHistories = sum(nParticlesTotalBixel);
                otherwise
                    matRad_cfg.dispError('Invalid history setting!');
            end

            machine = baseData.machine;
            
            %Preread beam setup
            switch obj.beamProfile
                case 'virtualGaussian'
                    fname = fullfile(obj.thisFolder,obj.infilenames.virtualGaussian);
                    TOPAS_beamSetup = fileread(fname);
                    matRad_cfg.dispInfo('Reading ''%s'' Beam Characteristics from ''%s''\n',obj.beamProfile,fname);

                    % gaussian filter to model penumbra from (measured) machine output / see diploma thesis siggel 4.1.2
                    if isfield(machine.data,'penumbraFWHMatIso')
                        penumbraFWHM = machine.data.penumbraFWHMatIso;
                    else
                        penumbraFWHM = 5;
                        matRad_cfg.dispWarning('photon machine file does not contain measured penumbra width in machine.data.penumbraFWHMatIso. Assuming 5 mm.');
                    end

                    sourceFWHM = penumbraFWHM * machine.meta.SCD/(machine.meta.SAD - machine.meta.SCD);
                    sourceSigma = sourceFWHM / sqrt(8*log(2)); % [mm]


                otherwise
                    matRad_cfg.dispError('Beam Type ''%s'' not supported for photons',obj.beamProfile);
            end

            for beamIx = 1:length(stf)
                
                SAD = stf(beamIx).SAD;                
                SCD = stf(beamIx).SCD;

                sourceToNozzleDistance = 0;                                              
       
                %get beamlet properties for each bixel in the stf and write
                %it into dataTOPAS
                currentBixel = 1;
                cutNumOfBixel = 0;
                nBeamParticlesTotal(beamIx) = 0;
                
                collectBixelIdx = [];
                
                %Loop over rays and then over spots on ray
                for rayIx = 1:stf(beamIx).numOfRays
                    for bixelIx = 1:stf(beamIx).numOfBixelsPerRay(rayIx)

                    end
                end


            end
        end

        function writeStfFields(obj,ct,stf,baseData,w)
            matRad_cfg = MatRad_Config.instance(); %Instance of matRad configuration class
            
            %snippet for future dij simulation
            %if ~exist('w','var')
            %    numBixels = sum([stf(:).totalNumOfBixels)];
            %    w = ones(numBixels,1);
            %end
            
            %Bookkeeping
            obj.MCparam.nbFields = length(stf);
            
            %Sanity check
            if numel(w) ~= sum([stf(:).totalNumOfBixels])
                matRad_cfg.dispError('Given number of weights (#%d) doesn''t match bixel count in stf (#%d)',numel(w), sum([stf(:).totalNumOfBixels]));
            end
            
                
            
            nParticlesTotalBixel = round(1e6*w);
            %nParticlesTotal = sum(nParticlesTotalBixel);
            maxParticlesBixel = 1e6*max(w(:));
            minParticlesBixel = round(max([obj.minRelWeight*maxParticlesBixel,1]));
            
            switch obj.modeHistories
                case 'num'
                    obj.fracHistories = obj.numHistories ./ sum(nParticlesTotalBixel);
                case 'frac'
                    obj.numHistories = sum(nParticlesTotalBixel);
                otherwise
                    matRad_cfg.dispError('Invalid history setting!');
            end
                      
            nParticlesTotal = 0;

            machine = baseData.machine;
            
            %Preread beam setup
            switch obj.beamProfile
                case 'virtualGaussian'
                    fname = fullfile(obj.thisFolder,obj.infilenames.beam_generic);
                    TOPAS_beamSetup = fileread(fname);
                    matRad_cfg.dispInfo('Reading ''%s'' Beam Characteristics from ''%s''\n',obj.beamProfile,fname);

                    % gaussian filter to model penumbra from (measured) machine output / see diploma thesis siggel 4.1.2
                    if isfield(machine.data,'penumbraFWHMatIso')
                        penumbraFWHM = machine.data.penumbraFWHMatIso;
                    else
                        penumbraFWHM = 5;
                        matRad_cfg.dispWarning('photon machine file does not contain measured penumbra width in machine.data.penumbraFWHMatIso. Assuming 5 mm.');
                    end

                    sourceFWHM = penumbraFWHM * machine.meta.SCD/(machine.meta.SAD - machine.meta.SCD);
                    sourceSigma = sourceFWHM / sqrt(8*log(2)); % [mm]


                otherwise
                    matRad_cfg.dispError('Beam Type ''%s'' not supported for photons',obj.beamProfile);
            end
            
            for beamIx = 1:length(stf)
                
                SAD = stf(beamIx).SAD;                
                SCD = stf(beamIx).SCD;

                sourceToNozzleDistance = 0;                                              
       
                %get beamlet properties for each bixel in the stf and write
                %it into dataTOPAS
                currentBixel = 1;
                
                %Loop over rays and then over spots on ray
                for rayIx = 1:stf(beamIx).numOfRays
                    for bixelIx = 1:stf(beamIx).numOfBixelsPerRay(rayIx)
                                              
                        
                        
                            if obj.pencilBeamScanning
                                % angleX corresponds to the rotation around the X axis necessary to move the spot in the Y direction
                                % angleY corresponds to the rotation around the Y' axis necessary to move the spot in the X direction
                                % note that Y' corresponds to the Y axis after the rotation of angleX around X axis                                
                                dataTOPAS(cutNumOfBixel).angleX = atan(dataTOPAS(cutNumOfBixel).posY / SAD);
                                dataTOPAS(cutNumOfBixel).angleY = atan(-dataTOPAS(cutNumOfBixel).posX ./ (SAD ./ cos(dataTOPAS(cutNumOfBixel).angleX)));
                                dataTOPAS(cutNumOfBixel).posX = (dataTOPAS(cutNumOfBixel).posX / SAD)*(SAD-nozzleToAxisDistance);
                                dataTOPAS(cutNumOfBixel).posY = (dataTOPAS(cutNumOfBixel).posY / SAD)*(SAD-nozzleToAxisDistance);
                            end
              
                        end
                        
                        currentBixel = currentBixel + 1;
                        
                    end
                end
                                
                nParticlesTotal = nParticlesTotal + nBeamParticlesTotal(beamIx);
                
                % discard data if the current has unphysical values
                idx = find([dataTOPAS.current] < 1);
                dataTOPAS(idx) = [];
                cutNumOfBixel = length(dataTOPAS(:));
                
                historyCount(beamIx) = uint32(obj.fracHistories * nBeamParticlesTotal(beamIx) / obj.numOfRuns);
                
                if historyCount < cutNumOfBixel || cutNumOfBixel == 0
                    matRad_cfg.dispError('Insufficient number of histories!')
                end
                
                while sum([dataTOPAS.current]) ~= historyCount(beamIx)
                    % Randomly pick an index with the weigth given by the current
                    idx = 1:length(dataTOPAS);
                    % Note: as of Octave version 5.1.0, histcounts is not yet implemented
                    %       using histc instead for compatibility with MATLAB and Octave
                    %[~,~,R] = histcounts(rand(1),cumsum([0;double(transpose([dataTOPAS(:).current]))./double(sum([dataTOPAS(:).current]))]));
                    [~,R] = histc(rand(1),cumsum([0;double(transpose([dataTOPAS(:).current]))./double(sum([dataTOPAS(:).current]))]));
                    randIx = idx(R);
                    
                    if (sum([dataTOPAS(:).current]) > historyCount(beamIx))
                        if dataTOPAS(randIx).current > 1
                            dataTOPAS(randIx).current = dataTOPAS(randIx).current-1;
                        end
                    else
                        dataTOPAS(randIx).current = dataTOPAS(randIx).current+1;
                    end
                end
                
                historyCount(beamIx) = historyCount(beamIx) * obj.numOfRuns;  

                
                %sort dataTOPAS according to energy
                [~,ixSorted] = sort([dataTOPAS(:).energy]);
                dataTOPAS = dataTOPAS(ixSorted);
                
                %write TOPAS data base file
                fieldSetupFileName = sprintf('beamSetup_%s_field%d.txt',obj.label,beamIx);
                fileID = fopen(fullfile(obj.workingDir,fieldSetupFileName),'w');
                obj.writeFieldHeader(fileID,beamIx);                
                
                                
                fprintf(fileID,'d:Sim/GantryAngle = %f deg\n',stf(beamIx).gantryAngle);
                fprintf(fileID,'d:Sim/CouchAngle = %f deg\n',stf(beamIx).couchAngle);
                
                fprintf(fileID,'d:Tf/TimelineStart = 0. ms\n');
                fprintf(fileID,'d:Tf/TimelineEnd = %i ms\n', 10 * cutNumOfBixel);
                fprintf(fileID,'i:Tf/NumberOfSequentialTimes = %i\n', cutNumOfBixel);
                fprintf(fileID,'dv:Tf/Beam/Spot/Times = %i ', cutNumOfBixel);
                fprintf(fileID,num2str(linspace(10,cutNumOfBixel*10,cutNumOfBixel)));
                fprintf(fileID,' ms\n');
                %fprintf(fileID,'uv:Tf/Beam/Spot/Values = %i %s\n',cutNumOfBixel,num2str(collectBixelIdx));
                fprintf(fileID,'s:Tf/Beam/Energy/Function = "Step"\n');
                fprintf(fileID,'dv:Tf/Beam/Energy/Times = Tf/Beam/Spot/Times ms\n');
                fprintf(fileID,'dv:Tf/Beam/Energy/Values = %i ', cutNumOfBixel);
                
                fprintf(fileID,num2str(particleA*[dataTOPAS.energy])); %Transform total energy with atomic number
                fprintf(fileID,' MeV\n');
                
                switch obj.beamProfile
                    case 'biGaussian'
                        fprintf(fileID,'s:Tf/Beam/EnergySpread/Function = "Step"\n');
                        fprintf(fileID,'dv:Tf/Beam/EnergySpread/Times = Tf/Beam/Spot/Times ms\n');
                        fprintf(fileID,'uv:Tf/Beam/EnergySpread/Values = %i ', cutNumOfBixel);
                        fprintf(fileID,num2str([dataTOPAS.energySpread]));
                        fprintf(fileID,'\n');
                        
                        fprintf(fileID,'s:Tf/Beam/SigmaX/Function = "Step"\n');
                        fprintf(fileID,'dv:Tf/Beam/SigmaX/Times = Tf/Beam/Spot/Times ms\n');
                        fprintf(fileID,'dv:Tf/Beam/SigmaX/Values = %i ', cutNumOfBixel);
                        fprintf(fileID,num2str([dataTOPAS.spotSize]));
                        fprintf(fileID,' mm\n');
                        fprintf(fileID,'s:Tf/Beam/SigmaXPrime/Function = "Step"\n');
                        fprintf(fileID,'dv:Tf/Beam/SigmaXPrime/Times = Tf/Beam/Spot/Times ms\n');
                        fprintf(fileID,'uv:Tf/Beam/SigmaXPrime/Values = %i ', cutNumOfBixel);
                        fprintf(fileID,num2str([dataTOPAS.divergence]));
                        fprintf(fileID,'\n');
                        fprintf(fileID,'s:Tf/Beam/CorrelationX/Function = "Step"\n');
                        fprintf(fileID,'dv:Tf/Beam/CorrelationX/Times = Tf/Beam/Spot/Times ms\n');
                        fprintf(fileID,'uv:Tf/Beam/CorrelationX/Values = %i ', cutNumOfBixel);
                        fprintf(fileID,num2str([dataTOPAS.correlation]));
                        fprintf(fileID,'\n');
                        
                        fprintf(fileID,'s:Tf/Beam/SigmaY/Function = "Step"\n');
                        fprintf(fileID,'dv:Tf/Beam/SigmaY/Times = Tf/Beam/Spot/Times ms\n');
                        fprintf(fileID,'dv:Tf/Beam/SigmaY/Values = %i ', cutNumOfBixel);
                        fprintf(fileID,num2str([dataTOPAS.spotSize]));
                        fprintf(fileID,' mm\n');
                        fprintf(fileID,'s:Tf/Beam/SigmaYPrime/Function = "Step"\n');
                        fprintf(fileID,'dv:Tf/Beam/SigmaYPrime/Times = Tf/Beam/Spot/Times ms\n');
                        fprintf(fileID,'uv:Tf/Beam/SigmaYPrime/Values = %i ', cutNumOfBixel);
                        fprintf(fileID,num2str([dataTOPAS.divergence]));
                        fprintf(fileID,'\n');
                        fprintf(fileID,'s:Tf/Beam/CorrelationY/Function = "Step"\n');
                        fprintf(fileID,'dv:Tf/Beam/CorrelationY/Times = Tf/Beam/Spot/Times ms\n');
                        fprintf(fileID,'uv:Tf/Beam/CorrelationY/Values = %i ', cutNumOfBixel);
                        fprintf(fileID,num2str([dataTOPAS.correlation]));
                        fprintf(fileID,'\n');
                    case 'simple'
                        fprintf(fileID,'s:Tf/Beam/FocusFWHM/Function = "Step"\n');
                        fprintf(fileID,'dv:Tf/Beam/FocusFWHM/Times = Tf/Beam/Spot/Times ms\n');
                        fprintf(fileID,'dv:Tf/Beam/FocusFWHM/Values = %i ', cutNumOfBixel);
                        fprintf(fileID,num2str([dataTOPAS.focusFWHM]));
                        fprintf(fileID,' mm\n');
                end
                
                if obj.pencilBeamScanning
                    fprintf(fileID,'s:Tf/Beam/AngleX/Function = "Step"\n');
                    fprintf(fileID,'dv:Tf/Beam/AngleX/Times = Tf/Beam/Spot/Times ms\n');
                    fprintf(fileID,'dv:Tf/Beam/AngleX/Values = %i ', cutNumOfBixel);
                    fprintf(fileID,num2str([dataTOPAS.angleX]));
                    fprintf(fileID,' rad\n');
                    fprintf(fileID,'s:Tf/Beam/AngleY/Function = "Step"\n');
                    fprintf(fileID,'dv:Tf/Beam/AngleY/Times = Tf/Beam/Spot/Times ms\n');
                    fprintf(fileID,'dv:Tf/Beam/AngleY/Values = %i ', cutNumOfBixel);
                    fprintf(fileID,num2str([dataTOPAS.angleY]));
                    fprintf(fileID,' rad\n');
                end
                
                fprintf(fileID,'s:Tf/Beam/PosX/Function = "Step"\n');
                fprintf(fileID,'dv:Tf/Beam/PosX/Times = Tf/Beam/Spot/Times ms\n');
                fprintf(fileID,'dv:Tf/Beam/PosX/Values = %i ', cutNumOfBixel);
                fprintf(fileID,num2str([dataTOPAS.posX]));
                fprintf(fileID,' mm\n');
                fprintf(fileID,'s:Tf/Beam/PosY/Function = "Step"\n');
                fprintf(fileID,'dv:Tf/Beam/PosY/Times = Tf/Beam/Spot/Times ms\n');
                fprintf(fileID,'dv:Tf/Beam/PosY/Values = %i ', cutNumOfBixel);
                fprintf(fileID,num2str([dataTOPAS.posY]));
                fprintf(fileID,' mm\n');
                
                fprintf(fileID,'s:Tf/Beam/Current/Function = "Step"\n');
                fprintf(fileID,'dv:Tf/Beam/Current/Times = Tf/Beam/Spot/Times ms\n');
                fprintf(fileID,'iv:Tf/Beam/Current/Values = %i ', cutNumOfBixel);
                fprintf(fileID,num2str([dataTOPAS.current]));
                fprintf(fileID,'\n\n');
                
                %Range shifter in/out
                if ~isempty(raShis)
                    fprintf(fileID,'#Range Shifter States:\n');
                    for r = 1:numel(raShis)
                        fprintf(fileID,'s:Tf/Beam/%sOut/Function = "Step"\n',raShis(r).topasID);
                        fprintf(fileID,'dv:Tf/Beam/%sOut/Times = Tf/Beam/Spot/Times ms\n',raShis(r).topasID);
                        fprintf(fileID,'uv:Tf/Beam/%sOut/Values = %i ', raShis(r).topasID, cutNumOfBixel);
                        fprintf(fileID,num2str([dataTOPAS.raShiOut]));
                        fprintf(fileID,'\n\n');
                    end
                end
                
                
                % NozzleAxialDistance
                fprintf(fileID,'d:Ge/Nozzle/TransZ = -%f mm\n', nozzleToAxisDistance);
                if obj.pencilBeamScanning
                    fprintf(fileID,'d:Ge/Nozzle/RotX = Tf/Beam/AngleX/Value rad\n');
                    fprintf(fileID,'d:Ge/Nozzle/RotY = Tf/Beam/AngleY/Value rad\n');
                    fprintf(fileID,'d:Ge/Nozzle/RotZ = 0.0 rad\n');
                end
                
                %Range Shifter Definition
                for r = 1:numel(raShis)
                    obj.writeRangeShifter(fileID,raShis(r),sourceToNozzleDistance);
                end
                                
                
                fprintf(fileID,'%s\n',TOPAS_beamSetup);
                
                %translate patient according to beam isocenter
                fprintf(fileID,'d:Ge/Patient/TransX      = %f mm\n',0.5*ct.resolution.x*(ct.cubeDim(2)+1)-stf(beamIx).isoCenter(1));
                fprintf(fileID,'d:Ge/Patient/TransY      = %f mm\n',0.5*ct.resolution.y*(ct.cubeDim(1)+1)-stf(beamIx).isoCenter(2));
                fprintf(fileID,'d:Ge/Patient/TransZ      = %f mm\n',0.5*ct.resolution.z*(ct.cubeDim(3)+1)-stf(beamIx).isoCenter(3));
                fprintf(fileID,'d:Ge/Patient/RotX=0. deg\n');
                fprintf(fileID,'d:Ge/Patient/RotY=0. deg\n');
                fprintf(fileID,'d:Ge/Patient/RotZ=0. deg\n');
                
                %load topas modules depending on the particle type
                fprintf(fileID,'# MODULES\n');
                moduleString = cellfun(@(s) sprintf('"%s"',s),modules,'UniformOutput',false);
                fprintf(fileID,'sv:Ph/Default/Modules = %d %s\n',length(modules),strjoin(moduleString,' '));
                
                fclose(fileID);
                %write run scripts for TOPAS
                for runIx = 1:obj.numOfRuns
                    runFileName = sprintf('%s_field%d_run%d.txt',obj.label,beamIx,runIx);
                    fileID = fopen(fullfile(obj.workingDir,runFileName),'w');
                    obj.writeRunHeader(fileID,beamIx,runIx);
                    fprintf(fileID,['i:Ts/Seed = ',num2str(runIx),'\n']);
                    fprintf(fileID,'includeFile = ./%s\n',fieldSetupFileName);
                    obj.writeScorers(fileID);
                    fclose(fileID);
                end                                
            end
            
            %Bookkeeping
            obj.MCparam.nbParticlesTotal = nParticlesTotal;
            obj.MCparam.nbHistoriesTotal = sum(historyCount);
            obj.MCparam.nbParticlesField = nBeamParticlesTotal;
            obj.MCparam.nbHistoriesField = historyCount;     
        end
    end
end