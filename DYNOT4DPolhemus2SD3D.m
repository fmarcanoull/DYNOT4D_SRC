 
function ficheroSD3D = DYNOT4DPolhemus2SD3D(DIGIGUICsv,longitudesOnda)
% DIGIGUICsv, fichero .csv de salida del Polhemus-GUI (DIGIGUI)
% longitudesOnda, vector con longitudes de onda del DYNOT. Ejemplo: [760, 830] 

if ~exist('DIGIGUICsv','var')
    [file,path] = uigetfile('*.csv','Fichero .csv de Polhemus-GUI (DIGIGUI)','MultiSelect','off');
    DIGIGUICsv = fullfile(path,file);
end

[path,name,ext] = fileparts(DIGIGUICsv);
p = what(path); path = p.path;
%%% En esta version de Matlab 2023, la concatenación de strings se comporta
%%% extraño, debo chacer el casting de name y ext aquí.
DIGIGUICsv = fullfile(path,[char(name) char(ext)]);
ficheroSD3D = fullfile(path,[char(name) char('.SD3D')]);
fd = fopen(DIGIGUICsv,'r');
dataArray = textscan(fd, '%s%f%f%f', 'delimiter', ',','headerLines',1,'endOfLine', '\r\n');
fclose(fd);
coordenadas = cell2mat(dataArray(2:4)) *10; % De cm a mm
fiduciales = coordenadas(1:5,:);
posicionesOptodos = coordenadas(6:end,:);

%%% Cambio de orientación de coordenadas:
%%%% Inion --> 0 0 0, Nasion(x) == Nasion(z) == 0, Ar(z) == Al(z), Cz arriba

mediaYZFiduciales = mean(fiduciales([3 4],:));
fiduciales = fiduciales - repmat(mediaYZFiduciales,size(fiduciales,1),1);
posicionesOptodos = posicionesOptodos - repmat(mediaYZFiduciales,size(posicionesOptodos,1),1);

Cz = fiduciales(5,:);
[azimut,elevacion,~] = cart2sph(Cz(1),Cz(2),Cz(3));
anguloAzimut = -rad2deg(azimut);
fiduciales = fiduciales * MATLAB_rotz(anguloAzimut) ;
posicionesOptodos = posicionesOptodos * MATLAB_rotz(anguloAzimut) ;
fiduciales = fiduciales * MATLAB_roty(-(90-rad2deg(elevacion)));
posicionesOptodos = posicionesOptodos * MATLAB_roty(-(90-rad2deg(elevacion)));

% Inion --> 0 0 0
Inion = fiduciales(2,:);
fiduciales = fiduciales - repmat(Inion,size(fiduciales,1),1);
posicionesOptodos = posicionesOptodos - repmat(Inion,size(posicionesOptodos,1),1);

%Nasion(x) == Nasion(z) == 0 (Alineación con eje Y)
Nasion = fiduciales(1,:);
Inion = fiduciales(2,:);
% Cz = fiduciales(5,:);
[azimut,elevacion,~] = cart2sph(Nasion(1)-Inion(1),Nasion(2)-Inion(2),Nasion(3)-Inion(3));
anguloAzimut = (90-rad2deg(azimut));
fiduciales = fiduciales * MATLAB_rotz(anguloAzimut) ;
fiduciales = fiduciales * MATLAB_rotx(-rad2deg(elevacion));
posicionesOptodos = posicionesOptodos * MATLAB_rotz(anguloAzimut);
posicionesOptodos =  posicionesOptodos * MATLAB_rotx(-rad2deg(elevacion));

% Ar(z) == Al(z)
Ar = fiduciales(3,:);
Al = fiduciales(4,:);
[~,elevacion,~] = cart2sph(Ar(1)-Al(1),Ar(2)-Al(2),Ar(3)-Al(3));
fiduciales =  fiduciales * MATLAB_roty(rad2deg(elevacion));
posicionesOptodos =  posicionesOptodos * MATLAB_roty(rad2deg(elevacion));

%%% Colocalizados
posicionesDeFuentes = posicionesOptodos(1:end,:);
posicionesDeDetectores = posicionesDeFuentes;

DYNOT4DPolhemus2SD3D_dibujarMontaje(fiduciales,posicionesDeFuentes,posicionesDeDetectores);

SD3D = {};
SD3D.SrcPos = posicionesDeFuentes;
SD3D.DetPos = posicionesDeDetectores;
SD3D.nSrcs = size(posicionesDeFuentes,1);
SD3D.nDets = size(posicionesDeDetectores,1);
SD3D.Lambda = longitudesOnda;
SD3D.SpatialUnit = 'mm';
SD3D.Landmarks = fiduciales;

