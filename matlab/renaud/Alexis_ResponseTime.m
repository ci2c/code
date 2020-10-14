function resp = Alexis_ResponseTime(sot)

% TWL
v  = [sot{1,11}.vect sot{2,11}.vect];
id = find(~isnan(v));
v  = v(id);
resp(1).name = 'TWL';
resp(1).N    = length([sot{1,1}.vect sot{2,1}.vect]);
resp(1).mean = round(mean(v));
resp(1).std  = round(std(v));

% TWR
v  = [sot{1,12}.vect sot{2,12}.vect];
id = find(~isnan(v));
v  = v(id);
resp(2).name = 'TWR';
resp(2).N    = length([sot{1,2}.vect sot{2,2}.vect]);
resp(2).mean = round(mean(v));
resp(2).std  = round(std(v));

% FWL
v  = [sot{1,13}.vect sot{2,13}.vect];
id = find(~isnan(v));
v  = v(id);
resp(3).name = 'FWL';
resp(3).N    = length([sot{1,3}.vect sot{2,3}.vect]);
resp(3).mean = round(mean(v));
resp(3).std  = round(std(v));

% FWR
v  = [sot{1,14}.vect sot{2,14}.vect];
id = find(~isnan(v));
v  = v(id);
resp(4).name = 'FWR';
resp(4).N    = length([sot{1,4}.vect sot{2,4}.vect]);
resp(4).mean = round(mean(v));
resp(4).std  = round(std(v));

% TNWL
v  = [sot{1,15}.vect sot{2,15}.vect];
id = find(~isnan(v));
v  = v(id);
resp(5).name = 'TNWL';
resp(5).N    = length([sot{1,5}.vect sot{2,5}.vect]);
resp(5).mean = round(mean(v));
resp(5).std  = round(std(v));

% TNWR
v  = [sot{1,16}.vect sot{2,16}.vect];
id = find(~isnan(v));
v  = v(id);
resp(6).name = 'TNWR';
resp(6).N    = length([sot{1,6}.vect sot{2,6}.vect]);
resp(6).mean = round(mean(v));
resp(6).std  = round(std(v));

% FNWL
v  = [sot{1,17}.vect sot{2,17}.vect];
id = find(~isnan(v));
v  = v(id);
resp(7).name = 'FNWL';
resp(7).N    = length([sot{1,7}.vect sot{2,7}.vect]);
resp(7).mean = round(mean(v));
resp(7).std  = round(std(v));

% FNWR
v  = [sot{1,18}.vect sot{2,18}.vect];
id = find(~isnan(v));
v  = v(id);
resp(8).name = 'FNWR';
resp(8).N    = length([sot{1,8}.vect sot{2,8}.vect]);
resp(8).mean = round(mean(v));
resp(8).std  = round(std(v));

% DL
vt = [sot{1,19}.vect sot{2,19}.vect];
vr = [sot{1,21}.vect sot{2,21}.vect];
id = find(~isnan(vt));
vt = vt(id);
vr = vr(id);
resp(9).name = 'DL';
resp(9).N    = length(vr);
resp(9).mean = round(mean(vt));
resp(9).std  = round(std(vt));

% DR
vt = [sot{1,20}.vect sot{2,20}.vect];
vr = [sot{1,22}.vect sot{2,22}.vect];
id = find(~isnan(vt));
vt = vt(id);
vr = vr(id);
resp(10).name = 'DR';
resp(10).N    = length(vr);
resp(10).mean = round(mean(vt));
resp(10).std  = round(std(vt));

