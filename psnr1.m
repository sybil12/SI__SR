%        ��RGBת��YCbCr��ʽ ȡ���ȷ��������� PSNR 
% Y��ָ���ȷ�����Cbָ��ɫɫ�ȷ�������Crָ��ɫɫ�ȷ�����
% ���ֱ�Ӽ�����ת�����ֵҪС2dB���ң���Ȼ�Ǹ�����ԣ�

%X= imread('photo_data/img3.bmp');  
%Y= imread('photo_data/img1.bmp');  
%PSNR1(X, Y)  %Ĭ�Ϸ��ص�һ������ֵPSNR

function [PSNR, MSE] = psnr1(X, Y)  
%%
if size(X,3)~=1   %�ж�ͼ��ʱ���ǲ�ɫͼrgb������ǣ����Ϊ3������Ϊ1  
    org=rgb2ycbcr(X);  
    test=rgb2ycbcr(Y);  
    Y1=org(:,:,1);    %ֻȡ���ȷ������м���
    Y2=test(:,:,1);  
    Y1=double(Y1);  %����ƽ��ʱ����Ҫת��double���ͣ�����uchar���ͻᶪʧ����  
    Y2=double(Y2);  
else              %�Ҷ�ͼ�񣬲���ת��  
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


MSE = sum(D(:).^2) / numel(Y1);   %numel()���ؾ�����Ԫ�صĸ���
PSNR = 10*log10(255^2 / MSE);  

end
