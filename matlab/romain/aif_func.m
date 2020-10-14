function f = func(t,a,b)
    f=(1.0-exp(-t*a))/a - (a*cos(b*t)+b*sin(b*t)-a*exp(a*t))/(a*a+b*b);
 
function  f = Cpm(ab,ag,mb,mg,t)
    f=ab*(1.0-cos(mb*t))+ab*ag*func(t,mg,mb);
