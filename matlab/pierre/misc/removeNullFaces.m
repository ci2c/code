function [surf_out, surf_sp_out] = removeNullFaces(surf, surf_sp)
% usage : [surf_out, surf_sp_out] = removeNullFaces(surf, [surf_sp])
%
% Removes faces whose area = 0 and divide very large faces
%
% If surf_sp provided, apply the same re-triangulation to this surface and
% return surf_sp_out
%
% Pierre Besson @ CHRU Lille, Oct. 2013

if nargin ~= 1 && nargin ~= 2
    error('invalid usage');
end

% get triangle area
A = getFacesArea(surf);

% Remove empty triangles
loop = 0;
surf_out = surf;

if nargin == 2
    surf_sp_out = surf_sp;
end

while min(A) == 0
    loop = loop + 1;
    if loop > 10000
        disp('tout plein');
    end
    A0 = find(A==0, 1, 'first');
    V1 = surf_out.tri(A0, 1);
    V2 = surf_out.tri(A0, 2);
    V3 = surf_out.tri(A0, 3);
    N1 = surf_out.coord(:, V1);
    N2 = surf_out.coord(:, V2);
    N3 = surf_out.coord(:, V3);
    
    % check if the triangle has twice the same node
    if V1 == V2 || V1 == V3 || V2 == V3
        disp(['remove triangle ' num2str(A0)]);
        surf_out.tri(A0, :) = [];
        A = getFacesArea(surf_out);
        if nargin == 2
            surf_sp_out.tri(A0, :) = [];
        end
        continue;
    end
    
    if sum(N1 == N2) == 3
        % Solution : remove node N1, remove triangle A0 and replace N1 with
        % N2 in other triangles
        Node = surf_out.tri(A0, 1);
        disp(['remove node ' num2str(Node)]);
        surf_out.tri(A0, :) = [];
        surf_out.tri(surf_out.tri == Node) = surf_out.tri(A0, 2);
        surf_out.coord(:, Node) = [];
        surf_out.tri(surf_out.tri(:) > Node) = surf_out.tri(surf_out.tri(:) > Node) - 1;
        
        if nargin == 2
            surf_sp_out.tri(A0, :) = [];
            surf_sp_out.tri(surf_sp_out.tri == Node) = surf_sp_out.tri(A0, 2);
            surf_sp_out.coord(:, Node) = [];
            surf_sp_out.tri(surf_sp_out.tri(:) > Node) = surf_sp_out.tri(surf_sp_out.tri(:) > Node) - 1;
        end
        
        % update A
        A = getFacesArea(surf_out);
    else
        if sum(N1 == N3) == 3
            % Solution : remove node N1, remove triangle A0 and replace N1 with
            % N3 in other triangles
            Node = surf_out.tri(A0, 1);
            disp(['remove node ' num2str(Node)]);
            surf_out.tri(A0, :) = [];
            surf_out.tri(surf_out.tri == Node) = surf_out.tri(A0, 3);
            surf_out.coord(:, Node) = [];
            surf_out.tri(surf_out.tri(:) > Node) = surf_out.tri(surf_out.tri(:) > Node) - 1;
            
            if nargin == 2
                surf_sp_out.tri(A0, :) = [];
                surf_sp_out.tri(surf_sp_out.tri == Node) = surf_sp_out.tri(A0, 3);
                surf_sp_out.coord(:, Node) = [];
                surf_sp_out.tri(surf_sp_out.tri(:) > Node) = surf_sp_out.tri(surf_sp_out.tri(:) > Node) - 1;
            end
            
            % update A
            A = getFacesArea(surf_out);
        else
            if sum(N2 == N3) == 3
                % Solution : remove node N2, remove triangle A0 and replace N2 with
                % N3 in other triangles
                Node = surf_out.tri(A0, 2);
                disp(['remove node ' num2str(Node)]);
                surf_out.tri(A0, :) = [];
                surf_out.tri(surf_out.tri == Node) = surf_out.tri(A0, 3);
                surf_out.coord(:, Node) = [];
                surf_out.tri(surf_out.tri(:) > Node) = surf_out.tri(surf_out.tri(:) > Node) - 1;
                
                if nargin == 2
                    surf_sp_out.tri(A0, :) = [];
                    surf_sp_out.tri(surf_sp_out.tri == Node) = surf_sp_out.tri(A0, 3);
                    surf_sp_out.coord(:, Node) = [];
                    surf_sp_out.tri(surf_sp_out.tri(:) > Node) = surf_sp_out.tri(surf_sp_out.tri(:) > Node) - 1;
                end
                
                % update A
                A = getFacesArea(surf_out);
            else
                disp('!! Points are aligned !!');
            end
        end
    end
