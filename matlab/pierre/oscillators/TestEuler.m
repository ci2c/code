function [tvals,yvals]=alcohol(t0,tf,y0,gam,cur)
    global a epsilon gamma I1
    a=.139; epsilon=.008; gamma=gam; I1=cur;
    peek=10; h=.01; tau=1/(gamma*epsilon);
    n=round((tf-t0)/h); tc=t0; yc=y0; yp=yc;
    tvals=tc; ypvals=yc; fc=feval('derivs',tc,yc);delsteps=round(tau/h);
    for i=1:delsteps % integrate backward w/o delay to generate IC
        [tc,yp,fc]=RKstep('derivs',tc,yp,fc,-h);
        ypvals=[yp ypvals];
        tvals=[tc tvals];
    end
    tc=t0; yp=ypvals; fcp=feval('derivsdel',tc,yc,yp(:,1));
    yvals=yp;
    % the system at time (t-tau) is the first column of yp
    if (n>delsteps)
        yvals=yc;
        tvals=tc;
    end
    for j=1:n % integrate forward w/ delay
        [tc,yc,fcp]=RKdelstep('derivsdel',tc,yc,yp,fcp,h);
        if mod(j,peek)==0
            yvals=[yvals yc];
            tvals=[tvals tc];
        end
        yp=[yp(:,2:delsteps+1) yc];
    end

%*************************************
function [tnew,ynew,fnew]=RKdelstep(fname,tc,yc,yp,fcp,h)
    ya=yp(:,1);
    ya1=0.5*(yp(:,1)+yp(:,2));
    ya2=yp(:,2);
    k1 = h*fcp;
    k2 = h*feval(fname,tc+(h/2),yc+(k1/2),ya1);
    k3 = h*feval(fname,tc+(h/2),yc+(k2/2),ya1);
    k4 = h*feval(fname,tc+h,yc+k3,ya2);
    ynew = yc +(k1 + 2*k2 + 2*k3 +k4)/6;
    tnew = tc+h;
    fnew = feval(fname,tnew,ynew,yp(:,2));

%**************************************
function [tnew,ynew,fnew]=RKstep(fname,tc,yc,fc,h)
    k1 = h*fc;
    k2 = h*feval(fname,tc+(h/2),yc+(k1/2));
    k3 = h*feval(fname,tc+(h/2),yc+(k2/2));
    k4 = h*feval(fname,tc+h,yc+k3);
    ynew = yc +(k1 + 2*k2 + 2*k3 +k4)/6;
    tnew = tc+h;
    fnew = feval(fname,tnew,ynew);
    
%**************************************
function dy=derivsdel(tc,yc,ya)
    global a epsilon gamma I1
    v=yc(1); w=yc(2); vt=ya(1); wt=ya(2);
    dy=[-v*(v-1)*(v-a)-wt+I1; epsilon*(v-gamma*w)];
    
%**************************************
function dy=derivs(tc,yc)
    global a epsilon gamma I1
    ya=yc;
    v=yc(1); w=yc(2); vt=ya(1); wt=ya(2);
    dy=[-v*(v-1)*(v-a)-wt+I1; epsilon*(v-gamma*w)];