SD3D.MeasList = [];
%%% Generalizado para varias longitudes de onda
for ix = 1:length(longitudesOnda)
    SD3D.MeasList = [ SD3D.MeasList; combinations(1:SD3D.nSrcs,1:SD3D.nDets,1,ix)];
end

SD3D.MeasList = table2array(SD3D.MeasList);
SD3D.MeasListAct = ones(size(SD3D.MeasList,1),1);

save(ficheroSD3D,'SD3D');

end

function DYNOT4DPolhemus2SD3D_dibujarMontaje(fiduciales,posicionesDeFuentes,posicionesDeDetectores)
    figure('Name','Datos de posición de optodos');
    Atlasviewer_plotmesh(fiduciales,'g.','MarkerSize', 30);hold on;
    
    etiquetasFiduciales = {'Nasion','Inion','Ar','Al','Cz'};
    for ix = 1:size(fiduciales)
        text(fiduciales(ix,1),fiduciales(ix,2)+3,fiduciales(ix,3)+3,etiquetasFiduciales{ix});
    end
    
    for ix = 1:size(posicionesDeFuentes,1)
        plot3(posicionesDeFuentes(ix,1),posicionesDeFuentes(ix,2),posicionesDeFuentes(ix,3),'r.','MarkerSize',10);hold on;
        text(posicionesDeFuentes(ix,1),posicionesDeFuentes(ix,2)+3,posicionesDeFuentes(ix,3)*(1-0.05),['S' num2str(ix)],'Color','r');
    end
    
    for ix = 1:size(posicionesDeDetectores,1)
        plot3(posicionesDeDetectores(ix,1),posicionesDeDetectores(ix,2),posicionesDeDetectores(ix,3),'bo','MarkerSize',15);hold on;
        text(posicionesDeDetectores(ix,1),posicionesDeDetectores(ix,2)+3,posicionesDeDetectores(ix,3)*(1+0.05),['D' num2str(ix)],'Color','b');
    end
    
    axis equal
    xlabel('X (mm)');ylabel('Y (mm)');zlabel('Z (mm)');
    title({'Posiciones de fuentes(S) y detectores (D)', 'Convención neurológica RAS (+X-->R, +Y-->A, +Z-->S)'});
end

