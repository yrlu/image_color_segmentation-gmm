function [mu, sigma] = gmm_train(x, k)

n = size(x,1);
dim = size(x, 2);

% first, we have to initialize mu, sigma
% mu is k by dim;
thres = 1
if max(max(x))<10
    thres = 10e-5;
end

mu = rand(k, dim)*max(max(x));
last_mu = mu;

% sigma is dim x dim x k; so sigma(:,:,i) is dim * dim;
sigma = reshape(repmat(diag(ones(dim,1)), 1, k),[dim, dim,k]) * 100;

% the probabilities is n x k.
z = zeros(n, k);

j = 0;
while j<100
    j = j+1
    % e-step
    % compute z(i, j);
    for i = 1: k
       z(:,i) = unimodel_gaussian_predict(mu(i,:), sigma(:,:,i), x); 
    end
    normz = 1./sum(z',1)'; % n x 1
    z = bsxfun(@times, z, normz);
    
%     z = bsxfun(@times, z, 1./normz);
    
    % m-step
    for i = 1:k
        mu(i, :) = sum( bsxfun(@times,z(:,i), x) ) / sum( z(:,i) );
        x_mu = bsxfun(@minus, x, mu(i,:)); % n by dim  
        x_mu_2 = bsxfun(@times, reshape(x_mu, [size(x_mu,1), size(x_mu,2), 1]), reshape(x_mu, [size(x_mu, 1), 1, size(x_mu,2)]));
        sigma(:,:,i) = sum(bsxfun(@times, x_mu_2, z(:,i)))  / sum(z(:, i));
        sigma(:, :, i) = sigma(:, :, i) + 0.000001*eye(size(sigma(:,:,i),1));
    end
    
    norm(last_mu - mu)
    if norm(last_mu - mu) < thres
       break;
    end
    last_mu = mu
end


end