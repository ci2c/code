%FRONTEND du prog de FARELL pour BV
%REF
%    *  J. A. Farrell, B. A. Landman, C. K. Jones, S. A. Smith, J. L. Prince, P. C. van Zijl, and S. Mori, (2007) Effects of SNR on the Accuracy and Reproducibility of DTI-derived Fractional Anisotropy, Mean Diffusivity, and Principal Eigenvector Measurements at 1.5T, Journal of Magnetic Resonance Imaging. In press.
%    * http://godzilla.kennedykrieger.org/~jfarrell/software_web.htm
function medinria =DTI_philips_brainvisa(A,b)
dir=DtI_gradient_table_creator_Philips_RelX(A)
dir(:,1)=-dir(:,1); %FLIP X ??
dir(:,2)=-dir(:,2); %FLIP Y ??
medinria = [dir(1:size(dir,1)-1,:)]
medinria = [ones(size(medinria,1),1)*b, medinria]
dlmwrite(strcat(A.par_file , '.txt'), medinria, 'delimiter', '\t', 'precision', 6)