function hm= Atlasviewer_plotmesh(node,varargin)
%
% hm=plotmesh(node,face,elem,opt)
%
% plot surface and volumetric meshes
% 
% author: Qianqian Fang <fangq at nmr.mgh.harvard.edu>
%
% input: 
%      node: a node coordinate list, 3 columns for x/y/z; if node has a 
%            4th column, it will be used to set the color at each node.
%      face: a triangular surface face list; if face has a 4th column,
%            it will be used to separate the surface into 
%            sub-surfaces and display them in different colors;
%            face can be a cell array, each element of the array represents
%            a polyhedral facet of the mesh, if an element is an array with
%            two array subelements, the first one is the node index, the
%            second one is a scalar as the group id of the facet.
%      elem: a tetrahedral element list; if elem has a 5th column,
%            it will be used to separate the mesh into 
%            sub-domains and display them in different colors.
%      opt:  additional options for the plotting
%
%            for simple point plotting, opt can be markers
%            or color options, such as 'r.', or opt can be 
%            a logic statement to select a subset of the mesh,
%            such as 'x>0 & y+z<1', or an equation defining
%            a plane at which a mesh cross-section is plotted, for
%            example 'y=2*x'; opt can have more than one
%            items to combine these options, for example: 
%            plotmesh(...,'x>0','r.'); the range selector must
%            appear before the color/marker specifier
%
% in the event where all of the above inputs have extra settings related to 
% the color of the plot, the priorities are given in the following order:
%
%          opt > node(:,4) > elem(:,5) > face(:,4)
%
% output:
%   hm: handle or handles (vector) to the plotted surfaces
%
% example:
%
%   h=plotmesh(node,'r.');
%   h=plotmesh(node,'x<20','r.');
%   h=plotmesh(node,face);
%   h=plotmesh(node,face,'y>10');
%   h=plotmesh(node,face,'facecolor','r');
%   h=plotmesh(node,elem,'x<20');
%   h=plotmesh(node,elem,'x<20 & y>0');
%   h=plotmesh(node,face,elem);
%   h=plotmesh(node,face,elem,'linestyle','--');
%   h=plotmesh(node,elem,'z=20');
% 
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

    selector=[];
    opt=[];
    face=[];
    elem=[];
    
    if(nargin>1)
       hasopt=0;
       for i=1:length(varargin)
   	    if(ischar(varargin{i}))
		    if(~isempty(regexp(varargin{i},'[x-zX-Z]')) && ~isempty(regexp(varargin{i},'[><=&|]')))
			    selector=varargin{i};
			    if(nargin>=i+1) opt=varargin(i+1:end); end
		    else
			    opt=varargin(i:end);
		    end
		    if(i==1)
			    face=[];elem=[];
		    elseif(i==2)
			    if(iscell(varargin{1}) | size(varargin{1},2)<4)
				    face=varargin{1}; elem=[];
			    elseif(size(varargin{1},2)==4)
                    faceid=unique(varargin{1}(:,4));
                    if(length(faceid)==1)
                        face=varargin{1}; elem=[];
                    elseif(any(hist(varargin{1}(:,4),unique(varargin{1}(:,4)))>50))
                        face=varargin{1}; elem=[];
                    else
                        elem=varargin{1}; face=[];
                    end
			    else
				    elem=varargin{1}; face=[];
			    end
		    elseif(i==3)
			    face=varargin{1};
			    elem=varargin{2};
		    end
		    hasopt=1;
		    break;
	    end
       end
       if(hasopt==0)
   	    if(length(varargin)>=2)
		    face=varargin{1};
		    elem=varargin{2};
		    if(length(varargin)>2) opt=varargin(3:end); end
	    elseif(iscell(varargin{1}) | size(varargin{1},2)<4)
		    face=varargin{1}; elem=[];
	    elseif(size(varargin{1},2)==4)
	        faceid=unique(varargin{1}(:,4));
                if(length(faceid)==1)
	            face=varargin{1}; elem=[];
	        elseif(any(hist(varargin{1}(:,4),unique(varargin{1}(:,4)))>50))
                    face=varargin{1}; elem=[];
	        else
                    elem=varargin{1}; face=[];
	        end
	    else
		    elem=varargin{1}; face=[];
	    end
       end
    end
    
    holdstate=ishold;
    if(~holdstate)
        cla;
    end
    if(size(node,2)==4 && size(elem,2)==5)
        warning(['You have specified the node colors by both the 4th ' ...
                'and 5th columns of node and face inputs, respectively. ' ...
                'The node input takes priority']);
    end
    if(isempty(face) && isempty(elem))
       if(isempty(selector))
            if(isempty(opt))
   		    h=plot3(node(:,1),node(:,2),node(:,3),'o');
	    else
   		    h=plot3(node(:,1),node(:,2),node(:,3),opt{:});
	    end
       else
	    x=node(:,1);
	    y=node(:,2);
	    z=node(:,3);
	    idx=eval(['find(' selector ')']);
        if(~isempty(idx))
	        if(isempty(opt))
		    h=plot3(node(idx,1),node(idx,2),node(idx,3),'o');
	        else
		    h=plot3(node(idx,1),node(idx,2),node(idx,3),opt{:});
            end
        else
            warning('nothing to plot');
	    end
       end
    end
    
    if(~isempty(face))
       hold on;
       if(isempty(selector))
            if(isempty(opt))
   		    h=plotsurf(node,face);
	    else
   		    h=plotsurf(node,face,opt{:});
	    end
       else
        if(iscell(face))
           cent=meshcentroid(node,face);
        else
           cent=meshcentroid(node,face(:,1:3));
        end
	    x=cent(:,1);
        y=cent(:,2);
	    z=cent(:,3);
        idx=eval(['find(' selector ')']);
        if(~isempty(idx))
            if(iscell(face))
                h=plotsurf(node,face(idx),opt{:});
            else
    		    h=plotsurf(node,face(idx,:),opt{:});
            end
        else
            warning('no surface to plot');
	    end
       end
    end
    
    if(~isempty(elem))
       hold on;
       if(isempty(selector))
            if(isempty(opt))
   		    h=plottetra(node,elem);
	    else
   		    h=plottetra(node,elem,opt{:});
	    end
       else
       cent=meshcentroid(node,elem(:,1:4));
       x=cent(:,1);
       y=cent(:,2);
       z=cent(:,3);
       if(regexp(selector,'='))
          if(size(node,2)==4)
              [cutpos,cutvalue,facedata]=qmeshcut(elem,node(:,1:3),node(:,4),selector);  
          elseif(size(node,2)==3)
              [cutpos,cutvalue,facedata]=qmeshcut(elem,node,node(:,3),selector);
          else
              error('plotmesh can only plot 3D tetrahedral meshes');
          end
          h=patch('Vertices',cutpos,'Faces',facedata,'FaceVertexCData',cutvalue,'facecolor','interp',opt{:});
       else
          idx=eval(['find(' selector ')']);
          if(~isempty(idx))
	        if(isempty(opt))
		    h=plottetra(node,elem(idx,:));
	        else
		    h=plottetra(node,elem(idx,:),opt{:});
            end
          else
            warning('no tetrahedral element to plot');
	    end
         end
       end
    end
    
    if(exist('h','var') & ~holdstate)
      hold off;
    end
    if(exist('h','var'))
      if(any(get(gca,'dataaspectratio')>1e8))
         view(3);
      end
      axis equal;
    end
    if(exist('h','var') & nargout>=1)
      hm=h;
    end

