function [w, parameters] = DYNOT4D_nirx_griddata(x,y,z,v,xi,yi,zi,method, parameters)
% Function: dotpro_nirx_griddata3
% Description: This function allow to make a image reconstruction over a 3D grid.
% Author: Hernandez-Martin.E & Marcano.F
% Date: Oct. 2015
% Remarks:  Following code has been taken and modified from NIRS_NAVI. Nirx
% Medical Technologies. Copyright 2006-2011.
%GRIDDATA3 Data gridding and hyper-surface fitting for 3-dimensional data.
%   W = GRIDDATA3(X, Y, Z, V, XI, YI, ZI) fits a hyper-surface of the
%   form W = F(X,Y,Z) to the data in the (usually) nonuniformly-spaced
%   vectors (X, Y, Z, V).  GRIDDATA3 interpolates this hyper-surface at
%   the points specified by (XI,YI,ZI) to produce W.
%
%   (XI,YI,ZI) is usually a uniform grid (as produced by MESHGRID) and is
%   where GRIDDATA3 gets its name. 
%
%   [...] = GRIDDATA3(...,'method') where 'method' is one of
%
%       'linear'    - Tessellation-based linear interpolation (default).
%       'nearest'   - Nearest neighbor interpolation.
%
%   defines the type of surface fit to the data. 
%   All the methods are based on a Delaunay triangulation of
%   the data via qhull. 
%
%   See also GRIDDATA, GRIDDATAN, QHULL, DELAUNAYN, MESHGRID

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.11 $  $Date: 2002/04/09 00:14:22 $
% global G_dataInfo;
% try
%     v(abs(v)<=G_dataInfo.SensitivityThreshold) = min(v(:));
% catch 
%     error('No se ha definido el umbral de sensibilidad.');
% end;

if nargin < 7
  error('Needs at least 7 arguments.');
end
if nargin < 8, 
    method = 'linear'; 
end
if ~isequal(method(1),'l') & ~isequal(method(1),'n')
  error('METHOD must be one of ''linear'', or ''nearest''.');
end

