function [F_left_norm , F_right_norm] = norma(F_left, F_right, temp_left, temp_right)
%
% usage : function [F_left_norm , F_right_norm] = norma(F_left, F_right, temp_left, temp_right)
%
% normalizes the raw data based on the template
%
% is used by normalizationcontrol.m
%
% Inputs :
%       F_left          : feature matrix unnormalized - left hemisphere
%       F_right         : feature matrix unnormalized - right hemisphere
%       temp_left       : template for left hemisphere
%       temp_right      : template for right hemisphere
%
%
%
% Outputs :
%
%       F_left_norm     : feature matrix normalized - left hemisphere
%       F_right_norm    : feature matrix normalized - right hemisphere
%
% For Automatic Detection of Focal Cortical Dysplasia
% Tanguy Hamel @ CHRU Lille, 2012


%%
% For Automatic Detection of Focal Cortical Dysplasia
% Tanguy Hamel @ CHRU Lille, 2012

%%

Medl = median(temp_left);
p30l = prctile(temp_left, 30);
p70l = prctile(temp_left, 70);

for j=1 : size(F_left,1)
    
    F_left_norm(j,:) = ( F_left(j,:) - median(F_left(j,:)) ) ./ ( prctile(F_left(j,:),70) - prctile(F_left(j,:),30) );
    F_left_norm(j,:) = F_left_norm(j,:) .* (p70l - p30l) + Medl;
    
end


for j=1 : size(F_right,1)
    
    F_right_norm(j,:) = ( F_right(j,:) - median(F_right(j,:)) ) ./ ( prctile(F_right(j,:),70) - prctile(F_right(j,:),30) );
    F_right_norm(j,:) = F_right_norm(j,:) .* (p70l - p30l) + Medl;
    
end


end