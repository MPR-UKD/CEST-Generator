function [CEST_Parameter] = update_pixel_params(CEST_Parameter, A, B, C, D, E, x, y)

CEST_Parameter.R1A=A.R1(x,y) * CEST_Parameter.R1A;  % PBS
CEST_Parameter.R2A=A.R2(x,y) * CEST_Parameter.R2A;    % PBS
CEST_Parameter.fA = A.f(x,y) * CEST_Parameter.fA;
% first CEST pool B
CEST_Parameter.fB=B.f(x,y) * CEST_Parameter.fB;
CEST_Parameter.kBA=B.kA(x,y) * CEST_Parameter.kBA;
CEST_Parameter.dwB=B.dw(x,y) * CEST_Parameter.dwB;
CEST_Parameter.R1B= B.R1(x,y) * CEST_Parameter.R1B; 
CEST_Parameter.R2B=B.R2(x,y) * CEST_Parameter.R2B;

% second CEST pool D
CEST_Parameter.fD=C.f(x,y) * CEST_Parameter.fD;
CEST_Parameter.kDA=C.kA(x,y) * CEST_Parameter.kDA;
CEST_Parameter.dwD=C.dw(x,y) * CEST_Parameter.dwD;
CEST_Parameter.R1D= C.R1(x,y) * CEST_Parameter.R1D; 
CEST_Parameter.R2D=C.R2(x,y) * CEST_Parameter.R2D;

% second CEST pool E
CEST_Parameter.fE=D.f(x,y) * CEST_Parameter.fE;
CEST_Parameter.kEA=D.kA(x,y) * CEST_Parameter.kEA;
CEST_Parameter.dwE=D.dw(x,y) * CEST_Parameter.dwE;
CEST_Parameter.R1E= D.R1(x,y) * CEST_Parameter.R1E; 
CEST_Parameter.R2E=D.R2(x,y) * CEST_Parameter.R2E; 

% second CEST pool F
CEST_Parameter.fF=E.f(x,y) * CEST_Parameter.fF;
CEST_Parameter.kFA=E.kA(x,y) * CEST_Parameter.kFA;
CEST_Parameter.dwF=E.dw(x,y) * CEST_Parameter.dwF;
CEST_Parameter.R1F= E.R1(x,y) * CEST_Parameter.R1F; 
CEST_Parameter.R2F=E.R2(x,y) * CEST_Parameter.R2F; 

end