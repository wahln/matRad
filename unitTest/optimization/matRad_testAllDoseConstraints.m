%% MinMaxDose
MinMaxDoseParamValues = {...
    {}, ... %Default values
    {0, 30, 'voxelwise'},...
    {0, 30, 'approx'},...
    {55, 66, 'voxelwise'},...
    {55, 66, 'approx'},...
    {55, Inf, 'voxelwise'},...
    {55, Inf, 'approx'}};

success = 0;
total = 0;
fprintf('Testing matRad_MinMaxDose... ');
for i = 1:numel(MinMaxDoseParamValues)
    state = matRad_testConstraintDerivatives(DoseConstraints.matRad_MinMaxDose(MinMaxDoseParamValues{i}{:}));
    total = total + numel(fieldnames(state));
    success = success + numel(find(structfun(@(s) s,state)));
end
fprintf('(%d/%d) passed\n',success,total);


%% MinMaxDVH
MinMaxDVHParamValues = {...
    {}, ... %Default values
    {30, 0, 50},...
    {60, 95, 100},...
    {45, 0.25 0.75}};

success = 0;
total = 0;
fprintf('Testing matRad_MinMaxDVH... ');
for i = 1:numel(MinMaxDVHParamValues)
    state = matRad_testConstraintDerivatives(DoseConstraints.matRad_MinMaxDVH(MinMaxDVHParamValues{i}{:}));
    total = total + numel(fieldnames(state));
    success = success + numel(find(structfun(@(s) s,state)));
end
fprintf('(%d/%d) passed\n',success,total);    

%% MinMaxEUD
MinMaxEUDParamValues = {...
    {}, ... %Default values
    {-10, 55, 65},...
    {5, 0, 30},...
    {-10, 55, Inf}};

success = 0;
total = 0;
fprintf('Testing matRad_MinMaxEUD... ');
for i = 1:numel(MinMaxEUDParamValues)
    state = matRad_testConstraintDerivatives(DoseConstraints.matRad_MinMaxEUD(MinMaxEUDParamValues{i}{:}));
    total = total + numel(fieldnames(state));
    success = success + numel(find(structfun(@(s) s,state)));
end
fprintf('(%d/%d) passed\n',success,total);    

%% MinMaxMeanDose
MinMaxMeanDoseParamValues = {...
    {}, ... %Default values
    {55, 65},...
    {0, 60},...
    {30, Inf}};
success = 0;
total = 0;
fprintf('Testing matRad_MinMaxMeanDose... ');
for i = 1:numel(MinMaxMeanDoseParamValues)
    state = matRad_testConstraintDerivatives(DoseConstraints.matRad_MinMaxMeanDose(MinMaxMeanDoseParamValues{i}{:}));
    total = total + numel(fieldnames(state));
    success = success + numel(find(structfun(@(s) s,state)));
end
fprintf('(%d/%d) passed\n',success,total);    

