function Table = getGradientTable(PAR, Rel, B, outname)
% Usage : Table = getGradientTable(PAR, Rel, B, outname)

A.par_file = PAR;
A.didREG = 'n';
A.writeGRAD = 'n';
A.grad_choice = 'yes-ovp-high';
A.release = Rel;
A.fat_shift = 'A';

Table = DTI_gradient_table_creator_Philips_RelX(A);

Table = [Table(1:end-1, :)]';
Table(2,:) = -Table(2,:);

if sum(Table(:,end)==[0;0;0])==3
    Table = [[0;0;0], Table(:, 1:end-1)];
end

dlmwrite(strcat(outname, '.bvec'), Table, 'delimiter', '\t', 'precision', 6);

Vals = B * ones(1, size(Table, 2));
Vals(1) = 0;

dlmwrite(strcat(outname, '.bval'), Vals, 'delimiter', '\t', 'precision', 4);
