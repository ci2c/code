function mse = eval_mcLeastR_mse(Y, X, W)
%% FUNCTION eval_MTL_mse
%   computation of mean squared error given a specific model.
%   the value is the lower the better.
   

mse = 0;
    
total_sample = 0;
y_pred = X * W;

mse = sum( (ypred - Y).^2 ) / 

mse = sqrt( sum( (y_pred - Y).^2)  ) / length(y_pred);
total_sample = total_sample + length(y_pred);
end

%mse = mse./total_sample;
