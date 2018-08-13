  function K = HPile_Stiff(K, L, n1, n2, EI)
%===============================================================================
%===============================================================================
% Hpile_Stiff  Add a 2D beam segment to stiffness matrix.
%            K = HPile_Stiff(K,L,n1,n2,I,E,P) sum up a 2D beam stiffness
%            matrix to a global stiffness matrix. The required input is:
%
%            K:  the global stiffness matrix.
%            L:  the beam length.
%            n1: number of starting structural node.
%            n2: number of ending structural node.
%            EI: flexural stiffness of cross section.
%===============================================================================

  i1  = 2*n1 - 1;
  i2  = 2*n1;
  i3  = 2*n2 - 1;
  i4  = 2*n2;

  k11 = 12*EI/L/L/L;
  k12 =  6*EI/L/L;
  k22 =  4*EI/L;

  K(i1,i1) = K(i1,i1) + k11;
  K(i1,i2) = K(i1,i2) + k12;    K(i2,i1) = K(i2,i1) + k12;
  K(i1,i3) = K(i1,i3) - k11;    K(i3,i1) = K(i3,i1) - k11; 
  K(i1,i4) = K(i1,i4) + k12;    K(i4,i1) = K(i4,i1) + k12; 
  K(i2,i2) = K(i2,i2) + k22;
  K(i2,i3) = K(i2,i3) - k12;    K(i3,i2) = K(i3,i2) - k12;
  K(i2,i4) = K(i2,i4) + k22/2;  K(i4,i2) = K(i4,i2) + k22/2;
  K(i3,i3) = K(i3,i3) + k11;    
  K(i3,i4) = K(i3,i4) - k12;    K(i4,i3) = K(i4,i3) - k12;
  K(i4,i4) = K(i4,i4) + k22;
  
%===============================================================================
%===============================================================================
  return
