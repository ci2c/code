%FRONTEND du prog de FARELL pour MEDINRIA
%REF
%    *  J. A. Farrell, B. A. Landman, C. K. Jones, S. A. Smith, J. L. Prince, P. C. van Zijl, and S. Mori, (2007) Effects of SNR on the Accuracy and Reproducibility of DTI-derived Fractional Anisotropy, Mean Diffusivity, and Principal Eigenvector Measurements at 1.5T, Journal of Magnetic Resonance Imaging. In press.
%    * http://godzilla.kennedykrieger.org/~jfarrell/software_web.htm
function medinria =DTI_philips_medinria(A)
dir=DtI_gradient_table_creator_Philips_RelX(A)
dir(:,2)=-dir(:,2); %FLIP Y ??
medinria = [0,0,0; dir(1:size(dir,1)-1,:)]
dlmwrite(strcat(A.par_file , '.txt'), medinria, 'delimiter', '\t', 'precision', 6)