%compute the LPE code for the  patch
function [patch_class] = LPC_class(patch , arg, patch_size)
            Nc=arg(1); Nd=arg(2);
            
            c = (patch_size-1)/2; 
            center = patch(c,c); 
            tcc = 256/2^Nc;
            %LPE_C = dec2bin(fix(center/tcc),Nc); %LPE_C
            LPE_C = char(rem(floor( (fix(center/tcc)) * pow2(1-Nc:0)) , 2 )+'0'); %dec2bin
            
            Np = patch_size^2-1;
            LPB = zeros(1,Np);
            d=0; p=0;
            for i=1:patch_size
                for j=1:patch_size
                    if i==c && j==c
                        continue
                    end
                    p=p+1;
                    d = d + abs( patch(i,j) - center );
                    LPB(p) = ( patch(i,j) > center);
                end
            end
            
            d=d/Np;
            %LPE_D = dec2bin(  min(fix(d/5) ,2^Nd-1)  ,Nd); %LPE_D
            LPE_D = char(rem(floor( (min(fix(d/5) ,2^Nd-1) ) * pow2(1-Nd:0)) , 2 )+'0'); %dec2bin
           
            LPB = char(LPB+'0');  %LPB
            LPE=[LPE_C , LPE_D , LPB]; %connect strings

            patch_class = bin2decImpl(LPE);
            if  patch_class == 0
                patch_class = 4096;  %total 2^12=4096 class, from 1 to 4096
            end
            
end


function x=bin2decImpl(s)
    % Convert to numbers
    v = s - '0';
    
    n = length(s);
    twos = pow2(n-1:-1:0);
    x = sum(v .* twos(1,:),2);
end
