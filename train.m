% classify the each LR-HR patch pair into the corresponding cluster and
% compute linear mappings matrix M for each class.
function [class_mapping] = train(train_img_num,patch_size,upscale,lambda,theta)

% clear all;
% close all;
train_img_path = 'Data/Training';


if (nargin ==0)  % 参数个数为0, 只训练一张图像
    patch_size = 3;
    upscale = 2;
    lambda = 1;          %penalty factor
    theta = 15;            %thershold for gradient ,use in patchclass in ptachcut
    train_img_num = 1;
elseif (nargin ==1) % 参数个数为1，只设置训练图形数量
    patch_size = 3;
    upscale = 2;
    lambda = 1;        
    theta = 15;      
elseif(nargin ~=5) %参数个数只能取0，1，5
    class_mapping=zeros(625,36);
    return
end



% generate LR images and generate LR-HR patch pair, and
% compute EO category of the LR-HR patch pair
type='*.jpg';
[hr_patch,lr_patch] = patchcut(train_img_path, type, patch_size, upscale,theta, train_img_num);

%learning the mapping matrix for each class
[class_mapping] = mapping(lr_patch ,hr_patch ,patch_size,upscale, lambda);

fprintf('trainning is done! \n')


return
