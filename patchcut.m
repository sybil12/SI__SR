% generate LR images and generate LR-HR patch pair, and
% compute class for the LR-HR patch pair
% method='EO'     arg=thershold
% method='LPC'    arg=[Nc, Nd]

function [hr_patch,lr_patch] = patchcut(img_path, type, train_img_num,  patch_size, upscale, method, arg)
%%  读取img_path中的所有格式为type的文件；
img_dir = dir(fullfile(img_path,type));  %列出img_path中的所有格式为type的文件；
%dir批量读取文件   %fullfile()利用文件各部分信息创建并合成完整文件名

%      存的不是patch原来的值，而是计算mapping的中间值 xc*yc' 和 yc*yc'
if strcmp(method,'LPC')
    hr_patch = zeros(4,9,4096); %12 bits LPE
    lr_patch = zeros(9,9,4096);
    if length(arg)~=2
        error('arg should have 2 elements for LPC class: Nc Nd!! \n')
    end
elseif strcmp(method,'EO')
    hr_patch = zeros(4,9,625);  %the 3rd dim presents EO class
    lr_patch = zeros(9,9,625);
    if length(arg)~=1
        error('arg should have 1 elements for EO class: thershold!! \n')
    end
end


img_num = length(img_dir); %img_num检测到的文件个数，train_img_num是要求检测的文件个数
img_num = min(img_num, train_img_num);

hint_w=waitbar(0,'正在训练图片...');pause(0.2)
patch_number = 0;  %total number of patches
tic;

%%    strart trainning
for ii = 1:img_num
    str=['正在训练第', num2str(ii) ,'张图片...'];
    waitbar(ii/img_num,hint_w,str);

    %input the HR image
    img = imread(fullfile(img_path, img_dir(ii).name));

    %RGB to ycbcr
    im_l_ycbcr = rgb2ycbcr(img);
    hr = im_l_ycbcr(:, :, 1);   %Only the brightness component is used for training
    
    % generate the corresponding LR image
    lr = imresize( imfilter( hr,fspecial('gaussian'),'same','replicate'), 1/upscale, 'bicubic');
%{     
    imresize改变图像大小  imfilter滤波处理函数 fspecial产生滤波算子
    imrersize函数使用由参数method指定的插值运算来改变图像的大小。
    B = imresize(A,m,method)
    g = imfilter(f, w, filtering_mode, boundary_options, size_options) ;     
%}
    
    lrow = size(lr, 1); lcol = size(lr, 2);     %get the size of LR patch
    radius = (patch_size-1)/2;                %radius（半径） of LR patch 
    
    % get LR-HR patches and their EO categories
    for i = 1+radius:lrow-radius   % {(i,j)} 是patch中心坐标可移动的范围
        for j = 1+radius:lcol-radius
           
            %patch of lr
            patch1 = lr(i-radius:i+radius,j-radius:j+radius);
            patch1 = double(patch1');
            patch1_vector = patch1(:)';   %change to row vector(1*9)
            patch1_vector = double(patch1_vector);
            
           %patch of hr
            patch2 = hr(2*i-1:2*i,2*j-1:2*j);
            patch2 = double(patch2);
            patch2_vector = reshape(patch2',1,4);  % upscaling factor is 2
            patch2_vector = double(patch2_vector);

            %  get the class of the  current patch 
            if strcmp(method,'LPC')
                temp_class = LPC_class( patch1,arg, patch_size); %arg=[Nc, Nd]
            elseif strcmp(method,'EO')
                temp_class = EOclass( patch1, arg, patch_size); %arg=thershold
            end

            
            % store the current patch as its EO class, not the original value 
            % but Intermediate calculation result for compute mapping
            Q = (patch2_vector')* patch1_vector;        %xc*yc'
            V = (patch1_vector')* patch1_vector;        %yc*yc'
            hr_patch(:,:,temp_class) =  hr_patch(:,:,temp_class) + Q;   %sum for xc*yc'
            lr_patch(:,:,temp_class) =  lr_patch(:,:,temp_class) + V;      %sum for yc*yc'
            
            patch_number = patch_number+1;
            
        end
    end
    
    
end

%%
toc;
waitbar(100,hint_w,'训练已完成，窗口即将关闭..');pause(0.3)
close(hint_w);

% patch_path = ['Training/LR-HR patch ' num2str(patch_size) '-' num2str(patch_number) '.mat'];
% save(patch_path, 'lr_patch','hr_patch');


return

