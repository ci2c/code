function my_textProgress(step,nSteps,startFlag)
%
% my_textProgress(step,nSteps,[startFlag])
%
% startFlag : A string displayed before the percent indicator. 
%             Use this to initialize the indicator. Inside the main loop,
%             only privide step and nSteps.
%
%
%
% [Example]
%
% nSteps = 100;
% my_textProgress(0,nSteps,'Do not disturb. Percent done: ');
% for step = 1 : nSteps;
%    my_textProgress(step,nSteps); 
%    pause(0.1)
% end
%
%
% Luis Concha. Noel Lab. BIC, MNI. October, 2008.

if nargin >2
    if strcmp(startFlag,'init');
        fprintf(1,'Percent done:  \n\n'); 
    else
        fprintf(1,'%s:  \n\n',startFlag); 
    end
end


stepPercent = round((step./nSteps) .* 100);
stepPercent = num2str(stepPercent,'%03.0f');


fprintf(1,'\b\b\b');
fprintf(1,'%s',stepPercent);

if step==nSteps
   fprintf(1,'\n'); 
end