function calcularImagenesRejilla(app,paramsImage) 
% Author: Marcano.F

    axes(app.UIAxes);
    cla    
    %Inicializar el slider.
    app.slider_Frames.Min = 1;
    app.slider_Frames.Max = app.parametrosImagen.image_N;
    app.slider_Frames.SliderStep = [1/(app.parametrosImagen.image_N-1),100/(app.parametrosImagen.image_N-1)];
    app.text_nimages.String = num2str(app.parametrosImagen.image_N))


Hbstate = paramsImage.Hbstate;
Hbtime = paramsImage.Hbtime;
transform_Index = paramsImage.transform_Index;
swap_axes_flag = paramsImage.swap_axes_flag;
currentImagePos = paramsImage.currentImagePos;




Grid_DIM = G_dataInfo.Reconstruction.Grid_DIM;
NodeCoordinate = G_dataInfo.Reconstruction.NodeCoordinate;
[x0, y0, z0, xi, yi, zi,~, ~, ~, grid_parameters] = dotpro_getGridInfo;
[~, coordSizeY] = size(NodeCoordinate);
app.parametrosImagen.x0=x0;     app.parametrosImagen.y0=y0;     app.parametrosImagen.xi=xi;     app.parametrosImagen.yi=yi;
if coordSizeY>3
    app.parametrosImagen.z0=z0; app.parametrosImagen.zi=zi;
else
    app.parametrosImagen.z0=[]; app.parametrosImagen.zi=[];
end
ii = 1:numel(xi);
grid_parameters.ii = ii;
app.parametrosImagen.grid_parameters=grid_parameters;
app.parametrosImagen.DIM = Grid_DIM;



app.parametrosImagen.Hbstate=Hbstate;
try
    app.parametrosImagen.currentImage =  dotpro_ImageDisplay3(handles,Hbtime,Hbstate);
    app.parametrosImagen.DIM = size(app.parametrosImagen.currentImage );
    app.parametrosImagen.Reconstruction = true;
catch
    app.parametrosImagen.currentImage =  dotpro_ImageDisplay2(Hbtime,currentImagePos,Hbstate);
    app.parametrosImagen.Reconstruction = false;
end;


SpecifyROIFlag=0;
if app.parametrosImagen.DIM(3)==1
    sliceN = app.parametrosImagen.DIM(3);
else
    sliceN =max(app.parametrosImagen.DIM);
end

% %--------------------------------------------------------------------------------------------
% % % % % % % %Aquí se muestra la imagen
figHnd = handles.axes1;
dotpro_DisplayImagesOnAxes(handles,figHnd,transform_Index, Hbstate,sliceN,SpecifyROIFlag);
% %---------------------------------------------------------------------------------------------

function imageSTD =  dotpro_ImageDisplay2(Hbtime,currentImagePos,Hbstate)
global app.parametrosImagen;

    %%%% CALCULO DINAMICO DE IMAGEN
    dotpro_readImages(Hbtime,currentImagePos);
    app.parametrosImagen.Description=' Original';
    switch(Hbstate)
        case 1, imageSTD = app.parametrosImagen.hboxy(:);
        case 2, imageSTD = app.parametrosImagen.hbred(:);
        case 3, imageSTD = app.parametrosImagen.hboxy(:)+app.parametrosImagen.hbred(:);
        case 4, imageSTD = (2.0226e-5 +app.parametrosImagen.hboxy(:))./(2.9399e-5+app.parametrosImagen.hboxy(:)+app.parametrosImagen.hbred(:)); 
    end
    try
        imageSTD= dotpro_nirx_griddata3(app.parametrosImagen.x0,app.parametrosImagen.y0,app.parametrosImagen.z0,imageSTD,app.parametrosImagen.xi,app.parametrosImagen.yi,app.parametrosImagen.zi,'linear',app.parametrosImagen.grid_parameters);
    catch
        imageSTD= dotpro_nirx_griddata2(app.parametrosImagen.x0,app.parametrosImagen.y0,imageSTD,app.parametrosImagen.xi,app.parametrosImagen.yi,'linear',app.parametrosImagen.grid_parameters);
    end

function imageSTD =  dotpro_ImageDisplay3(handles,Hbtime,Hbstate)
global G_dataInfo;
    CurrRes = dotpro_ResFromWout;
    if ~isempty(CurrRes)&& get(handles.checkbox_customview,'Value')
        set(handles.popupmenu_Rescale,'Value',find(strcmp(CurrRes,get(handles.popupmenu_Rescale,'String'))));
    else
        throw NoReconstruction; 
    end;
      
    [~,fname] = fileparts(strrep(G_dataInfo.Reconstruction.reconstructed_img_file{1},'_hboxy.NAV',''));
    fname = [ G_dataInfo.writeFlags.prefix dotpro_FileNameExport(fname,Hbstate,Hbtime) '.hdr'];
    niifile = load_nii(fullfile([G_dataInfo.wout filesep fname]));
    imageSTD = double(niifile.img);
    imageSTD = permute(imageSTD,[2 1 3]); % Nuestra convención
    imageSTD = imageSTD(end:-1:1,end:-1:1,:);
    
        
    