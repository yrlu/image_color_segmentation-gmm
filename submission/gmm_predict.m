function [score] = gmm_predict(mu, sigma, x)
    score = zeros(size(x,1),1);
    for i = 1: size(mu,1)
       score = score + unimodel_gaussian_predict(mu(i,:), sigma(:,:,i), x); 
    end
    score = score/ size(x,1);
end