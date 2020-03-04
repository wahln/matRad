function  [state] = matRad_testDoseConstraint(doseConstraint,visBool)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%Tests
state.c_evaluate = false;
state.c_column = false;
state.c_size = false;
state.c_nonan = false;
state.j_evaluate = false;
state.j_estimate = false;
state.j_nonan = false;



if nargin < 2
    visBool = false;
end

dPoints =[0:1:100];
[d1,d2] = ndgrid(dPoints,dPoints);

ix = randi([1,100],2,1);
try 
    c = arrayfun(@(d1,d2) doseConstraint.computeDoseConstraintFunction([d1; d2]),d1,d2,'UniformOutput',false);
    state.c_evaluate  = true;
catch    
end

try
    state.c_column = all(cellfun(@iscolumn,c),'all'); %Check if column vector
catch
end

try    
    nC = unique(cellfun(@(c) size(c,1),c));
    state.c_size = numel(nC) == 1; %equal sizes
catch
end

try
    state.c_nonan = ~any(cellfun(@(c) any(isnan(c)),c),'all'); %Check for NaN values
catch
end

%Reshape the constraints (could be moved up)
if state.c_evaluate && state.c_size
    for i = 1:nC
        cReshaped{i} = cellfun(@(c) c(i),c);
    end
end


%test jacobian evaluation
try
    j = arrayfun(@(d1, d2) doseConstraint.computeDoseConstraintJacobian([d1; d2]),d1,d2,'UniformOutput',false);
    state.j_evaluate = true;
    
    state.j_nonan = ~any(cellfun(@(j) any(isnan(j(:))),j),'all');
    
    for i = 1:nC
        jReshaped{i} = cellfun(@(j) j(:,i),j,'UniformOutput',false);
        j1{i} = cellfun(@(j) j(1),jReshaped{i});
        j2{i} = cellfun(@(j) j(2),jReshaped{i});
        [g2{i},g1{i}] = gradient(cReshaped{i});
        
        diff1{i} = g1{i} - j1{i};
        rmse{i,1} = sqrt(mean(diff1{i}(:).^2));
        diff2{i} = g2{i} - j2{i};
        rmse{i,2} = sqrt(mean(diff2{i}(:).^2));        
    end
    
    state.j_estimate = all(cell2mat(rmse) < 0.01,'all');
catch
end

%{   
cTestVal = c{ix(1),ix(2)}

nCfunc = numel(cTestVal);
lambda = ones(size(cTestVal));

jNumIx = jacobianest(@doseConstraint.computeDoseConstraintFunction,[dPoints(ix(1)); dPoints(ix(2))])
j = arrayfun(@(d1, d2) doseConstraint.computeDoseConstraintJacobian([d1; d2]),d1,d2,'UniformOutput',false);
j{ix(1),ix(2)}'
%}

%hessNumIx = hessian(@(d) sum(doseConstraint.computeDoseConstraintFunction(d)),[dPoints(ix(1)); dPoints(ix(2))])
%h = arrayfun(@(d1, d2) doseConstraint.computeDoseConstraintHessian([d1; d2],lambda),d1,d2,'UniformOutput',false);
%full(h{ix(1),ix(2)})
%[gxx, gxy] = gradient(gx, d1, d2);
%[gyx, gyy] = gradient(gy, d1, d2);


if visBool
    ha(i) = axes(figure);
    contour(ha(i),d1,d2,cReshaped{i});
    hold(ha(i),'on');
    quiver(ha(i),g1{i},g2{i});
    quiver(ha(i),j1{i},j2{i});
end


end

