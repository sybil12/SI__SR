%  learning the mapping matrix for each class
%  method: classification method
%  regular: regularization method
function [class_mapping] = mapping(lr_patch ,hr_patch ,patch_size,upscale, method, regular, lambda)
if (nargin ==5)  
    regular=0;
elseif (nargin ~=7)  %if regular~=0, then add a regularization iterm
    fprintf(' args num for mapping should be 5 or 7\n')
end

if strcmp(method,'LPC')
    classes = 4096;
elseif strcmp(method,'EO')
    classes = 5^((patch_size-1)^2);  %total class numbers
end


class_mapping =zeros(classes,upscale^2*patch_size^2);   %every line stores a mapping for a class

for i = 1:classes %i means class number
    if sum(lr_patch(:,:,i)) == 0 % no corresponding class index
        temp_class_mapping = 0.1*ones(1,size(class_mapping,2)); 
    else
        if regular==2
        temp_class_mapping = (hr_patch(:,:,i)) * ...
            pinv( (lr_patch(:,:,i)) + (lambda*(ones(patch_size^2)))); 
        else
            temp_class_mapping = (hr_patch(:,:,i)) * pinv( lr_patch(:,:,i) );
        end
    end
%     temp_class_mapping=reshape(temp_class_mapping',1,numel(temp_class_mapping));
    temp_class_mapping=temp_class_mapping';
    class_mapping(i,:) = temp_class_mapping(:)';
    
    
end
