% To get started, place all code in your matlab path then load the optim.mat file. 
clear;
load my_optim
% To run the optimization type [f,fval,fmin,fminval] = anneal(loss,initvals,options); 
% and go have a beer. The output "f" will define the sequence in a tabular way. 
% There are at least three columns, each representing a parameter set. 
% There are five rows. 
% Row 1: an estimate of the number of concatenations that 
%        Seimens will want to use (this is only important if optimizing per 
%        unit time since concatenations can take a long time). 
% Row 2: defines sequence type,
%        0 is standard fse (no IR); 
%        1 is single IR; 
%        2 is double IR. 
% Row 3: First inversion time in ms (only relevant if double IR, ignore otherwise).
% Row 4: Second inversion time if double IR, or inversion time if IR (ignore if row 2 is 0 for no IR). 
% Row 5: Repetition time.
% 
[f,fval,fmin,fminval] = anneal(loss,initvals,options);

% There are many options that can be adjusted.
% 
% Optimization adjustments in the options structure:
% you want the cooling schedule, initial temperature, and max success to be large 
% enough to get a consistent answer. Try the defaults I've provided, but run a few 
% times to make sure it's converging on the optimal solution. If not, increase max 
% success or put the cooling schedule closer to unity (but not greater than or equal 
% to unity!). The fval output should give you an indication as to how good the 
% solution is doing.
% 
% Weighting term:
% You can specify which tissue is more important by changing the w parameter 
% in tissue_opts.m file (line 81-ish). Currently, they're all equal (ie: w=[1;1;1]), but might be worth less weight on csf, and more on WM and/or GM.
% 
% Physical constants:
% At the top of tissue_opt.m file there are T1 and proton density values for 
% the three tissue types. You'll want to add the values for 3 T in there and
% comment out the 1.5 T values.
% 
% Sequence parameters:
% To compute scan time and concatenations the code has values for etl, esp, 
% and ns. These are in both genparams.m and tissue_opts.m. Keep them consistent.
% 
% Number of scans:
% change the number of columns in the initvals parameter (min three columns 
% for fully determined solution, more for over determined). Be sure to look 
% at the solutions when using more than three scans. Often several of them 
% are degenerate, implying averaging rather than a different contrast. 
% In my experience there are often three scan very unique scans, a no ir 
% long tr, a long tr with long ti, and a short tr with short ti. 
% Any additional scans are short tr with short ti to help improve the SNR of that scan.
% 
% Fortunately the fitting is easier to run. Just use the tissuemaps2.m function. 
% Unfortunately, this function could be vastly improved as I'm sure you'll discover.
% 


fprintf(1,'.......................................\n');
fprintf(1,'Parameters used:\n');
fprintf(1,'.......................................\n');
fprintf(1,'*) Field Strength:\t%s\n',Params.FieldStrength);
fprintf(1,'*) Echo Train Length:\t%d\n',Params.EchoTrainLength);
fprintf(1,'*) Echo Spacing:\t%d\n',Params.EchoSpacing);
fprintf(1,'*) T1 values (ms)\n');
fprintf(1,'\tGM:\t%d\n\tWM:\t%d\n\tCSF:\t%d\n',Params.T1.GM,Params.T1.WM,Params.T1.CSF);
fprintf(1,'*) PD values (percent)\n');
fprintf(1,'\tGM:\t%d\n\tWM:\t%d\n\tCSF:\t%d\n',Params.PD.GM,Params.PD.WM,Params.PD.CSF);
fprintf(1,'.......................................\n');



stype = {'FSE';'IR';'DIR'};

fprintf(1,'\n\nOriginal sequences used for optimization:\n');
fprintf(1,'.......................................\n');
fprintf(1,'N\tType\tTI1\tTI2\tTR\n');
fprintf(1,'---------------------------------------\n');
for seq = 1: size(initvals,2)
   if initvals(2,seq) == 0     % FSE
       TI1=NaN;
       TI2=NaN;
   elseif initvals(2,seq) == 1 %IR
       TI1 = NaN;
       TI2 = initvals(4,seq);
   else                 %DIR
       TI1 = initvals(3,seq);
       TI2 = initvals(4,seq);
   end
   fprintf(1,'%d\t%s\t%d\t%d\t%d\n',seq,stype{initvals(2,seq)+1},TI1,TI2,initvals(5,seq));
end
fprintf(1,'.......................................\n');





fprintf(1,'\n\nOPTIMIZED PARAMETERS:\n');
fprintf(1,'=======================================\n');
fprintf(1,'N\tType\tTI1\tTI2\tTR\n');
fprintf(1,'---------------------------------------\n');
for seq = 1: size(f,2)
   if f(2,seq) == 0     % FSE
       TI1=NaN;
       TI2=NaN;
   elseif f(2,seq) == 1 %IR
       TI1 = NaN;
       TI2 = f(4,seq);
   else                 %DIR
       TI1 = f(3,seq);
       TI2 = f(4,seq);
   end
   fprintf(1,'%d\t%s\t%d\t%d\t%d\n',seq,stype{f(2,seq)+1},TI1,TI2,f(5,seq));
end
fprintf(1,'=======================================\n');



   
