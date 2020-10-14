function [adc,fa,perp] = calcFA(lambdas)

if ndims(lambdas) == 4
    e1 = squeeze(lambdas(:,:,:,1));
    e2 = squeeze(lambdas(:,:,:,2));
    e3 = squeeze(lambdas(:,:,:,3));
elseif ndims(lambdas) == 2
    e1 = lambdas(1,:);
    e2 = lambdas(2,:);
    e3 = lambdas(3,:);
else
    disp('Cannot understand format of your lambdas. It must be either 2D or 4D');
    lambdas = NaN;
    return;
end

adc  = (e1 + e2 + e3) ./3;

perp = (e2 + e3) ./2;

numerator = sqrt( (e1-adc).^2 + (e2-adc).^2 + (e3-adc).^2 );
denom     = sqrt( e1.^2 + e2.^2 + e3.^2);

fa = (sqrt(3) ./ sqrt(2)) .* (numerator ./ denom);


