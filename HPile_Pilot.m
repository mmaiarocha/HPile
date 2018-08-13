%===============================================================================
%===============================================================================
%  *********     Analysis of a laterally loaded pile       *********
%                   (Note: all units in kN and m)
%===============================================================================
%===============================================================================
  clear; clc;
%===============================================================================
% 1. Pile data
%-------------------------------------------------------------------------------
  hp  =  12;              % Total pile height (m)
  dp  =  0.3;             % lateral pile dimension - diameter (m)
  dz  =  0.1;             % discretization length (m)

  Ep  =  30.;             % Young's modulus for pile material (GPa)
  gp  =  25.;             % Specific weight for pile material (kN/m3)

  gW  =  9.81;            % Specific weight for water (kN/m3)
  zW  =  4.;              % Water table depth from pile top (m)

  Ni  =  50;              % Number of iterations to seek convergence

%===============================================================================
% 2. Geotechnical profile (one row per layer)
%
%    Note 1:  origin of z axis is the pile top, pointing downwards to pile tip.
%             Soil stars at coordinate zS. The free pile top is represented
%             as a virtual empty soil layer, with bottom at zS, which is the
%             first row of matrix "Soil".
%
%    Note 3:  soil horizontal stiffness is modelled as a linear function of
%             depth z, as K = dp*dz*[k0 + k1*(z - zS)]. The spring coefficient
%             "K" has unit [kN/m^3], for it must be multiplied by pile width
%             to give a stiffness per unit length.
%
%-------------------------------------------------------------------------------
%
%    Column 1:  layer bottom position (m).
%    Column 2:  soil specific weight (kN/m3).
%    Column 3:  internal friction angle (degrees).
%    Column 4:  coesion (kN/m2).
%    Column 5:  multiplier for passive limit coefficient kP (*)
%    Column 6:  soil stiffness linear coefficient k0 (kN/m^3).
%    Column 7:  soil stiffness angular coefficient k1 (kN/m^4).
%
%   (*) to account for 3d effects on soil resistance.
%
%-------------------------------------------------------------------------------
%          bottom  gam    phi     c     mk     k0     k1  
%-------------------------------------------------------------------------------
  Soil  = [ 1.00    0.     0.     0.     0.     0.     0.  ;  ... % free top
            6.00   16.    30.     0.     1.   500.     0.  ;  ... % clayey sand
           14.00   18.     0.    20.     1.   300.     0. ];      % sandy clay

%===============================================================================
% 3. Pile load (at pile top: z = 0)
%-------------------------------------------------------------------------------
  HForce = 40.;         % horizontal force at pile top (kN)

%===============================================================================
% 4. Call analysis
%-------------------------------------------------------------------------------
  HPile_Script;

%===============================================================================
% 5. Plot and save results
%-------------------------------------------------------------------------------
  HPile_Results;

%===============================================================================
% 6. Finish script HPile_Pilot
%-------------------------------------------------------------------------------
  return
