function  f = Cpm(ab,ag,mb,mg,t)
    f=ab*(1.0-cos(mb*t))+ab*ag*func(t,mg,mb);

function f = func(t,a,b)
    f=(1.0-exp(-t*a))/a - (a*cos(b*t)+b*sin(b*t)-a*exp(a*t))/(a*a+b*b);
    
    
 ab=13.88;
 ag=694.05;
 mb=61.55;
 mg=0.0;
 t=308;