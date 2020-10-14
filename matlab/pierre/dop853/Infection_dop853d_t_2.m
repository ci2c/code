function Status = Infection_dop853d_t_2(tin,yin,hin,ContIn,Flag,varargin);

persistent t y Ct h
Status = false;


if strcmp(Flag,'init')
  t = tin(1);
  y = yin(:)';
  h = hin;
  Ct(1,:,:) = ContIn;  
elseif strcmp(Flag,'')
  t = [t;tin];
  y = [y;yin(:)'];
  h = [h,hin];
  Ct(length(t),:,:) = ContIn;  
else 
  figure
  plot(t,y(:,1),'b')
  hold on

  t_2 = t(1:end-1) +  diff(t)/2;
  for k = 1:length(t)-1
    dt     = t_2(k) - t(k);
    S      = dt/h(k);      
    S1     = 1 - S; 
    ConPar = Ct(k,1,5) + S*(Ct(k,1,6) + S1*(Ct(k,1,7) +  S*Ct(k,1,8)));       
    y_2(k) = Ct(k,1,1) + S*(Ct(k,1,2) + S1*(Ct(k,1,3) + S*(Ct(k,1,4) + S1*ConPar)));
  end
  plot(t_2,y_2,'or')
  hold on
  title('Infection dop853d, circle at half the returned interval')
end