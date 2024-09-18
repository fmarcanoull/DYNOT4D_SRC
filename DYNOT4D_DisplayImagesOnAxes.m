function DYNOT4D_DisplayImagesOnAxes(handles, figno,transformIndex, Hbstate, sliceN, SpecifyROIFlag)
    global IMAGE;
    IMAGE.currentSlice=[];
    cla(figno);
    set(figno,'units','normalized');
    window_pos = get(figno, 'Position');
    CurrentImage = IMAGE.currentImage; 
    CurrentImage(CurrentImage == 0) = nan;
    sliceN = AxesGridDist(transformIndex,sliceN,CurrentImage);
    slice_row_N = floor(sqrt(sliceN));
    slice_column_N = ceil(sliceN/slice_row_N);
    vdimx=[1 max(IMAGE.DIM(1))]; 
    vdimy=[1 max(IMAGE.DIM(2))]; 

    %%% Borrar slices previos
    ch = findobj('Tag','slice overlay panel');
    if(~isempty(ch))
        delete(ch);
    end;
    %%% Crear nuevos slices
    axisd = resetaxis (figno, vdimx, vdimy, slice_row_N, slice_column_N, window_pos);

    IMAGE.axisd=axisd;
    set(figno,'UserData',axisd);

    IMAGE.transformIndex = transformIndex;
    try 
        clim=[IMAGE.scale_image_C];
        if isempty(clim);
            clim=[min(CurrentImage(:)) max(CurrentImage(:))];
        end
    catch
        clim=[min(CurrentImage(:)) max(CurrentImage(:))];
    end;
    
    iz = 0;
    switch(transformIndex)
    case 1, %% axial
        CurrentImage = permute(CurrentImage,[1 2 3]);   
        CurrentImage  =  CurrentImage (:,:,end:-1:1);
    case 2, %%% sagittal
        CurrentImage = permute(permute(CurrentImage,[1 3 2]),[2 1 3]);        
    case 3, %%% coronal
        CurrentImage = permute(CurrentImage,[3 2 1]);
    end;
    
    for i=1:size(CurrentImage,3)
        SLC = squeeze(CurrentImage(:,:,i));
        if(sum(~isnan(SLC(:))) == 0); continue; end;
        iz = iz + 1;
        imagesc('Parent', axisd(iz),...
            'ButtonDownFcn',{@dotpro_MultipleAxesCallback,axisd(iz),i},...
            'CData',SLC, clim); 
        sz = size(SLC);
        set(axisd(iz),'XLim',[1 sz(2)],'YLim',[1 sz(1)]);
    end;
  
    axes(figno); axis off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function N = AxesGridDist(transformIndex,sliceN,CurrentImage)
    switch(transformIndex)
        case 1, %% axial
            N = sum(squeeze(sum(sum(~isnan(CurrentImage)))) >0);
        case 2, %%% sagittal  
            N = sum(squeeze(sum(sum(~isnan(permute(permute(CurrentImage,[1 3 2]),[2 1 3]))))) >0);
        case 3, %%% coronal
            N = sum(squeeze(sum(sum(~isnan(permute(CurrentImage,[3 2 1]))))) >0);
    end     




function axisd = resetaxis (figHnd, vdimx, vdimy, slice_row_N, slice_column_N, win)
axes(figHnd);
cla;
dimX =slice_row_N;
dimY= slice_column_N;
r=dimX-1;
c=0;

IP = get(figHnd,'Position');
ta = IP(3:4) ;

for i = 1:dimY*dimX
    pos = [c (r+0.5) 1 1].*[1/dimY 1/dimX 1/dimY 1/dimX] .* [ta(1) ta(2) ta(1) ta(2)]; 
    axisd(i) = axes(...
	'XTick',[],...
	'XTickLabel',[],...
	'YTick',[],...
	'YTickLabel',[],...
	'Box','on',...         
	'XLim',vdimx,...
	'YLim',vdimy,...
	'Units', 'normalized',...
    'Position',pos ,...     %****** YX 10042007 
    ... 'Position',[0.01+r*win(3)/dimX 1-c*win(4)/dimY-0.03 win(3)/(dimX+0.15) win(4)/(dimY+0.15)] ,...     %****** YX 10042007 
	'Tag','slice overlay panel');
    r=r-1;
    if r< 0
        c=c+1;
        r=dimX-1;
    end
end

