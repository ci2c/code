function dti()
   A.writeGRAD='n';
   A.fat_shift='A';
   A.didREG='n';
   current=pwd;
   javaclasspath(strcat(current,'/dtiphilips.jar'));
   res=dtiphilips.JGUIDti.showDialog;
   A.par_file=char(res(1));
   A.grad_choice=char(res(3));
   A.release=char(res(2));
   A
   bv=DTI_philips_brainvisa(A,800);
end