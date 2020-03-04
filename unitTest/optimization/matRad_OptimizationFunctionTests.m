function test_suite = matRad_OptimizationFunctionTests
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions=localfunctions();
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
    
function test_DoseObjectives
    assertTrue(true);
    assertTrue(true);



function test_DoseConstraints
    assertTrue(true);



