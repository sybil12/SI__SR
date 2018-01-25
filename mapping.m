%%　learning the mapping matrix for each class
function [class_mapping] = mapping(lr_patch ,hr_patch ,patch_size,upscale, lambda);

classes=5^((patch_size-1)^2);  %total class numbers
class_mapping =zeros(classes,upscale^2*patch_size^2);   %every line stores a mapping for a EO category

for i = 1:classes %i means class number
    if sum(lr_patch(:,:,i)) == 0 %对应索引值没有patch时
        temp_class_mapping = 0.1*ones(1,size(class_mapping,2)); 
    else
        temp_class_mapping = (hr_patch(:,:,i)) * ...
            pinv( (lr_patch(:,:,i)) + (lambda*(ones(patch_size^2)))); 
    end
%     temp_class_mapping=reshape(temp_class_mapping',1,numel(temp_class_mapping));
    temp_class_mapping=temp_class_mapping';
    class_mapping(i,:) = temp_class_mapping(:)';
    
    
end
