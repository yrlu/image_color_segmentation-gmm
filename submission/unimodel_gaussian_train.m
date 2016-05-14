function [mu, sigma]= unimodel_gaussian_train(pixels)

% input pixels (Nv*3)
% compute mu and A for mutli-dimenional gaussian
% argmax(mu, A) P(x|"barrel") = argmax(mu, A) sqrt(detA/(2pi)^3)*exp(-0.5 (x-mu) * A * (x-mu))

pixels = double(pixels);
mu = mean(pixels);
Nv = size(pixels,1);
k = size(pixels,2);
x_mu = bsxfun(@minus, pixels, mu); % n*3
sigma = cov(pixels);
end