if nargin <9 
     x = x(:); y=y(:); z=z(:); v = v(:);
     m = length(x);
     if m < 3, 
         error('Not enough points'); 
     end
     if m ~= length(y) | m ~= length(z) | m ~= length(v)
         error('X,Y,Z,V must all have the same size.');
     end
     X = [x y z];
     % Sort (x,y,z) so duplicate points can be averaged before passing to delaunay
     [X, ind] = sortrows(X);
     v = v(ind);
     v_ind = ind;
     ind = all(diff(X)'==0);
     if any(ind)
          warning('MATLAB:griddata3:Duplicate DataPoints',['Duplicate x data points detected: using average of the y values.']);
          ind = [0 ind];
          ind1 = diff(ind);
          fs = find(ind1==1);
          fe = find(ind1==-1);
           if fs(end) == length(ind1) % add an extra term if the last one start at end
               fe = [fe fs(end)+1];
           end
           for i = 1 : length(fs)
              % averaging v values
               v(fe(i)) = mean(v(fs(i):fe(i)));
           end
           X = X(~ind(2:end),:);
           v = v(~ind(2:end));
           param.DuplicateFlag =1;
           param.fe=fe;
           param.fs=fs;
       else
           param.DuplicateFlag=0;
           param.fe=[];
           param.fs=[];
       end
       param.X = X;
       param.ind = v_ind;

   switch lower(method(1))
     case 'l'
      [w,parameters] = linear(X,v,[xi(:) yi(:) zi(:)]);
    case 'n'
      [w,parameters] = nearest(X,v,[xi(:) yi(:) zi(:)]);
    otherwise
       error('Unknown method.');
    end
    parameters.X = param.X;
    parameters.ind = param.ind;
    parameters.DuplicateFlag = param.DuplicateFlag;
    parameters.fe = param.fe;
    parameters.fs = param.fs;
else
    ind = parameters.ind;
    fe = parameters.fe;
    fs = parameters.fs;
    v = v(ind);
    for i = 1 :length(fs)
        % averaging v values
         v(fe(i)) = mean(v(fs(i):fe(i)));
    end 
    switch lower(method(1)),
      case 'l'
        %%% dotpro_new_linear, dotpro_new_nearest funciona mal (mala
        %%% posicion de valores en fem).
        %%% Para corregir el problema de los valores t y p de grid_parameters
        %%% mal generados desde el brainmodel, el valor corregido de t y p en
        %%% el grid_parameters devuelto se salvara en el fichero GRID_LIBNNN correspondiente 
        %%% a la resolucion actual (ver dotpro2_calculoVolumenNIRS).
        if (isfield(parameters,'TP_Calculado_tsearchn'))
            [w] = dotpro_new_linear(parameters,v,[xi(:) yi(:) zi(:)]);
        else
            [w,parameters] = linear(parameters.X,v,[xi(:) yi(:) zi(:)]);
        end
      case 'n'
        if (isfield(parameters,'TP_Calculado_tsearchn'))
            [w] = dotpro_new_nearest(parameters,v,[xi(:) yi(:) zi(:)]);
        else
            [w,parameters] = nearest(parameters.X,v,[xi(:) yi(:) zi(:)]);
        end
      otherwise
        error('Unknown method.');
    end
end
    
w = reshape(w,size(xi));

%------------------------------------------------------------
function [zi, parameters] = linear(x,y,xi)
%LINEAR Triangle-based linear interpolation

%   Reference: David F. Watson, "Contouring: A guide
%   to the analysis and display of spacial data", Pergamon, 1994.

% Triangularize the data
tri = delaunayn(x);
if isempty(tri),
  warning('MATLAB:griddata3:CannotTriangulate','Data cannot be triangulated.');
  zi = NaN*zeros(size(xi));
  return
end
parameters.tri = tri;

% Find the nearest triangle (t)
[t,p] = tsearchn(x,tri,xi);
parameters.t = t;
parameters.p = p;

m1 = size(xi,1);
onev = ones(1,size(x,2)+1);
zi = NaN*zeros(m1,1);

for i = 1:m1
  if ~isnan(t(i))
     zi(i) = p(i,:)*y(tri(t(i),:));
  end
end
%----------------------------------------------------------

%------------------------------------------------------------
function [zi, parameters] = nearest(x,y,xi)
%NEAREST Triangle-based nearest neightbor interpolation

%   Reference: David F. Watson, "Contouring: A guide
%   to the analysis and display of spacial data", Pergamon, 1994.

% Triangularize the data
tri = delaunayn(x);
parameters.tri = tri;

if isempty(tri), 
  warning('MATLAB:griddata3:CannotTriangulate','Data cannot be triangulated.');
  zi = repmat(NaN,size(xi));
  return
end

% Find the nearest vertex
k = dsearchn(x,tri,xi);
parameters.k = k;

zi = k;
d = find(isfinite(k));
zi(d) = y(k(d));

%----------------------------------------------------------

%%% the following functions are made by Dr. ZS Wang
%%% using parameters generated in the previous time to save time
%------------------------------------------------------------


%----------------------------------------------------------

%------------------------------------------------------------
function zi = dotpro_new_nearest(parameters,y,xi)
%NEAREST Triangle-based nearest neightbor interpolation

%   Reference: David F. Watson, "Contouring: A guide
%   to the analysis and display of spacial data", Pergamon, 1994.

% Triangularize the data
tri = parameters.tri;
if isempty(tri), 
  warning('MATLAB:griddata3:CannotTriangulate','Data cannot be triangulated.');
  zi = repmat(NaN,size(xi));
  return
end

% Find the nearest vertex
%k = dsearchn(x,tri,xi);
%k = dsearchn(parameters.X,tri,xi);

k=parameters.k;

zi = k;
d = find(isfinite(k));
zi(d) = y(k(d));
