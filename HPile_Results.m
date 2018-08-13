%===============================================================================
%===============================================================================
% 1. Finalize and format plots used to keep track of convergence 
%-------------------------------------------------------------------------------
  figure(2);
%-------------------------------------------------------------------------------
% 1.1 Soil stiffness degradation
%-------------------------------------------------------------------------------
  subplot(1,3,1);
  L21b(1) = plot( ksi, -z, 'b');
  L21b(2) = plot(-kse, -z, 'r'); hold off;

  set(L21b,'LineWidth',2);
  xlabel('k (kN/m^3)');   
  ylabel('z (m)');
  title('Soil stiffness degradation');
  axis([-5*smax 5*smax -zmax 0.])
  grid on;

%-------------------------------------------------------------------------------
% 1.2 Soil stresses convergence
%-------------------------------------------------------------------------------
  subplot(1,3,2);
  L22b(1) = plot( Si, -z, 'b');
  L22b(2) = plot(-Se, -z, 'r'); hold off;

  set(L22b,'LineWidth',2);
  xlabel('\sigma (kN/m^2)');   
  ylabel('z (m)');
  title('Soil stresses convergence');
  axis([-smax smax -zmax 0.])
  grid on;

%-------------------------------------------------------------------------------
% 1.3 Elastic line convergence
%-------------------------------------------------------------------------------
  subplot(1,3,3);
  L23b = plot(UH, -z, 'b'); hold off;
  
  Umax = HForce*(hp^3)/12/EI;
  Umax = round(12.5*Umax)/10;
  
  set(L23b,'LineWidth',2);
  xlabel('U (m)');
  ylabel('z (m)');
  title('Elastic line convergence');
  axis([-Umax Umax -zmax zmax/10])
  grid on;

  print('-dpng','-r300', 'HPile_Convergence.png');

%===============================================================================
% 2. Bending moments (Mp) and shear forces (Qp) along pile length
%-------------------------------------------------------------------------------
% 2.1 Calculate internal Mp and Qp
%-------------------------------------------------------------------------------
  Mp  =  zeros(size(z));   Mp(1) = 0.;
  Qp  =  zeros(size(z));   Qp(1) = HForce;

  for ii = 2:nN
      RN     = HPile_Forces(Disp, dz, ii-1, ii, EI);    % nodal reactions
      Qp(ii) = -RN(3);
      Mp(ii) = -RN(4);
  end
  
%-------------------------------------------------------------------------------
% 2.2 Plots
%-------------------------------------------------------------------------------
  figure(3);

  subplot(1,3,1);  
  plot(UH, -z);
 [pk,ipk] = max(abs(UH));
  text(UH(ipk),-z(ipk),num2str(pk));
  xlabel('U (m)');
  ylabel('z (m)');
  title('Elastic Line');
  axis([-Umax Umax -zmax zmax/10])
  grid on;

  Mmax = HForce*hp/3;
  Mmax = 100*round(1.25*Mmax/100);
  
  subplot(1,3,2);
  plot(Mp, -z);
 [pk,ipk] = max(abs(Mp));
  text(Mp(ipk),-z(ipk),num2str(pk));
  xlabel('M (kNm)');
  ylabel('z (m)');
  title('Bending Moment');
  axis([-Mmax Mmax -zmax zmax/10])
  grid on;

  Qmax = 1.2*HForce;
  Qmax = 100*round(1.25*Qmax/100);
  
  subplot(1,3,3);
  plot(Qp, -z);
 [pk,ipk] = max(abs(Qp));
  text(Qp(ipk),-z(ipk),num2str(pk));
  xlabel('Q (kN)');
  ylabel('z (m)');
  title('Shear force');
  axis([-Qmax Qmax -zmax zmax/10])
  grid on;

  print('-dpng','-r300', 'HPile_FinalResults.png');
 
%===============================================================================
% 3. Finish script HPile_Script
%-------------------------------------------------------------------------------
  return

