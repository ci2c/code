function Tmap = bpm_compute_Tmap_surf(ConImage,XtX,c,brain_mask,sig2,Tmap,M,nr)
% Computing the Tmaps for ancova bpm and regression bpm

% for m = 1:M 
%     if brain_mask(m) == 1     
%         if sig2(m) > 0        
%             vertexXtX = reshape(XtX(:,m),nr,nr);              
%             cp = c'*pinv(vertexXtX)*c;    
%             den = sqrt(sig2(m).*cp);                
% %                 den = sqrt(max(sig2(m,n).*cp,eps(class(sig2(m,n))))); % don't let t value be too large               
%             Tmap(m) = ConImage(m)/den;  
%         end      
%     end
% end

% Optimized function
I = find((brain_mask==1)&(sig2>0));
vertexXtX = arrayfun(@(x) reshape(XtX(:,x),nr,nr), I, 'UniformOutput', false);
cp = cellfun(@(x) c'*pinv(x)*c, vertexXtX);
% den = arrayfun(@(x) sqrt(sig2(x)*cp(x)), 1:length(I));
den = sqrt(sig2(I).*cp);
% Tmap(I) = arrayfun(@(x) ConImage(x)/den(x), 1:length(I));
Tmap(I) = ConImage(I)./den;


