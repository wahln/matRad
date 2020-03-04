function [success,ME] = matRad_testFunction(fHandle,varargin)
%matRad_testFunction Tests a function by handle

% matRad function to get the software environment matRad is running on
% 
% call
%   [success,ME] = matRad_testFunction(fHandle,varargin)
%
% input
%   fHandle:    handle to the function to test
%   varargin:   arguments to pass to the function   
% output
%   success:    true or false for success or fail
%   ME:         exception object. empty when successful
%
% References
%   -
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Copyright 2020 the matRad development team. 
% 
% This file is part of the matRad project. It is subject to the license 
% terms in the LICENSE file found in the top-level directory of this 
% distribution and at https://github.com/e0404/matRad/LICENSES.txt. No part 
% of the matRad project, including this file, may be copied, modified, 
% propagated, or distributed except according to the terms contained in the 
% LICENSE file.
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


try
    success = fHandle(varargin{:});
    ME = [];
catch ME    
    warning(ME.identifier,'Test failed due to: %s\n',ME.message);
    success = false;
end

end

