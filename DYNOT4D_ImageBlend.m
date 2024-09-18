function DYNOT4D_ImageBlend(IM1,IM2,ax,contr)
    IM1= double(IM1); 
    IM2 =double(IM2);
    
   
    IM2(IM2 == 0) = nan;

    NNANS1 = ~isnan(IM1);
    NNANS2 = ~isnan(IM2);
    MM1 =  max(IM1(NNANS1));
    mm1 = min(IM1(NNANS1));

    if ~isempty(IM2(NNANS2))
        IM2 = IM2 - min(IM2(NNANS2));
        IM2 = MM1 * IM2/max(IM2(NNANS2)) ;
    end;


    fig = get(ax,'Parent');
    
    MM2 =  max(IM2(~isnan(IM2)));
    mm2 = min(IM2(~isnan(IM2)));

    IMSC = imagesc(IM1,[mm1,MM1/contr]);
    
    set(IMSC,'Parent',ax); % ,'LineStyle','none');

    colormap(bone(16384));
    set(IMSC,'AlphaData',0.99);
    freezeColors(ax);
    hold(ax,'on');

    if (~isempty(mm2) && ~isempty(MM2))
        
        [H,R] = hist(IM2(:),ceil(norm(size(IM2),2)));
        F = find(H > 5 ,1,'first');
        IM2(IM2 < R(F)) = nan;
        mm2 = min(IM2(:));
        if (MM2 <= mm2); MM2 = mm2+1; end;
        IMSC2= imagesc(IM2,[mm2 MM2]);
        
        set(IMSC2,'Parent',ax,'Tag','overlayimage'); % ,'LineStyle','none'); 
        set(IMSC2,'ButtonDownFcn',{@dotpro_OverlayImage,ax,IMSC2});
        set(IMSC,'ButtonDownFcn',{@dotpro_OverlayImage,ax,IMSC2});
        set(fig,'WindowScrollWheelFcn',{@dotpro_OverlayImageWheel,ax,IMSC2});
        set(fig,'WindowScrollWheelFcn',{@dotpro_OverlayImageWheel,ax,IMSC2});
    end;
    colormap(jet);
    set(IMSC2,'AlphaData',0.5);
        
    %unfreezeColors;


function dotpro_OverlayImage(hObject, events, myaxes, myhandle)

switch(get(myhandle,'Visible'))
    case 'on'
        set(myhandle,'Visible','off');
    case 'off'
        set(myhandle,'Visible','on');
end;

function dotpro_OverlayImageWheel(hObject, events, myaxes, myhandle)

ad = get(myhandle,'AlphaData');
if events.VerticalScrollCount > 0
    if(ad > 0.1)
        set(myhandle,'AlphaData',max(ad-0.1,0));
    end;
else
    if(ad < 1.0)
        set(myhandle,'AlphaData',min(ad+0.1,1));
    end;
end

    



