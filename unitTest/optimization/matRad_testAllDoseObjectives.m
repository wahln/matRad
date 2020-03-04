penalty = 1;

%% EUD
EUDParamValues = {...
    {}, ... %Default values
    {0, 5},...
    {30, 3},...
    {60, -10}};

success = 0;
total = 0;
fprintf('Testing matRad_EUD... ');
for i = 1:numel(EUDParamValues)
    state = matRad_testDoseObjective(DoseObjectives.matRad_EUD(penalty,EUDParamValues{i}{:}));
    total = total + numel(fieldnames(state));
    success = success + numel(find(structfun(@(s) s,state)));
end
fprintf('(%d/%d) passed\n',success,total);


%% MaxDVH
MaxDVHParamValues = {...
    {}, ... %Default values
    {0, 10},...
    {30, 50}};

success = 0;
total = 0;
fprintf('Testing matRad_MaxDVH... ');
for i = 1:numel(MaxDVHParamValues)
    state = matRad_testDoseObjective(DoseObjectives.matRad_MaxDVH(penalty,MaxDVHParamValues{i}{:}));
    total = total + numel(fieldnames(state));
    success = success + numel(find(structfun(@(s) s,state)));
end
fprintf('(%d/%d) passed\n',success,total);

%% MinDVH
MinDVHParamValues = {...
    {}, ... %Default values
    {50, 90},...
    {60, 95},...
    {70, 100}};


success = 0;
total = 0;
fprintf('Testing matRad_MinDVH... ');
for i = 1:numel(MinDVHParamValues)
    state = matRad_testDoseObjective(DoseObjectives.matRad_MinDVH(penalty,MinDVHParamValues{i}{:}));
    total = total + numel(fieldnames(state));
    success = success + numel(find(structfun(@(s) s,state)));
end
fprintf('(%d/%d) passed\n',success,total);

%% MeanDose
MeanDoseParamValues = {...
    {}, ... %Default values
    {0},...
    {15},...
    {30},...
    {60}};


success = 0;
total = 0;
fprintf('Testing matRad_MeanDose... ');
for i = 1:numel(MeanDoseParamValues)
    state = matRad_testDoseObjective(DoseObjectives.matRad_MeanDose(penalty,MeanDoseParamValues{i}{:}));
    total = total + numel(fieldnames(state));
    success = success + numel(find(structfun(@(s) s,state)));
end
fprintf('(%d/%d) passed\n',success,total);

%% SquaredDeviation
SquaredDeviationParamValues = {...
    {}, ... %Default values
    {0},...
    {15},...
    {30},...
    {60}};


success = 0;
total = 0;
fprintf('Testing matRad_SquaredDeviation... ');
for i = 1:numel(SquaredDeviationParamValues)
    state = matRad_testDoseObjective(DoseObjectives.matRad_SquaredDeviation(penalty,SquaredDeviationParamValues{i}{:}));
    total = total + numel(fieldnames(state));
    success = success + numel(find(structfun(@(s) s,state)));
end
fprintf('(%d/%d) passed\n',success,total);

%% SquaredOVerdosing
SquaredOverdosingParamValues = {...
    {}, ... %Default values
    {0},...
    {15},...
    {30},...
    {60}};


success = 0;
total = 0;
fprintf('Testing matRad_SquaredOverdosing... ');
for i = 1:numel(SquaredOverdosingParamValues)
    state = matRad_testDoseObjective(DoseObjectives.matRad_SquaredOverdosing(penalty,SquaredOverdosingParamValues{i}{:}));
    total = total + numel(fieldnames(state));
    success = success + numel(find(structfun(@(s) s,state)));
end
fprintf('(%d/%d) passed\n',success,total);

%% SquaredUnderdosing
SquaredUnderdosingParamValues = {...
    {}, ... %Default values
    {0},...
    {15},...
    {30},...
    {60}};


success = 0;
total = 0;
fprintf('Testing matRad_SquaredUnderdosing... ');
for i = 1:numel(SquaredUnderdosingParamValues)
    state = matRad_testDoseObjective(DoseObjectives.matRad_SquaredUnderdosing(penalty,SquaredUnderdosingParamValues{i}{:}));
    total = total + numel(fieldnames(state));
    success = success + numel(find(structfun(@(s) s,state)));
end
fprintf('(%d/%d) passed\n',success,total);