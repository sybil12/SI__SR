% classify the each LR-HR patch pair into the corresponding cluster and
% compute linear mappings matrix M for each class.
function [class_mapping] = train(train_img_num,patch_size,upscale,arg1,arg2)

% clear all;
% close all;

train_img_path = 'Data/Training';
% method = 'EO';
method =  'LPC';

if (nargin <2)  
    patch_size = 3;
    upscale = 2;
    if strcmp(method,'LPC')
        arg = [2,2];         %Nc Nd
    elseif strcmp(method,'EO')
        lambda = 1;        %penalty factor in L2 regularization
        arg = 15;            %thershold for gradient ,use in patchclass in ptachcut
    end
    if(nargin == 0)
    	train_img_num = 1;  % 0 args, The default number of the training images is 1
    end
    
elseif(nargin ==5) 
    if strcmp(method,'LPC')
        arg=[arg1,arg2];  %Nc Nd
    elseif strcmp(method,'EO')
        lambda = arg1;
        arg=arg2;  %thershold for gradient
    end
    
else % The number of parameters can only be 0,1,5.
    error('The number of parameters can only be 0,1,5. \n ')
end


type='*.jpg';
% generate LR images and generate LR-HR patch pair, and
% compute LPC class of the LR-HR patch pair
[hr_patch,lr_patch] = patchcut(train_img_path, type,train_img_num,...
    patch_size, upscale, method, arg);
    
%learning the mapping matrix for each class
if strcmp(method,'LPC')
    [class_mapping] = mapping(lr_patch ,hr_patch, patch_size, upscale, method);
elseif strcmp(method,'EO')
    [class_mapping] = mapping(lr_patch ,hr_patch, patch_size, upscale, method,...
        2, lambda);  %L2 regularlation 
end



fprintf('trainning is done! \n')


return
