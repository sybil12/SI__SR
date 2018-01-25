%        将RGB转成YCbCr格式 取亮度分量来计算 PSNR 
% Y是指亮度分量，Cb指蓝色色度分量，而Cr指红色色度分量。
% 如果直接计算会比转后计算值要小2dB左右（当然是个别测试）

%X= imread('photo_data/img3.bmp');  
%Y= imread('photo_data/img1.bmp');  
%PSNR1(X, Y)  %默认返回第一个返回值PSNR

function [PSNR, MSE] = psnr1(X, Y)  
%%
if size(X,3)~=1   %判断图像时不是彩色图rgb，如果是，结果为3，否则为1  
    org=rgb2ycbcr(X);  
    test=rgb2ycbcr(Y);  
    Y1=org(:,:,1);    %只取亮度分量进行计算
    Y2=test(:,:,1);  
    Y1=double(Y1);  %计算平方时候需要转成double类型，否则uchar类型会丢失数据  
    Y2=double(Y2);  
else              %灰度图像，不用转换  
    Y1=double(X);  
    Y2=double(Y);  
end  
   
 
if any(size(Y1)~=size(Y2))  
    %     error('The input size is not equal to each other!');  
    s1 = (size(Y1,1)-size(Y2,1))/2;
    s2 = (size(Y1,2)-size(Y2,2))/2;
    Y1 = Y1(1+s1 : size(Y1,1)-s1 , 1+s2 : size(Y1,2)-s2);
end

D = Y1 - Y2; 


MSE = sum(D(:).^2) / numel(Y1);   %numel()返回矩阵中元素的个数
PSNR = 10*log10(255^2 / MSE);  

end
