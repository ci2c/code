% --------------------------------------------------------- %
% Readme.txt                                                %
%                                                           %
% List of the examples used to test dop54d                  %
%                                                           %
% Denis Bichsel                                             %
% 58 Rue des Deurres                                        %
% 2000 Neuchâtel                                            %
% Tel. 41 (0) 32 730 10 16                                  %
% email: dbichsel@infomaniak.ch                             %
% --------------------------------------------------------- %
dop54d is a translation in Matlab from RETARD.F
the Fortran code written by :
E. Hairer and G. Wanner
Université de Genève.
dop853d is the extension to delay differential equations
of dop853 (no delay).
dop54d and dop853d are well suited for delay differential
equations with constant delay.

Remark: The steps size are adjust to end and begin at the 
delay multiples. The results are more accurate with this 
choice.

See
E. Hairer, S.P. Norsett, G. Wanner
Solving Ordinary Differential Equations I
Nonstiff Problems  (p. 286-301)
Springer Verlag 1987

% --------------------------------------------------------- %
The options for dop54d and dop853d can be set with dopset
and read with dopget.
These functions are very similar dop54, dop853 (without delay)  
The options are the same for all 4 functions.

The allowed options are essentially the same as in Matlab.
The options
  BDF
  Jacobian
  JConstant
  JPattern
  Refine
  Vectorized
  MvPattern
  MassSingular
  InitialSlope
  MaxOrder
are not implemented.

Remark : The following options are not implemented for ode45
in Matlab   
  BDF
  Jacobian
  JConstant
  JPattern
  Vectorized
  MvPattern
  InitialSlope
  MassSingular
  InitialSlope
  MaxOrder
  
The option "Refine" is just useless with dop54d and dop 853,
because it's possible to choose all the output value for 
the t variable without any effect on the step size calculation.

DenseOuputFcn,  DenseOutputSel.

Like the "OutputFcn" and "OutputSel" options, "DenseOutputFcn" 
and "DenseOutputSel" allow to get the t and y values after each 
step calculation. More, with this option the user gets also the
coefficients which allow dense calculation on the interval
[t, t+h], h = step size, 5 coefficients for dop54d and 8 
coefficients for dop854d (see dop54 and dop853 exemples)
These options allows for example, the calculation with high 
precision of the extrema of a function 
% --------------------------------------------------------- %


List of examples:
------------------

The name of the main function of the examples end always
with   "_dop54d_dop853d.m". The other functions with a name 
which begin on the same way, are used for the calculation.
For example :  "Enzyme_dop54d_dop853d.m" is the main function of the 
exemple "Enzyme" and uses "Enzyme_dop54d_Prime.m", 
Enzyme_dop853d_Prime and "Enzyme_phi.m"

Enzyme_dop54d_dop853d.m  ( see
  This function tests the following option:
    MaxStep.
  compare the execution time of dop54d, dop853d and 
  Matlab dde23. The difference of the solutions evaluated
  with dop853d and dop54d is plotted, the same for dop853d
  and dde23.

Immunologie_dop54d_dop853d.m
  This function tests the following option:
    MaxStep.
  The difference of the solutions evaluated with dop853d 
  and dop54d is plotted.
  
 Infection_dop54d_dop853d.m
  This function tests the following options:
    MaxStep
	OutputSel
	DenseOuputSel	
	DenseOutputFcn
The soltions evaluated with dop54d and dop853d are plotted
on figure 3. On figures 1 and 2 the DenseOutputFcn is used to
plot the solution and the solution on each half-intervals returned
by dop54d and dop853d respectively. 
 
 Mass_dop54d_dop853d.m
   The solution of thi example is teh cosine function and his
   derivative. 
   This function tests the following options:
   MaxStep
   Mass  (mass = cte matrix)
   Mass  ( mass = Mass_t_Fcn, the mass depends on t only)
   MStateDependance
   Mass  ( mass = Mass_ty_Fcn, the mass depends on t and y)
 
Population_dop54d_dop853d.m
  This function tests the following option:
  MaxStep

Test_dop54d_dop853d.m
  This function tests the following options:
  RelTol
  AbsTol
  MaxStep
  In this case, the phi function is choosen first in order
  to get a solution which is the same as the nalytical one
  and second the phi function is set to 1. The 2 solutions 
  are complitely different as expected.
  The convergence of the two methods, dop54d and dop853d can
  be tested with this example.  
  The solution got with Matlab function dde3, is compared to 
  the analytical solution.

Wille_and_Backer_dop54d_dop853d.m
  This example comes out Matlab's help.
  The exact solution has been calculated for 0 <= t <= 1
  and the comparison between wxact and numerical solutions
  are shown





















