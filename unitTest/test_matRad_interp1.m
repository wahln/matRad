function test = test_matRad_interp1()
%TEST_MATRAD_INTERP1 Summary of this function goes here
%   Detailed explanation goes here
    assert(matRad_interp1([0; 1],[1; 3],0.5) == 2); %Two Points
    assert(isnan(matRad_interp1([0; 1],[1; 3],4))); %Default Extrapolation
    assert(matRad_interp1([0; 1],[1; 3],4,10) == 10); %Set Extrapolation
    assert(matRad_interp1([0; 1],[-1; 1],2,'extrap') == 3); %Linear Extrapolation
    
    assert(all(matRad_interp1([0; 1; 2],[1; 3; 4],[0.5; 1.5]) == [2; 3.5]));
    assert(all(isnan(matRad_interp1([0; 1; 2],[1; 3; 4],[-1; 10]))));
    assert(all(matRad_interp1([0; 1; 2],[1; 3; 4],[-1; 10],0) == [0; 0]));
    assert(all(matRad_interp1([0; 1; 2],[1; 3; 5],[-1; 3],'extrap') == [-1; 7]));
end

