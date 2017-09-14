function [xOpt, info] = matRad_optimizerCallWrapper(x0,funcs,options,optimizer)


if nargin < 4
    optimizer = 'IPOPT';
end

disp(['Using optimizer ' optimizer '...']);

if strcmp(optimizer,'IPOPT')
    [xOpt, info]  = ipopt(x0,funcs,options);
elseif strcmp(optimizer,'fmincon')
    optionsFmincon = optimoptions('fmincon',...
    'SpecifyObjectiveGradient',true,'SpecifyConstraintGradient',true,...
    'HessianApproximation',{'lbfgs',6},'UseParallel',true,...
    'OptimalityTolerance',1e-4,...
    'Display','iter-detailed',...
    'PlotFcn',@optimplotfval,...
    'AlwaysHonorConstraints', 'bounds');
    fungrad = @(x) deal(funcs.objective(x),funcs.gradient(x));
    
    %{
    %find equality and inequality constraints
    ceqIx = options.cl == options.cb;
    cneqIx = options.cl ~= options.cb;
    
    %all equality constraints have to be defined to equal zero
    if any(ceqIx)
        ceqfuns = @(x) funcs.constraints(x) - options.cl(ceqix);
        ceqgrads = @(x) funcs.jacobian(
    else
        ceqfuns = [];
    end
    %}
    
    cInfBoundsIx = isinf(options.cl);
    options.cl(cInfBoundsIx) = -0.1*realmax('double');
    cInfBoundsIx = isinf(options.cu);
    options.cu(cInfBoundsIx) = 0.1*realmax('double');
    
    cneqfuncs = @(x) [funcs.constraints(x) - options.cu; options.cl - funcs.constraints(x)];
    cneqgrads = @(x) [funcs.jacobian(x); -funcs.jacobian(x)];
    
    constfungrad = @(x) deal(cneqfuncs(x),[],transpose(cneqgrads(x)),[]);

    [xOpt,fVal,exitflag,info] = fmincon(fungrad,x0,[],[],[],[],options.lb,options.ub,constfungrad,optionsFmincon);
elseif strcmp(optimizer,'fmincon_sqp')
    optionsFmincon = optimoptions('fmincon',...
    'Algorithm','sqp',...
    'SpecifyObjectiveGradient',true,...
    'SpecifyConstraintGradient',true,...
    'UseParallel',true,...
    'OptimalityTolerance',1e-4,...
    'Display','iter-detailed',...
    'PlotFcn',@optimplotfval,...
    'AlwaysHonorConstraints', 'bounds');
    fungrad = @(x) deal(funcs.objective(x),funcs.gradient(x));
    %}
    
    cInfBoundsIx = isinf(options.cl);
    options.cl(cInfBoundsIx) = -0.1*realmax('double');
    cInfBoundsIx = isinf(options.cu);
    options.cu(cInfBoundsIx) = 0.1*realmax('double');
    
    cneqfuncs = @(x) [funcs.constraints(x) - options.cu; options.cl - funcs.constraints(x)];
    cneqgrads = @(x) [funcs.jacobian(x); -funcs.jacobian(x)];
    
    constfungrad = @(x) deal(cneqfuncs(x),[],transpose(cneqgrads(x)),[]);

    [xOpt,fVal,exitflag,info] = fmincon(fungrad,x0,[],[],[],[],options.lb,options.ub,constfungrad,optionsFmincon);
else
    error(['Optimizer ''' optimizer ''' not found!']);
end

disp('Optimization finished!');

end