function [score] = unimodel_gaussian_predict(mu, sigma, x)
% pixel: rgb 1x3
% mu: 1x3
% A_1: A^(-1) 3x3
pixel = double(x);
dim = size(x, 2);
x_mu = bsxfun(@minus, x, mu);

[R,err] = cholcov(sigma); 


% xRinv(i,:) = X0(i,:) / R;
% x_mu_R = zeros(size(x,1),size(x,2));
% for i = 1:size(x,1)
%     x_mu_R(i,:) = x_mu(i,:)/R;
% end
x_mu_R = x_mu / R;
quadform = sum(x_mu_R.^2, 2);
score = 1/sqrt((2*pi)^dim*det(sigma)) * exp(-0.5*quadform);

% mvnpdf(x, mu, sigma);
% score = sqrt(det(A_1)+0.00001)/(2*pi)^(3/2) * exp(-0.5*(pixel - mu) * A_1 * (pixel- mu)');
% score = sqrt(det(A_1))/(2*pi)^(3/2) *   exp(-0.5* bsxfun(@minus, pixels, mu) * A_1 * bsxfun(@minus, pixels, mu)'));
end