end

function rotmat = MATLAB_rotz(gamma)
%rotz     Rotation matrix around z-axis
%   ROTMAT = rotz(GAMMA) returns the rotation matrix, ROTMAT, that rotates
%   a point around the z-axis for an angle GAMMA (in degrees). The point is
%   specified in the form of [x;y;z], with the x, y, and z axes forming a
%   right-handed Cartesian coordinate system. With the z axis pointing
%   towards the observer, GAMMA is measured counter-clockwise in the x-y
%   plane.
%
%   ROTMAT is a 3x3 matrix. The rotation of the point can be achieved by
%   left-multiplying ROTMAT with the point's coordinate vector [x;y;z].
%
%   % Example:
%   %   Rotate a point, (0,1,0), around z-axis 45 degrees
%   %   counter-clockwise.
%
%   p = [0;1;0];
%   p = rotz(45)*p
%
%   See also phased, rotx, roty.

%   Copyright 2012-2021 The MathWorks, Inc.

%   References:
%   [1] James Foley, et. al. Computer Graphics Principles and Practices in
%       C, 2nd Edition, Addison-Wesley, 1995

%#codegen
%#ok<*EMCA>

eml_assert_no_varsize(1,gamma);
sigdatatypes.validateAngle(gamma,'rotz','GAMMA',{'scalar'});
% rotate in the direction of x->y, counter-clockwise
rotmat = [cosd(gamma) -sind(gamma) 0; sind(gamma) cosd(gamma) 0; 0 0 1];

end

function rotmat = MATLAB_rotx(alpha)
%rotx     Rotation matrix around x-axis
%   ROTMAT = rotx(ALPHA) returns the rotation matrix, ROTMAT, that rotates
%   a point around the x-axis for an angle ALPHA (in degrees). The point is
%   specified in the form of [x;y;z], with the x, y, and z axes forming a
%   right-handed Cartesian coordinate system. With the x axis pointing
%   towards the observer, ALPHA is measured counter-clockwise in the y-z
%   plane.
%
%   ROTMAT is a 3x3 matrix. The rotation of the point can be achieved by
%   left-multiplying ROTMAT with the point's coordinate vector [x;y;z].
%
%   % Example:
%   %   Rotate a point, (0,1,0), around x-axis 45 degrees
%   %   counter-clockwise.
%
%   p = [0;1;0];
%   p = rotx(45)*p
%
%   See also phased, roty, rotz.

%   Copyright 2012-2021 The MathWorks, Inc.

%   References:
%   [1] James Foley, et. al. Computer Graphics Principles and Practices in
%       C, 2nd Edition, Addison-Wesley, 1995

%#codegen
%#ok<*EMCA>

eml_assert_no_varsize(1,alpha);
sigdatatypes.validateAngle(alpha,'rotx','ALPHA',{'scalar'});
% rotate in the direction of y->z, counter-clockwise
rotmat = [1 0 0;0 cosd(alpha) -sind(alpha); 0 sind(alpha) cosd(alpha)];
end

function rotmat = MATLAB_roty(beta)
%roty     Rotation matrix around y-axis
%   ROTMAT = roty(BETA) returns the rotation matrix, ROTMAT, that rotates
%   a point around the y-axis for an angle BETA (in degrees). The point is
%   specified in the form of [x;y;z], with the x, y, and z axes forming a
%   right-handed Cartesian coordinate system. With the y axis pointing
%   towards the observer, BETA is measured counter-clockwise in the z-x
%   plane.
%
%   ROTMAT is a 3x3 matrix. The rotation of the point can be achieved by
%   left-multiplying ROTMAT with the point's coordinate vector [x;y;z].
%
%   % Example:
%   %   Rotate a point, (0,1,0), around y-axis 45 degrees
%   %   counter-clockwise.
%
%   p = [1;0;0];
%   p = roty(45)*p
%
%   See also phased, rotx, rotz.

%   Copyright 2012-2021 The MathWorks, Inc.

%   References:
%   [1] James Foley, et. al. Computer Graphics Principles and Practices in
%       C, 2nd Edition, Addison-Wesley, 1995


%#codegen
%#ok<*EMCA>

eml_assert_no_varsize(1,beta);
sigdatatypes.validateAngle(beta,'roty','BETA',{'scalar'});
% rotate in the direction of z->x, counter-clockwise
rotmat = [cosd(beta) 0 sind(beta); 0 1 0; -sind(beta) 0 cosd(beta)];

end