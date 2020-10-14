function [TC_OUT,param] = TemporalRegularization(TCN,param)

% computes temporal regularization for all voxels

% cost computation -- for synthetic data

TC_OUT = zeros(param.Dimension(4),param.NbrVoxels);

if (param.COST_SAVE)
    param.cost_TEMP = [];
end
param.NitTemp  = param.NitTemp*5;
[TC_OUT,param] = MyTemporal(TCN,param);
        
end