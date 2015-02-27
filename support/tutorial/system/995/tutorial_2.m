
%__________________________________________________________________________
%
% This file is part of BRAHMS
% Copyright (C) 2007 Ben Mitchinson
% URL: http://brahms.sourceforge.net
%
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version.
%
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% General Public License for more details.
%
% You should have received a copy of the GNU General Public License along
% with this program; if not, write to the Free Software Foundation, Inc.,
% 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
%__________________________________________________________________________
%
% $Id:: tutorial_2.m 1751 2009-04-01 23:36:40Z benjmitch                 $
% $Rev:: 1751                                                            $
% $Author:: benjmitch                                                    $
% $Date:: 2009-04-02 00:36:40 +0100 (Thu, 02 Apr 2009)                   $
%__________________________________________________________________________
%


% Tutorial 2 : Connecting processes together - adding two
% numbers
%
% By the end of this tutorial you should understand the
% following concepts:
%
%   * how to use the std/random/numeric library process
%   * how to use the std/math/esum library process
%   * linking multiple processes into a single system   
%
% Extra credit tasks are listed at the end of this code


% construct the system: start with an empty system
sys = sml_system;

% construct a process, a source of numeric data
state = [];
state.data = 42*ones(1,2,3);  % 1x2 matrix, 3 samples
state.repeat = false;

% add the new process to the system, and name the process
% "src1", setting sample rate (3 Hz) and passing the
% parameters ("state" structure)
sys = sys.addprocess('src1', 'std/2009/source/numeric', 3, state);

% construct another process, much like the explicit numeric
% source, but change the process type to a source of random
% numeric data instead.
state = [];
state.dims = [1 2];               % dimension of output array 
state.dist = 'uniform';           % type of distribution
state.pars = [2 8];               % values will range in 2 to 8
state.complex = false;            % real output only

% add this second process to the system, and give it a
% unique name, "src2", a sample rate, and its parameters
sys = sys.addprocess('src2', 'std/2009/random/numeric', 3, state);

% add a third process, a sum block, to add the outputs of
% the first two processes, sampling at 3 Hz - it does not
% take any state information, so we can omit that
% argument completely (or pass the empty object "[]").
sys = sys.addprocess('sum', 'std/2009/math/esum', 3);

% we can now add links, connecting the output of both
% sources to the sum block. links can be specified with any
% lag (sample delay), but if we don't specify, the lag
% defaults to unity. see "help sml_system/link".
sys = sys.link('src1>out', 'sum');
sys = sys.link('src2>out', 'sum');

% construct the execution
exe = brahms_execution;
exe.stop = 1;         % stop the simulation after one second (synonym for "executionStop")
exe.all = true;       % log all the outputs of the entire system

% execute the system
out = brahms(sys, exe);

% We can now examine the output structure that was returned
% by BRAHMS, which has a field for each process that was
% logged (all, in this case, see above). In each of these
% process fields, we will find the outputs of that process
% (in this case, still only one output per process).
disp([repmat('_',1,60) 10])
disp('*** Output structure')
disp('out')
disp(out)

% As before, we can find the output "out" of the explicit
% numeric source here:
disp([repmat('_',1,60) 10])
disp('*** Explicit numeric output')
disp('out.src1.out')
disp(out.src1.out)

% Similarly, we can also find the output of the random
% numeric source here:
disp([repmat('_',1,60) 10])
disp('*** Random numeric output')
disp('out.src2.out')
disp(out.src2.out)

% We fixed the size of the output of the explicit numeric
% source by the size of the data we provided for output,
% which was 1x2x3. We fixed the size of the output of the
% random numeric source explicitly, in the field "dims",
% which was 1x2. At the output, we find executionStop/T
% samples have been generated by each output object, with T
% the sample period of the output object.
disp([repmat('_',1,60) 10])
disp('*** Size of numeric data objects')
disp('size(out.src1.out)')
disp(size(out.src1.out))
disp('size(out.src2.out)')
disp(size(out.src2.out))

% Since these data objects were of the same size and sample
% rate, we can add them using the "sum" process, and the
% output will be the same size and have the same sample
% rate (and thus produce 3 samples in the 1 second
% execution, as well).
disp([repmat('_',1,60) 10])
disp('*** Size of summed output')
disp('size(out.sum.out)')
disp(size(out.sum.out))

% Finally, we can examine the output of the sum process.
% Note that the output of src1 is defined at t=0, t=1/3, and
% t=2/3; it is NOT defined at t=1 (similarly for src2). We
% used unity lag links, which means that the inputs to the
% sum block are defined at t=1/3, t=2/3 and t=1. Since the
% sum block needs to produce an output at t=0, we can ask
% where it gets its input from to form this output. The
% answer is that links are stateful, as you would expect, so
% the unity lag links we used have one data sample "in the
% pipe". It is possible to specify what these "historic"
% samples should be, but if you don't (we didn't) they
% default to being of a zero nature - for numeric data, this
% means they are exactly zero.
disp([repmat('_',1,60) 10])
disp('*** Output of sum process')
disp('out.sum.out')
disp(out.sum.out)

% FOR A COMPLETE UNDERSTANDING:
%
%   * Change the size of both numeric sources to scalars,
%   and change the length of the simulation to many many
%   samples. Then, confirm the statistics of the outputs of
%   src1, src2, and sum are as you expect.
%
%   * Try a different distribution type in the random source
%   - you will find all the information you need in the
%   reference documentation for std/random/numeric.