  function F = HPile_Forces(X, L, n1, n2, EI)
%===============================================================================
%===============================================================================
% HPile_Forces  Calculate nodal forces for 2D beam element.
%          F = HPile_Forces(K,L,n1,n2,I,E,P) build up a 2D beam
%          stiffness matrix and calculate nodal forces for solution X. 
%          The required input is:
%
%          X:  solution (displacement vector).
%          L:  the beam length.
%          n1: number of starting structural node.
%          n2: number of ending structural node.
%          EI: flexural stiffness of beam cross section.
%===============================================================================

  Xi  = zeros(4,1);

  i1  = 2*n1 - 1;       Xi(1) = X(i1);
  i2  = 2*n1;           Xi(2) = X(i2);
  i3  = 2*n2 - 1;       Xi(3) = X(i3);
  i4  = 2*n2;           Xi(4) = X(i4);

  k11 = 12*EI/L/L/L;
  k12 =  6*EI/L/L;
  k22 =  4*EI/L;

  K(1,1) =  k11;
  K(1,2) =  k12;    K(2,1) =  k12;
  K(1,3) = -k11;    K(3,1) = -k11; 
  K(1,4) =  k12;    K(4,1) =  k12; 
  K(2,2) =  k22;
  K(2,3) = -k12;    K(3,2) = -k12;
  K(2,4) =  k22/2;  K(4,2) =  k22/2;
  K(3,3) =  k11;    
  K(3,4) = -k12;    K(4,3) = -k12;
  K(4,4) =  k22;

  F = K*Xi;
  
%===============================================================================
%===============================================================================
  return
