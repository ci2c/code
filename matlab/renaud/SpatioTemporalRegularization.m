function [TC_OUT,param] = SpatioTemporalRegularization(TCN,atlas,param)

% computes spatio-temporal regularization for all voxels

% cost computation -- for synthetic data

TC_OUT = zeros(param.Dimension(4),param.NbrVoxels);

% paramOUT = cell(1,param.NbrVoxels);
switch lower(param.METHOD_SPAT)
    
    case{'no'}
        
        if (param.COST_SAVE)
            param.cost_TEMP = [];
        end
        param.NitTemp  = param.NitTemp*5;
        [TC_OUT,param] = MyTemporal(TCN,param);
        
    case{'tik'} % fgp_L2.m
        
        xT = zeros(param.Dimension(4),param.NbrVoxels); % temporal
        xS = zeros(param.Dimension(4),param.NbrVoxels); % spatial
        k  = 1;
        while (k <= param.Nit)
            [temp,param] = MyTemporal(TC_OUT-xT+TCN,param);
            xT           = xT + (temp - TC_OUT); % update temporal, stepsize=1; xT = xT + stepsize*(temp - TC_OUT);
            if(k<param.Nit)
                temp2 = Spatial_Tikhonov(TC_OUT,TC_OUT-xS+TCN,param); % calculates for the whole volume
                xS    = xS+(temp2-TC_OUT);
            end
            TC_OUT = xT*param.weights(1)+param.weights(2)*xS;
            k = k+1;
        end
        
        
    case{'strspr'}
        
        xT = zeros(param.Dimension(4),param.NbrVoxels); % temporal
        xS = zeros(param.Dimension(4),param.NbrVoxels); % spatial
        k  = 1;
        
        if (param.COST_SAVE)
            param.cost_TEMP    = [];
            param.cost_SPATIAL = [];
        end
        
        while (k <= param.Nit)
            param.NitTemp = param.NitTemp+100; % increase temporal step at each iteration for better convergence.
            [temp,param]  = MyTemporal(TC_OUT-xT+TCN,param);
            fprintf('Temporal \n');
            xT = xT + (temp - TC_OUT); % update temporal, stepsize=1; xT = xT + stepsize*(temp - TC_OUT);
            if(k <= param.Nit)
                [temp2,param] = Spatial_StrSpr(TC_OUT-xS+TCN,atlas,param); % calculates for the whole volume
                xS            = xS+(temp2-TC_OUT);
            end
            fprintf('Spatial \n');
            TC_OUT = xT*param.weights(1)+param.weights(2)*xS;
            if (param.COST_SAVE)
                param.cost_TOTAL(k) = calculate_totalcost(TC_OUT,TCN,atlas,param);
            end
            %        param.SOL{k} = TC_OUT;
            k = k+1;
        end
        %        param.temp =temp;
        
    otherwise
        error('Unknown Method.')
end

end