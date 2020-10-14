bvecs = load('/NAS/dumbo/protocoles/strokconnect/QA_DTI/BAILLIE^MARIE_PIERRE_STROKE_CONNECT_2014-09-10/dti/bvec/dti.bvec'); % Assuming your filename is bvecs
figure('position',[100 100 500 500]);
plot3(bvecs(1,:),bvecs(2,:),bvecs(3,:),'*r');
axis([-1 1 -1 1 -1 1]);
axis vis3d;
rotate3d