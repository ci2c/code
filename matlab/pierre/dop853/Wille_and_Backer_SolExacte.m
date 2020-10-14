function  ye = Wille_and_Backer_SolExacte(tt)  % 0 <= t <= 1

for k = 1: length(tt)
  t = tt(k);
  if t <= 1
    ye(k,1) = 1+t;
  elseif t <= 2
    ye(k,1) = 1.5 + 0.5 *t*t;
  elseif t <= 3
    ye(k,1) = 1/6*(t-1).^3 + 1.5*t + 1/3;
  elseif t <= 4
    ye(k,1) = 1/24*(t-2).^4 + 1.5/2*(t-1).^2 +t/3 + 2.125;
  elseif t > 4
    ye(k,1) = -1.13333333333333 + 1/6 *(t-1)^2 + 1.5/6*(t-2)^3 + ...
            1/120*(t-3)^5 + 2.125*t;        
  else
    ye(k,1) = 0;
  end
end

for k = 1: length(tt)
  t = tt(k);
  if t <= 0.2
    ye(k,2) = 1 + 2*t;
    ye(k,3) = 1 + t + t^2;
  elseif t <= 0.4
    ye(k,2) = 1 + 2*t + (t-0.2)^2;
    ye(k,3) = 1 + t + t^2 + (t-0.2)^3/3;
  elseif t <= 0.6
    ye(k,2) = 1 + 2*t + (t-0.2)^2   + (t-0.4)^3/3 ;
    ye(k,3) = 1 + t + t^2 + (t-0.2)^3/3 + (t-0.4)^4/12;
  elseif t <= 0.8
    ye(k,2) = 1 + 2*t + (t-0.2)^2 + (t-0.4)^3/3 + (t-0.6)^4/12;
    ye(k,3) = 1 + t + t^2 + (t-0.2)^3/3 + (t-0.4)^4/12 + (t-0.6)^5/60;    
  elseif t <= 1
    ye(k,2) = 1 + 2*t + (t-0.2)^2 + (t-0.4)^3/3 + (t-0.6)^4/12 + (t-0.8)^5 /60; 
    ye(k,3) = 1 + t + t^2 + (t-0.2)^3/3 + (t-0.4)^4/12 + (t-0.6)^5/60 + (t-0.8)^6/360;      
  else
    ye(k,2) = 0;
    ye(k,3) = 0;
  end  
end
   
