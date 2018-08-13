%===============================================================================
%===============================================================================
% 1. Build auxiliar variables
%-------------------------------------------------------------------------------
  nL  =  size(Soil,1);         % number of soil layers
  nN  =  1 + round(hp/dz);     % number of nodes for pile discretization
  
  Ip  =  pi*(dp^4)/64;         % pile momento of inertia (m^4)
  EI  =  1.e6*Ep*Ip;           % pile flexural stiffness (kNm2)

%===============================================================================
% 2. Pile and soil discretization
%-------------------------------------------------------------------------------
% 2.1 Locate z coordinates 
%-------------------------------------------------------------------------------
  z   =  linspace(0,hp,nN)';   % z coordinate discretization
  izS  = zeros(nL,1);          % bottom position for each layer

  for ii = 1:nL
     [~,izS(ii)] = min(abs(z - Soil(ii,1)));
  end

%-------------------------------------------------------------------------------
% 2.2 Locate water table
%-------------------------------------------------------------------------------
 [~,izW] = min(abs(z - zW));

%-------------------------------------------------------------------------------
% 2.3 Locate begining of soil (bottom of first virtual empty layer)
%-------------------------------------------------------------------------------
  zS   = 0.;                            % if no free top
  zmax = Soil(end,1);                   % pile tip position
  
  if (Soil(1,2) == 0.)                  % zero weight means empty layer
      zS = Soil(1,1);
  end

%-------------------------------------------------------------------------------
% 2.4 Replicate soil properties for each pile node
%-------------------------------------------------------------------------------
  ID =  ones(izS(1),1);                 % initialize counter

  gs =  Soil(1,2)*ID;                   % specific weight
  fs =  Soil(1,3)*ID;                   % internal friction angle
  cs =  Soil(1,4)*ID;                   % coesion
  mK =  Soil(1,5)*ID;                   % multiplier of passive limit
  k0 =  Soil(1,6)*ID;                   % linear coefficients k0
  k1 =  Soil(1,7)*ID;                   % angular coefficients k1

  for ii = 2:nL
      ID = ones((izS(ii)-izS(ii-1)),1);
      
      gs = [gs; Soil(ii,2)*ID];          %#ok<*AGROW>
      fs = [fs; Soil(ii,3)*ID];
      cs = [cs; Soil(ii,4)*ID];
      mK = [mK; Soil(ii,5)*ID];
      k0 = [k0; Soil(ii,6)*ID];
      k1 = [k1; Soil(ii,7)*ID];
  end

%-------------------------------------------------------------------------------
% 2.5 Calculate further soil properties
%-------------------------------------------------------------------------------
  fr  =  pi*fs/180;                     % from degrees to radians
  kN  =  1.0 - sin(fr);                 % neutral earth pressure coefficient
  kP  =  mK.*(tan(pi/4 + fr/2)).^2;     % passive earth pressure coefficient
  kA  =  1.0*(tan(pi/4 - fr/2)).^2;     % active earth pressure coefficient
  
  ksi =  k0 + k1.*(z - zS);             % right side
  kse =  k0 + k1.*(z - zS);             % left side

%===============================================================================
% 3. Build earth pressure vectors
%-------------------------------------------------------------------------------
% 3.1 Hidrostatic pressure
%-------------------------------------------------------------------------------
  sW  = zeros(size(z));                 % initialize
  sW(izW:end) = gW*dz;                  % increment
  sW  = cumsum(sW);                     % integrate

%-------------------------------------------------------------------------------
% 3.2 Vertical effective stress
%-------------------------------------------------------------------------------
  sV  = gs*dz;                          % self weight
  sV (izW:end) = sV(izW:end) - gW*dz;   % hidrostatic pressure excluded
  sV  = cumsum(sV);                     % integrate

%-------------------------------------------------------------------------------
% 3.3 Neutral, active and passive limits
%-------------------------------------------------------------------------------
  sN = sV.*kN;                          % neutral limit stress
  sA = sV.*kA - 2*cs.*sqrt(kA);         % active limit stress
  sP = sV.*kP + 2*cs.*sqrt(kP);         % passive limit stress
  
  sA(sA < 0) = 0.;                      % active limit cannot be negative
  
