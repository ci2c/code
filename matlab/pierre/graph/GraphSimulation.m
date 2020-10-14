% Computes wavelets coefficients on simulated graphs
g = graph;
g2 = graph;
Grid_size = 10;
Thre = 0.5;
nb_edge = 100;

% Create Graph
grid(g, Grid_size, Grid_size);
M = matrix(g);

% Create Matrices
Mat = abs(2.*(rand(size(M)) - 0.5));
Mat = (Mat + Mat') ./ 2;
Mat = M .* Mat;
S = sort(Mat(:));
The = S(end - nb_edge.*2);
Mat_t = Mat > The;

set_matrix(g2, Mat_t);
%distxy(g2);
figure; draw(g2)
figure; image(Mat_t)
sum(sum(Mat_t))


free(g);
free(g2);
clear g g2;