end

% Divide very big triangles
while max(A) > 10 * mean(A)
    % cut largest triangle
    L = find(A == max(A), 1, 'first');
    disp(['divide face ' num2str(L)]);
    n_face = length(A);
    n_node = length(surf_out.coord);
    x_s1  = surf_out.coord(1, surf_out.tri(L,1));
    x_s2  = surf_out.coord(1, surf_out.tri(L,2));
    x_s3  = surf_out.coord(1, surf_out.tri(L,3));
    y_s1  = surf_out.coord(2, surf_out.tri(L,1));
    y_s2  = surf_out.coord(2, surf_out.tri(L,2));
    y_s3  = surf_out.coord(2, surf_out.tri(L,3));
    z_s1  = surf_out.coord(3, surf_out.tri(L,1));
    z_s2  = surf_out.coord(3, surf_out.tri(L,2));
    z_s3  = surf_out.coord(3, surf_out.tri(L,3));
    
    x_bari = (x_s1 + x_s2 + x_s3) ./ 3;
    y_bari = (y_s1 + y_s2 + y_s3) ./ 3;
    z_bari = (z_s1 + z_s2 + z_s3) ./ 3;
    
    if nargin == 2
        x_sp_s1  = surf_sp_out.coord(1, surf_sp_out.tri(L,1));
        x_sp_s2  = surf_sp_out.coord(1, surf_sp_out.tri(L,2));
        x_sp_s3  = surf_sp_out.coord(1, surf_sp_out.tri(L,3));
        y_sp_s1  = surf_sp_out.coord(2, surf_sp_out.tri(L,1));
        y_sp_s2  = surf_sp_out.coord(2, surf_sp_out.tri(L,2));
        y_sp_s3  = surf_sp_out.coord(2, surf_sp_out.tri(L,3));
        z_sp_s1  = surf_sp_out.coord(3, surf_sp_out.tri(L,1));
        z_sp_s2  = surf_sp_out.coord(3, surf_sp_out.tri(L,2));
        z_sp_s3  = surf_sp_out.coord(3, surf_sp_out.tri(L,3));

        x_sp_bari = (x_sp_s1 + x_sp_s2 + x_sp_s3) ./ 3;
        y_sp_bari = (y_sp_s1 + y_sp_s2 + y_sp_s3) ./ 3;
        z_sp_bari = (z_sp_s1 + z_sp_s2 + z_sp_s3) ./ 3;
    end
    
    % add barycentric triangles
    temp = [surf_out.tri(L,1), surf_out.tri(L,2), n_node + 1];
    tri_out = temp;
    temp = [surf_out.tri(L,1), n_node + 1, surf_out.tri(L,3)];
    tri_out = [tri_out; temp];
    temp = [surf_out.tri(L,2), surf_out.tri(L,3), n_node + 1];
    tri_out = [tri_out; temp];
    
    % Remove large triangle
    surf_out.tri(L,:) = [];
    
    % Add temp triangles
    surf_out.tri = [surf_out.tri; tri_out];
    
    % Add barycenter to the nodes
    surf_out.coord = [surf_out.coord, [x_bari; y_bari; z_bari]];
    
    if nargin == 2
        % Remove large triangle
        surf_sp_out.tri(L,:) = [];

        % Add temp triangles
        surf_sp_out.tri = [surf_sp_out.tri; tri_out];

        % Add barycenter to the nodes
        surf_sp_out.coord = [surf_sp_out.coord, [x_sp_bari; y_sp_bari; z_sp_bari]];
    end
    
    % update A
    A = getFacesArea(surf_out);
    % disp(['max A =' num2str(max(A)) '   mean A = ' num2str(mean(A))]);
end