%-------------------------------------------------------------------------------
% 3.4 Plot all limits for overall control of soil resistance
%-------------------------------------------------------------------------------
  figure(1);
  
  L1(1: 2) = plot( sV, -z, 'k', -sV, -z, 'k');   hold on;
  L1(3: 4) = plot( sN, -z, 'g', -sN, -z, 'g');
  L1(5: 6) = plot( sA, -z, 'r', -sA, -z, 'r');
  L1(7: 8) = plot( sP, -z, 'm', -sP, -z, 'm'); 
  L1(9:10) = plot( sW, -z, 'b', -sW, -z, 'b'); 

  L1(  11) = plot([0  0],[0 -hp],'k');

  set(L1(5:6),'LineWidth',2); 
  set(L1(7:8),'LineWidth',2);
  set(L1(11), 'LineWidth',4);
   
  smax = max(abs(sP));                  % define stress scale for all plots
  smax = 100*round(1.25*smax/100);
 
  plot([-smax smax],[-zS -zS],'k:');

  for ii = 1:nL
      LG = plot([-smax smax],[-Soil(ii,1) -Soil(ii,1)],'k:');
      set(LG,'LineWidth',2);
  end
 
  legend(L1(1:2:9),'Vertical',...
                   'Neutral',...
                   'Active',...
                   'Passive',...
                   'Hidrostatic');
 
  xlabel('\sigma (kN/m^2)');   
  ylabel('z (m)');
  title('Limit stresses as functions of depth');
  axis([-smax smax -zmax zmax/10]);
  grid on;
  hold off; 

  print('-dpng','-r300', 'HPile_SoilStresses.png');
  
%===============================================================================
% 4. Solution - iteractive method
%-------------------------------------------------------------------------------
% 4.1 Reset plastic condition and perform initial solution
%-------------------------------------------------------------------------------
  iPi = [];                             % flag for passive limit reached right
  iAi = [];                             % flag for active limit reached right
  iPe = [];                             % flag for passive limit reached left
  iAe = [];                             % flag for active limit reached left
  
  iLoad  =  1;                          % initialize iteration counter
  HPile_Solver;                         % initial solution
  
  while (iLoad <= Ni)                   % START ITERATION **********************
%-------------------------------------------------------------------------------
% 4.2 Select nodes where (active or passive) limit state was reached
%-------------------------------------------------------------------------------
  Si =   UH.*ksi + sN;                  % soil stresses right
  Si(Si < 0) = 0;                       % tensile stresses not allowed

  Se =  -UH.*kse + sN;                  % soil stresses left
  Se(Se < 0) = 0;                       % tensile stresses not allowed

  iPi = find(Si > sP);                  % check passive limit right
  iAi = find(Si < sA);                  % check active limit right
  iPe = find(Se > sP);                  % check passive limit left
  iAe = find(Se < sA);                  % check active limit left

%-------------------------------------------------------------------------------
% 4.3 Update stiffness wherever limit state has been reached
%-------------------------------------------------------------------------------
  ksi(iPi) = (sP(iPi) - sN(iPi))./abs(UH(iPi));
  ksi(iAi) = (sN(iAi) - sA(iAi))./abs(UH(iAi));
  kse(iPe) = (sP(iPe) - sN(iPe))./abs(UH(iPe));
  kse(iAe) = (sN(iAe) - sA(iAe))./abs(UH(iAe));

%-------------------------------------------------------------------------------
% 4.4 Keep track of solution convergence
%-------------------------------------------------------------------------------
  figure(2);     
  
  subplot(1,3,1);                               % soil stiffness reduction
  L21a(1) = plot( ksi, -z, 'b:');    hold on;
  L21a(2) = plot(-kse, -z, 'r:');
 
  subplot(1,3,2);                               % soil stress
  L22a(1) = plot( Si,  -z, 'b:');    hold on;
  L22a(2) = plot(-Se,  -z, 'r:');
  
  subplot(1,3,3);                               % pile deformation
  L23a    = plot( UH,  -z, 'b:');    hold on;

%-------------------------------------------------------------------------------
% 4.5 New solution with modified soil stiffness
%-------------------------------------------------------------------------------
  HPile_Solver;
  iLoad = iLoad + 1;                    % up date counter
  end                                   % END OF ITERATION *********************

%===============================================================================
% 5. finish script HPile_Script
%-------------------------------------------------------------------------------
  return

