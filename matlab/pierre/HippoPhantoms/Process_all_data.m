% Report curved hippo
%File = fopen('Report_Hippos_curved.log', 'w');
%Root_name = 'curve_hippo_';
%Sq = ones(10, 10, 20);

% Generates curved hippos

%fprintf(File, 'Filename;D;RH;L\n');
%Index = 1;
%for D = 10 : 5 : 50
%	for RH = 0 : 50 : 500
%		for L = 10 : 10 : 100
%			Name = strcat(Root_name, int2str(Index), '.mnc');
%			middle_line = Middle_line_design(D, [RH 0], [50 50 50], L);
%			display('Generate hippo');
%			Generate_hippo(middle_line, Sq, Name, [256 256 256], [1 1 1]);
%			fprintf(File, '%s;%d;%d;%d\n', Name, D, RH, L);
%			Index = Index + 1;
%		end
%	end
%end
%fclose(File);

% Report bended hippo
File = fopen('Report_Hippos_shifted.log', 'w');
Root_name = 'shift_hippo_';
Sq = make_ellipsoid([5 5 9]);
%Sq = ones(10, 10, 20);

fprintf(File, 'Filename;L;D;H;W\n');
Index = 1;
for L = 200
	for D = 60
		for H = 1:10
			for W = 80
				if W / 2 < D
					Name=strcat(Root_name, int2str(L), '_', int2str(D), '_', int2str(H), '_', int2str(W), '.mnc');
					middle_line=Middle_line_design2([50 50 50], L, D, W, H);
					display('Generate hippo');
					
					Generate_hippo(middle_line, Sq, Name, [300 300 300], [1 1 1]);
					fprintf(File, '%s;%d;%d;%d;%d\n', Name, L, D, H, W);
					Index = Index+1;
				end
			end
		end
	end
end

fclose(File);