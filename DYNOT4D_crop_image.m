function [I,R] = DYNOT4D_crop_image(I,cota_inf,max_pix_value,gauss_width)
    % gauss_width = 200;
    % max_pix_value = 16384
 
    max_pix_value = max (max_pix_value,100);

    I(I <= cota_inf) = nan;    
    rango = 1:max_pix_value;
    [HH,RR] = hist(I(:),max_pix_value/20);
   
    maxy = max(HH);
    maxx = RR(find(HH == maxy,1,'first'));
    damp = 1;

    %gauss_width = sqrt(maxy);
    g = maxy * dotpro__ngaussian(rango,maxx,gauss_width,damp); 
    R = rango.*(g >= 1);  
    R(R == 0) = nan;
    % MM = max(R(~isnan(R)));
    mm = min(R);
    
    I(I < mm)  = nan;  
    