% generate LR images and generate LR-HR patch pair, and
% compute EO class of the LR-HR patch pair

function [hr_patch,lr_patch] = patchcut(img_path, type, patch_size, upscale,theta,train_img_num)
%%  ��ȡimg_path�е����и�ʽΪtype���ļ���
img_dir = dir(fullfile(img_path,type));  %�г�img_path�е����и�ʽΪtype���ļ���
%dir������ȡ�ļ�   %fullfile()�����ļ���������Ϣ�������ϳ������ļ���

%      ��Ĳ���patchԭ����ֵ�����Ǽ���mapping���м�ֵ xc*yc' �� yc*yc'
hr_patch = zeros(4,9,625);  %the 3rd dim presents EO class
lr_patch = zeros(9,9,625);  

img_num = length(img_dir); %img_num��⵽���ļ�������train_img_num��Ҫ������ļ�����
img_num = min(img_num, train_img_num);

hint_w=waitbar(0,'����ѵ��ͼƬ...');pause(0.2)
patch_number = 0;  %total number of patches
tic;

%%    strart trainning
for ii = 1:img_num
    str=['����ѵ����', num2str(ii) ,'��ͼƬ...'];
    waitbar(ii/img_num,hint_w,str);

    %input the HR image
    img = imread(fullfile(img_path, img_dir(ii).name));

    %RGB to ycbcr
    im_l_ycbcr = rgb2ycbcr(img);
    hr = im_l_ycbcr(:, :, 1);   %Only the brightness component is used for training
    
    % generate the corresponding LR image
    lr = imresize( imfilter( hr,fspecial('gaussian'),'same','replicate'), 1/upscale, 'bicubic');
%{     
    imresize�ı�ͼ���С  imfilter�˲������� fspecial�����˲�����
    imrersize����ʹ���ɲ���methodָ���Ĳ�ֵ�������ı�ͼ��Ĵ�С��
    B = imresize(A,m,method)
    g = imfilter(f, w, filtering_mode, boundary_options, size_options) ;     
%}
    
    lrow = size(lr, 1); lcol = size(lr, 2);     %get the size of LR patch
    radius = (patch_size-1)/2;                %radius���뾶�� of LR patch 
    
    % get LR-HR patches and their EO categories
    for i = 1+radius:lrow-radius   % {(i,j)} ��patch����������ƶ��ķ�Χ
        for j = 1+radius:lcol-radius
           
            %patch of lr
            patch1 = lr(i-radius:i+radius,j-radius:j+radius);
            patch1 = double(patch1');
            patch1_vector = patch1(:)';   %change to row vector(1*9)
            patch1_vector = double(patch1_vector);
% %             lr_patch = [lr_patch;patch1_vector];
            
           %patch of hr
            patch2 = hr(2*i-1:2*i,2*j-1:2*j);
            patch2 = double(patch2);
            patch2_vector = reshape(patch2',1,4);  % upscaling factor is 2
            patch2_vector = double(patch2_vector);
% %             hr_patch = [hr_patch;patch2_vector];

            %  get the EO class of the  current patch 
            temp_class = patchclass( patch1, theta, patch_size);

            
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
waitbar(100,hint_w,'ѵ������ɣ����ڼ����ر�..');pause(0.3)
close(hint_w);

% patch_path = ['Training/LR-HR patch ' num2str(patch_size) '-' num2str(patch_number) '.mat'];
% save(patch_path, 'lr_patch','hr_patch');


return

