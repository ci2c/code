function Mass = Mass_ty_Fcn(t,y,varargin)
Mass =  [2+10*t+0.1*norm(y) , -3 ; -1-2*t-0.2*norm(y), 4];