load('labeled.mat', 'data');
train_prefix = 'Training_set/';


parts = make_xval_partition(size(data,1),5);
test_set = data(logical(parts == 1));
train_set = data(logical(parts ~= 1));
% train_set = data([1:50]);

% train_set = train_set(1:10);

train_prefix = 'Training_set/';
pixels = [];  % RGB n * 3;
pixels_n = [];
distances = [];
ratios = [];
bbs=[];
for i = 1:size(train_set,1)
    i
    im = imread( strcat(train_prefix, train_set(i).name ));
    im = rgb2hsv(im);
    area = train_set(i).area;
    bb = regionprops(area, {'Area', 'BoundingBox'});
    
    if size(bb.BoundingBox,1) ~= 0
        ratio = bb.BoundingBox(4)/bb.BoundingBox(3);
        ratios = [ratios;ratio];
    end
    
    px = find(area);
    px_n = find(area==0);
    im_reshape = reshape(im, [size(im,1)*size(im,2), size(im,3)]);
%     immean = bsxfun(@minus, double(im_reshape),double(mean(im_reshape)));
%     if(train_set(i).distance<=10)
    distances = [distances;size(px,1),train_set(i).distance];
    x = -distances(:,1).^(0.01);
    y = distances(:,2);
%     end
    pixels = [pixels;im_reshape(px,:)];
    pixels_n = [pixels_n; im_reshape(px_n,:)];
end
w = polyfit(x,y,2);


pixels = double(pixels);
pixels_n = double(pixels_n);

p_barrel = size(pixels, 1)/(size(pixels, 1)+size(pixels_n,1));
p_others = size(pixels_n, 1)/(size(pixels, 1)+size(pixels_n,1));

%% train models

[mu, sigma] = gmm_train(pixels,3);
[mu_n, sigma_n] = gmm_train(pixels_n,3);
%% save parameters
save('gmm_hsv_3.mat','mu','sigma', 'mu_n', 'sigma_n', 'p_barrel', 'p_others', 'w')
%%

err_d = 0;

for i = 1:size(test_set,1)

imtest_1 = imread(strcat(train_prefix,  test_set(i).name));
imtest_1 = rgb2hsv(imtest_1);


re_imtest_1 = reshape(imtest_1, [size(imtest_1,1)*size(imtest_1,2), 3]);

pb = gmm_predict(mu, sigma, double(re_imtest_1)) * p_barrel;
po = gmm_predict(mu_n, sigma_n, double(re_imtest_1)) * p_others;

BW = zeros(size(imtest_1,1)*size(imtest_1,2),1);
% re_imtest_1(pb>po,:) = 255;
BW(pb>po,:) = 1;
BW = reshape(BW, [size(imtest_1,1), size(imtest_1,2)]);
imtest_1 = reshape(re_imtest_1,[size(imtest_1,1), size(imtest_1,2), 3]);

se = strel('ball',5,5);
% for i = 1:2
% BW = imdilate(BW, se);
% BW = imerode(BW, se);
BW = imfill(BW, 'holes');
% end


L = bwlabel(BW);
maxi = 1;
maxa = 1;
for j = 1:max(max(L))
    if sum(sum(L==j)) > maxa
        maxi = j;
        maxa = sum(sum(L==j));
    end
end

BW = (L==maxi);

npix = sum(sum(BW))+1;
npx = -npix^(0.01);
d = polyval(w, npx)
test_set(i).distance
err_d = err_d + (d-test_set(i).distance)^2;

cc= regionprops(BW,'centroid');
stats2 = regionprops(BW, {'Area', 'BoundingBox'});
imshow(imtest_1);

if size(cc,1) ~= 0
hold on;
plot(cc.Centroid(:,1), cc.Centroid(:,2), 'b+');
hold on;
rectangle('Position',[stats2.BoundingBox(1),stats2.BoundingBox(2),stats2.BoundingBox(3),stats2.BoundingBox(4)],...
     'EdgeColor','y','LineWidth',1 );
end



pause(0.1);

end
err_d

%% 

test_prefix = 'Training_set/';
dirstruct = dir(strcat(test_prefix,'*.png'));
for i = 1:length(dirstruct)
    im = imread(strcat(test_prefix,dirstruct(i).name));
    
    [x,y,d, BW, cc, bb] = detect_barrel(im);
    imshow(im);
    if size(cc,1) ~= 0
    hold on;
    plot(cc.Centroid(:,1), cc.Centroid(:,2), 'b+');
    hold on;
    rectangle('Position',[bb.BoundingBox(1),bb.BoundingBox(2),bb.BoundingBox(3),bb.BoundingBox(4)],...
         'EdgeColor','y','LineWidth',1 );
    end
    pause(0.1);
end
    
%% test 3

load('labeled.mat', 'data');
train_prefix = 'Test_set/';
% dirstruct = dir(strcat(test_prefix,'*.png'));
err_d=0;
dhat = zeros(size(data,1),1);
dtruth = zeros(size(data,1),1);
for i = 1:size(data,1)
    i
%   im = imread(strcat(test_prefix,dirstruct(i).name));
    im = imread(strcat(train_prefix, data(i).name));
    
    [x,y,d, BW, cc, bb] = detect_barrel(im);
    
    dhat(i) = d;
    dtruth(i) = data(i).distance;
    err_d = err_d+(d- data(i).distance)^2;
    imshow(im);
    if size(cc,1) ~= 0
    hold on;
    plot(cc.Centroid(:,1), cc.Centroid(:,2), 'b+');
    hold on;
    rectangle('Position',[bb.BoundingBox(1),bb.BoundingBox(2),bb.BoundingBox(3),bb.BoundingBox(4)],...
         'EdgeColor','y','LineWidth',1 );
    end
    pause(0.1);
end
err_d