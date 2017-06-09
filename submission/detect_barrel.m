function [x,y,d, BW, cc, bb] = detect_barrel(im)
% first to load model:
% load('gmm3.mat','mu','sigma', 'mu_n', 'sigma_n', 'p_barrel', 'p_others','w');
load('gmm_hsv_3.mat','mu','sigma', 'mu_n', 'sigma_n', 'p_barrel', 'p_others','w');
im = rgb2hsv(im);
imtest_1 = im;
re_imtest_1 = reshape(imtest_1, [size(imtest_1,1)*size(imtest_1,2), 3]);

pb = gmm_predict(mu, sigma, double(re_imtest_1)) * p_barrel;
po = gmm_predict(mu_n, sigma_n, double(re_imtest_1)) * p_others;

BW = zeros(size(imtest_1,1)*size(imtest_1,2),1);
BW(pb>po,:) = 1;
BW = reshape(BW, [size(imtest_1,1), size(imtest_1,2)]);
imtest_1 = reshape(re_imtest_1,[size(imtest_1,1), size(imtest_1,2), 3]);

se = strel('ball',10,10);
% for i = 1:5
% BW = imdilate(BW, se);
% BW = imerode(BW, se);
% end
BW = imfill(BW, 'holes');
L = bwlabel(BW);

maxi = 1;
maxa = 1;
for i = 1:max(max(L))
    
    bb = regionprops(L==i, {'Area', 'BoundingBox'});
    if size(bb.BoundingBox,1) ~= 0
        ratio = bb.BoundingBox(4)/bb.BoundingBox(3);
        if~(ratio>0.8 && ratio<2.7)
            continue;
        end
    end
    
    if sum(sum(L==i)) > maxa
        maxi = i;
        maxa = sum(sum(L==i));
    end
end

BW = (L==maxi);
BW = bwconvhull(BW);

npix = sum(sum(BW))+1;
npx = -npix^(0.01);
d = polyval(w, npx)-0.1;

cc= regionprops(BW,'centroid');
bb = regionprops(BW, {'Area', 'BoundingBox'});

x = 0;
y = 0;

if size(cc,1) ~= 0
x=cc.Centroid(:,1);
y=cc.Centroid(:,2);
end
end
