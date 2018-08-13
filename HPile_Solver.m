%===============================================================================
%===============================================================================
% 1. Assembling global stiffness matrix for pile, KK
%-------------------------------------------------------------------------------
% 1.1 Include all pile segments
%-------------------------------------------------------------------------------
  KK = zeros(2*nN,2*nN);           % initialize empty stiffness matrix

  for ii = 2:nN
      KK = HPile_Stiff(KK, dz, ii-1, ii, EI);    % fills global matrix
  end

  nD  = 2*nN;                      % total number of d.o.f.
  tD  = 1:2:(nD-1);                % translational  d.o.f.
  rD  = 2:2:(nD);                  % rotational d.o.f.

%-------------------------------------------------------------------------------
% 1.2 Includes current soil stiffness (only in translational d.o.f.)
%-------------------------------------------------------------------------------
  KSi = dp*dz.*ksi;                % right side stiffness (x > 0)
  KSe = dp*dz.*kse;                % left side stiffness ( x < 0)

  for ii = 1:nN
      KK(tD(ii),tD(ii)) = KK(tD(ii),tD(ii)) + KSi(ii);
      KK(tD(ii),tD(ii)) = KK(tD(ii),tD(ii)) + KSe(ii);
  end

%===============================================================================
% 2. Assembling load vector (only translational d.o.f.)
%-------------------------------------------------------------------------------
  Load    = zeros(nD,1);           % initialize load vector
  Load(1) = HForce*sqrt(iLoad/Ni); % horizontal force on top (increasing)

%===============================================================================
% 3. Solve system and retrieve lateral displacements (translational d.o.f.)
%-------------------------------------------------------------------------------
  Disp    = KK\Load;               % solve for displacements
  UH      = Disp(tD);              % retrieve horizontal displacements  
  FH      = Load(tD);              % retrieve lateral loads

%===============================================================================
% 4. Encerra script HPile_Solver
%-------------------------------------------------------------------------------
  return

