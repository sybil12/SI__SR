%compute the EO class for the  patch
function [patch_class] = patchclass(patch ,thershold ,patch_size)
            class_index = zeros( 1, (patch_size-1)^2 );  %store EO class for every subpatch
            for iii = 1:patch_size-1
                for jjj = 1:patch_size-1
                       
                    % p1 p2 p3 p4 is a subpacth
                    p1=patch(iii,jjj);
                    p2=patch(iii,jjj+1);
                    p3=patch(iii+1,jjj);
                    p4=patch(iii+1,jjj+1);
                    
                    % compute the horizontal gradient and vertical gradient.
                    gh = p1-p2+p3-p4;
                    gv = p1+p2-p3-p4;
                    gh = double(gh);
                    gv = double(gv);
            
                    
                    m = sqrt(gh^2 + gv^2);
                    if gv == 0
                        d = pi/2;
                    else
                        d = atan(gh/gv);
                    end
                    
                    %comput the EO class of the  subpatch ,
                    %and EO categories of all subpatches are stored in  class_index 
                    if m < thershold
                            class_index((iii-1)*(patch_size-1)+jjj)= 0;
                    elseif (d>(-22.5/180)*pi)&&(d<=(22.5/180)*pi)%-0.3927<d<0.3927
                            class_index((iii-1)*(patch_size-1)+jjj)= 1;
                    elseif (d>(22.5/180)*pi)&&(d<=(67.5/180)*pi)%0.3927<d<1.1781
                            class_index((iii-1)*(patch_size-1)+jjj)= 2;
                    elseif (d<=(-67.5/180)*pi)||(d>(67.5/180)*pi)%d<-1.1781或d>1.1781
                            class_index((iii-1)*(patch_size-1)+jjj)= 3;
                    elseif (d>(-67.5/180)*pi)&&(d<=(-22.5/180)*pi)%-1.1781<d<-0.3927
                            class_index((iii-1)*(patch_size-1)+jjj)= 4;
                    end
                    
                end
            end
            
            patch_class = 0;  %EO class of the  current patch 
            for m=1:size(class_index,2)
                patch_class = patch_class + class_index(m)*(5^(m-1));        %相当于一个五进制数
            end
            if  patch_class == 0
                patch_class = 625;  %总共5^4=256个EO类，从1-256
            end
end
