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
% 
% n = size(pixels,1); % number of samples
% dim = size(pixels, 2); % dimensions
% 
% % randomly init mu, sigma, and pi.
% % mu should be k* dim
% mu = rand(k, dim)*255;
% last_mu = mu;
% % sigma should be dim*dim*k
% % sigma = rand(dim, dim, k) *100;
% sigma = reshape(repmat(diag(ones(dim,1)), 1, k),[dim, dim,k]) * 100;
% last_sigma = sigma;
% 
% Pzx = zeros(n, k); % n by k
% 
% j = 1;
% while 1
%     j
%     j = j+1;
%     % E-step, estimate P(z=k|x)  (n, k);
%     for i = 1:k
%        Pzx(:,i) = pii(i)*unimodel_gaussian_predict(mu(i,:), sigma(:,:,i), pixels); 
% %         Pzx(:,i) = mvnpdf(pixels, mu(i,:), sigma(:,:,i)); 
% %        Pzx(:,i) = Pzx(:,i);
%     end
% %     Pzx = max(Pzx, eps);
% %     normp = sum(Pzx')';
% %     for i = 1:k
% %         Pzx(:,i) = Pzx(:,i)/normp(i);
% %     end
% %     Pzx = Pzx./normp;
% %     Pzx = bsxfun(@divide, Pzx, normp);
%     % M-step
%     for i = 1:k
%        pii(i) = 1/n* sum( Pzx(:, i));
%        mu(i,:) = sum(bsxfun(@times, Pzx(:, i), pixels))/sum( Pzx(:, i));
% %        mu
%        x_mu = bsxfun(@minus, pixels, mu(i,:)); % n by dim  
%        x_mu_2 = bsxfun(@times, reshape(x_mu, [size(x_mu,1), size(x_mu,2), 1]), reshape(x_mu, [size(x_mu, 1), 1, size(x_mu,2)]));
%        sigma(:, :, i) = sum(bsxfun(@times, x_mu_2, Pzx(:,i)))  / sum(Pzx(:, i));
%        sigma(:, :, i) = sigma(:, :, i) + 0.000001*eye(size(sigma(:,:,i),1));
%     end
%     
%     norm(last_mu - mu)
%     if norm(last_mu - mu) < 1e-3
%        break; 
%     end
%     last_mu = mu;
% end
% end