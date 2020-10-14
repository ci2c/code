function w = FMRI_GetWindows(l,w,o,d)

if (isempty(d))
    
    l   = length(l);
    wl  = l/(w*(1-o)+o);
    wlr = wl*(1-o);
    w   = repmat(floor((0:(w-1))*wlr),ceil(wl),1)'+repmat(1:ceil(wl),w,1);
    
else
    
    d   = interp1(0:(length(d)-1),d,l)';
    l   = length(l);
    dn  = false(size(d(:)));
    dn(2:(end-1)) = (d(2:(end-1))>d(1:(end-2)))&(d(2:(end-1))>=d(3:end));
    f   = find(dn);
    
    if (length(f)>w)
        df    = f(2:end)-f(1:(end-1));
        [x,p] = sort(df);
        dn(f(p(1:(length(f)-w))+1)) = false;
        f     = find(dn);
    end
    
    if (min(f)>1), f = [1;f]; end
    if (max(f)<l), f = [f;l]; end
    
    df = f(3:end)-f(1:(end-2));
    wn = length(f)-2;
    wl = floor((1-o)*min(df)+o*l);
    w  = zeros(wn,wl);
    for i = 1:wn
        s = max(1,floor(f(i+1)-wl/2));
        e = s+wl-1;
        if (e>l), s = s-e+l; e = l; end
        w(i,:) = s:e;
    end
    
end

w = unique(w,'rows');