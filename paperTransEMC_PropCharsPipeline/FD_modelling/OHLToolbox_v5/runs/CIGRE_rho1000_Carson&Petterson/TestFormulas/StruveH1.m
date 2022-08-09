function fun=StruveH1(z)
%
% StruveH1 calculates the function StruveH1 for complex argument z
%
% Author : T.P. Theodoulidis
% Date   : 11 June 2012
% Revised: 28 June 2012
%
% Arguments
% z : can be scalar, vector, matrix
% 
% External routines called         : cheval, StruveH1Y1
% Matlab intrinsic routines called : bessely, besselh
%
bn=[1.174772580755468e-001 -2.063239340271849e-001  1.751320915325495e-001...
   -1.476097803805857e-001  1.182404335502399e-001 -9.137328954211181e-002...
    6.802445516286525e-002 -4.319280526221906e-002  2.138865768076921e-002...
   -8.127801352215093e-003  2.408890594971285e-003 -5.700262395462067e-004...
    1.101362259325982e-004 -1.771568288128481e-005  2.411640097064378e-006...
   -2.817186005983407e-007  2.857457024734533e-008 -2.542050586813256e-009...
    2.000851282790685e-010 -1.404022573627935e-011  8.842338744683481e-013...
   -5.027697609094073e-014  2.594649322424009e-015 -1.221125551378858e-016...
    5.263554297072107e-018 -2.086067833557006e-019  7.628743889512747e-021...
   -2.582665191720707e-022  8.118488058768003e-024 -2.376158518887718e-025...
    6.492040011606459e-027 -1.659684657836811e-028  3.978970933012760e-030...
   -8.964275720784261e-032  1.901515474817625e-033];
%
x=z(:);
%
% |x|<=16
i1=abs(x)<=16;
x1=x(i1);
if isempty(x1)==0
    z1=x1.^2/400;
    fun1=cheval('shifted',bn,z1).*x1.^2*2/3/pi;
else
    fun1=[];
end
%
% |x|>16
i2=abs(x)>16;
x2=x(i2);
if isempty(x2)==0
    fun2=StruveH1Y1(x2)+bessely(1,x2);
else
    fun2=[];
end
%
fun=x*0;
fun(i1)=fun1;
fun(i2)=fun2;
%
fun=reshape(fun,size(z));
%