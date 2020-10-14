function [Uni1,Uni2,NUni,varargout] = UniformityParameters(type,varargin)

switch type
    case 'ROI'  
        %% ROI principale et centrale
        if (size(varargin,2)==1) && ((nargout-3)==0)
            
            ROI = varargin{1};
            NdGmax = double(max(ROI(find(ROI~=0))));
            NdGmin = double(min(ROI(find(ROI~=0))));

            Uni1 = 1/2*(NdGmax+NdGmin)/(NdGmax-NdGmin);
            Uni2 = (1-(NdGmax-NdGmin)/(NdGmax+NdGmin))*100;
            NUni = (NdGmax-NdGmin)/(NdGmax+NdGmin);  
        
        %% ROI latérales
        elseif (size(varargin,2)==3) && ((nargout-3)==1)
            
            ROI = varargin{1};
            ROIc = varargin{2};
            ROIp = varargin{3};
            NdGmax = double(max(ROI(find(ROI~=0))));
            NdGmin = double(min(ROI(find(ROI~=0))));

            Uni1 = 1/2*(NdGmax+NdGmin)/(NdGmax-NdGmin);
            Uni2 = (1-(NdGmax-NdGmin)/(NdGmax+NdGmin))*100;
            NUni = (NdGmax-NdGmin)/(NdGmax+NdGmin);    
            varargout(1) = {abs((double(mean(ROIc(find(ROIc~=0))))-double(mean(ROI(find(ROI~=0)))))/double(mean(ROIp(find(ROIp~=0))))*100)};

        else
            error('Wrong number of variable input/output arguments');
        end   
        
    case 'profil_vert'
        if (size(varargin,2)==4) && ((nargout-3)==2)
            
            ROIc = varargin{1};
            ROIp = varargin{2};  
            ROIh = varargin{3};
            ROIb = varargin{4};
            Pvert = ROIp(:,ceil(size(ROIp,2)/2));
            Pc = ROIc(:,ceil(size(ROIc,2)/2));
            Ph = ROIh(:,ceil(size(ROIh,2)/2));
            Pb = ROIb(:,ceil(size(ROIb,2)/2));
            NdGmax = double(max(Pvert(find(Pvert~=0))));
            NdGmin = double(min(Pvert(find(Pvert~=0))));
            
            Uni1 = 1/2*(NdGmax+NdGmin)/(NdGmax-NdGmin);
            Uni2 = (1-(NdGmax-NdGmin)/(NdGmax+NdGmin))*100;
            NUni = (NdGmax-NdGmin)/(NdGmax+NdGmin);
            varargout(1) = {abs((double(mean(Pc(find(Pc~=0))))-double(mean(Ph(find(Ph~=0)))))/double(mean(Pvert(find(Pvert~=0))))*100)};
            varargout(2) = {abs((double(mean(Pc(find(Pc~=0))))-double(mean(Pb(find(Pb~=0)))))/double(mean(Pvert(find(Pvert~=0))))*100)};
        
        else
            error('Wrong number of variable input/output arguments');
        end    
        
    case 'profil_horiz'   
        if (size(varargin,2)==4) && ((nargout-3)==2)
            
            ROIc = varargin{1};
            ROIp = varargin{2};  
            ROIg = varargin{3};
            ROId = varargin{4};
            Phoriz = ROIp(ceil(size(ROIp,1)/2),:);
            Pc = ROIc(ceil(size(ROIc,1)/2),:);
            Pg = ROIg(ceil(size(ROIg,1)/2),:);
            Pd = ROId(ceil(size(ROId,1)/2),:);
            NdGmax = double(max(Phoriz(find(Phoriz~=0))));
            NdGmin = double(min(Phoriz(find(Phoriz~=0))));
            
            Uni1 = 1/2*(NdGmax+NdGmin)/(NdGmax-NdGmin);
            Uni2 = (1-(NdGmax-NdGmin)/(NdGmax+NdGmin))*100;
            NUni = (NdGmax-NdGmin)/(NdGmax+NdGmin);
            varargout(1) = {abs((double(mean(Pc(find(Pc~=0))))-double(mean(Pg(find(Pg~=0)))))/double(mean(Phoriz(find(Phoriz~=0))))*100)};
            varargout(2) = {abs((double(mean(Pc(find(Pc~=0))))-double(mean(Pd(find(Pd~=0)))))/double(mean(Phoriz(find(Phoriz~=0))))*100)};
        
        else
            error('Wrong number of variable input/output arguments');
        end    
        
    otherwise
        error('Type of input data unknown');
end