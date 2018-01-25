% Super-Interpolation with edge-orientation-based mapping kernels
%           2018.01.25 BY sisiyin changed on  Duan Peiqi, 2017



% clear; close all;
% % ------ training the mapping------
% train_img_num=20;
% [class_mapping] = train(train_img_num);


%%   upscaling
% ------- input test images -------- 
test_img_path = 'Data/Testing';
test_num=5;
% type={'*.jpg'; '*.bmp'}; %jpg type is too big to show
type='*.bmp';
imgs=fullfile(test_img_path,type);
if iscell(type)
    test_dir = dir(char(imgs(1)));
    for s= 2:length(imgs)
        test_dir = [test_dir; dir(char(imgs(s)))];
    end
else
     test_dir = dir(imgs);
end
num = min(test_num,length(test_dir)); %image nums to test



% ------- get the LR images, and reconstruct a HR one -------- 
patch_size = 3;
upscale = 2;
theta = 15;%thershold for gradient
lambda = 1;%penalty factor


tic;
for tt = 1:num
    str=['正在放大第', num2str(tt) ,'张图 ... ... \n']; fprintf(str)
    
    %% get LR for the input HR image, and then upscaling
    test_img = imread(fullfile(test_img_path, test_dir(tt).name));
%     test_img = imread('Data/Testing/lenna.bmp');
    if size(test_img, 3) == 3
        test_hr_ycbcr = rgb2ycbcr(test_img);
    else
        test_hr_ycbcr = test_img;
    end
    test_lr_ycbcr = imresize(imfilter(test_hr_ycbcr,fspecial('gaussian'),'same','replicate'), 1/upscale, 'bicubic');
    
    test_lr = test_lr_ycbcr(:, :, 1); 
    test_lr_cb = test_lr_ycbcr(:, :, 2);
    test_lr_cr = test_lr_ycbcr(:, :, 3);
    
    % Only the brightness component used for the SI method.
    lrow = size(test_lr, 1);  lcol = size(test_lr, 2);
    radius = (patch_size-1)/2;                %radius（半径） of LR patch 
    
    %get LR patches and their EO categories, and generate its HR patch
    patch_nums = (lrow-2*radius)*(lcol-2*radius);
    generate_hr_patch=zeros(patch_nums, upscale^2);
    nn=0;
    for i = 1+radius:lrow-radius   % {(i,j)} 是patch中心坐标可移动的范围
        for j = 1+radius:lcol-radius
            nn=nn+1;
            test_patch = test_lr(i-radius:i+radius,j-radius:j+radius);
            test_patch = double(test_patch');
            test_patch_vector = test_patch(:)';   %change to row vector(1*9)
            test_patch_vector = double(test_patch_vector);
           
            test_patch_class= patchclass( test_patch, theta, patch_size);
            m = class_mapping(test_patch_class,:);
            m = reshape(m,patch_size^2,upscale^2);
            temp_hr_patch = double(m')*double(test_patch_vector'); %get LR patches
            generate_hr_patch(nn,:) = reshape(temp_hr_patch',1,upscale^2);
            
        end
    end
 
    %% Composite   the brightness component for HR image 
    str=['正在合成第', num2str(tt) , '张放大图像 ... ... \n'];  fprintf(str)
    
    % ------ generate the HR image -------
    generate_hr_size = [2*(size(test_lr,1)-2) , 2*(size(test_lr,2)-2) ]; %放大两倍
    generate_hr_img = zeros(generate_hr_size);
   k=0;
    for i=1 : upscale :  generate_hr_size(1)
        for j=1 : upscale : generate_hr_size(2)
            k=k+1;
            generate_hr_img(i:i+upscale-1,j:j+upscale-1) =...
                (reshape(generate_hr_patch(k,:),upscale,upscale))';
        end
    end
    
    %%  display
%     generate_hr_cb = imresize(test_lr_cb, upscale, 'bicubic');
%     generate_hr_cr = imresize(test_lr_cr, upscale, 'bicubic');
%     generate_hr_cb = generate_hr_cb(1+upscale:size(generate_hr_cb,1)-upscale,1+upscale:size(generate_hr_cb,2)-upscale);
%     generate_hr_cr = generate_hr_cr(1+upscale:size(generate_hr_cr,1)-upscale,1+upscale:size(generate_hr_cr,2)-upscale);
%     
%     
%     generate_hr_ycbcr = zeros([size(generate_hr_img,1), size(generate_hr_img,2), 3]);
%     generate_hr_ycbcr(:, :, 1) = generate_hr_img;
%     generate_hr_ycbcr(:, :, 2) = generate_hr_cb;
%     generate_hr_ycbcr(:, :, 3) = generate_hr_cr;
%     generate_hr = ycbcr2rgb(uint8(generate_hr_ycbcr));
%     
%     if tt>1
%         close(1,2,3);
%     end
%     figure(1); imshow(test_img);axis off;title('input hr');
%     figure(2); imshow(ycbcr2rgb(test_lr_ycbcr));axis off;title('input lr');
%     figure(3); imshow(generate_hr);axis off;title('output hr');
    
    
    
%% ------ compute the PSNR and SSIM  between output HR and input HR ------

    mpsnr = psnr1(test_hr_ycbcr(:,:,1) ,generate_hr_img);
    fprintf('    PSNR=%f   \n',mpsnr)
    
    K = [0.01 0.03];  
    window = ones(8);  
    L = 100; 
    [mssim, ssim_map] = ssim(test_hr_ycbcr(:,:,1),generate_hr_img, K, window, L); %只计算亮度分量
    fprintf('    SSIM=%f\n',mssim)

end
toc;

