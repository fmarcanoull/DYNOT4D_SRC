
function dotpro_MultipleAxesCallback(hObject, events, myaxes, mypos)
global IMAGE;
global SMF_SelectAxes;
   
if (SMF_SelectAxes == 1); return; end;
SMF_SelectAxes = 1;
        
    axes(myaxes);
    ch = findobj(gcf,'Type','rectangle');
    delete(ch);
    lims = [get(myaxes,'Xlim') get(myaxes,'Ylim')];
    lims = [lims(1) lims(3) lims(2) lims(4)];
    
    rectangle('Position',lims,...
         'LineWidth',8,'LineStyle','-','EdgeColor',[1 0 0]);
     IMAGE.currentSlice=mypos;
     
    units0 = get(get(myaxes,'Parent'),'Units');
    PP = get(myaxes,'Parent');
     
    set(PP,'Units','pixel');
    pos = get(get(myaxes,'Parent'),'OuterPosition');

    vw = IMAGE.transformIndex;
     
    dotpro_ROI_definition(vw, mypos,'pixel',[pos(1)-pos(4)-10 pos(2)-10     pos(4) pos(4)+20]);
    set(PP,'Units',units0);
   
SMF_SelectAxes = 0;

end

