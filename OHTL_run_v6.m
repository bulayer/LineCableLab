% OHTL run

close all; % Deletes all figures whose handles are not hidden
clear all; % Remove items from workspace, freeing up system memory
clear;
clc; % Clears all input and output from the Command Window display, giving you a "clean screen"
format longEng; % Engineering format that has exactly 16 significant digits and a power that is a multiple of three.

% soil parameters - to facilitate parametric studies
soil_rho=1000;%resistivity of earth
soil_eps=5; %this is not used if FD_flag != 0
% These are whatever formulas I choose to compute modal params
Zmod_src='Ztot_Carson';Zmod_src='Ztot_Wise';
Ymod_src='Ytot_Imag';Ymod_src='Ytot_Wise';
% Flags
ZYprnt=1; % Flag to print parameters
ZYsave=0; % Flag to save parameters to matfiles
export2EMTP=1; % Flag to save parameters to a matfile compatible with EMTP-RV
export2PCH=0;
FD_flag=0; % Flag for FD soil models. (0) Constant, (1) Longmire & Smith, (2) Portela, (3) Alipio & Visacro, (4) Datsios & Mikropoulos, (5) Scott, (6) Messier, (7) Visacro & Portela, (8) Visacro & Alipio, (9) Cigre
decmp_flag = 9; % Modal decomposition flag. (1) QR,(2)QR ATP,(3)simple_QR,(4)simple_QR,(5)NR,(6)NR_back,(7)SQP,(8)SQP_back,(9)LM Levenberg-Marquardt,(10)LM_back,(11)LM_fast,(12)LM_alt, (13) eigenvalue shuffle QR, (14) intercheig QR

% jobid will be appended to whatever file or plot generated by this run
jobid = ['FD' num2str(FD_flag) '_' Zmod_src '_' Ymod_src '_rho' num2str(fix(soil_rho)) '_eps' num2str(soil_eps)];

%% Library functions
currmfile = mfilename('fullpath');
currPath = currmfile(1:end-length(mfilename()));
addpath([currPath 'ZY_OHTL_pul_funs']);
addpath([currPath 'mode_decomp_funs']);
addpath([currPath 'FD_soil_models_funs']);
addpath([currPath 'export_fun']);
addpath([currPath 'Bundle_reduction_funs']);

%% Frequency range
points_per_dec=100;
f_dec1=1:10/points_per_dec:10;
f_dec2=10:100/points_per_dec:100;
f_dec3=100:1000/(points_per_dec):1000;
f_dec4=1000:10000/(points_per_dec):10000; 
f_dec5=10000:100000/(points_per_dec):100000;
f_dec6=100000:1000000/(points_per_dec):1000000;
% f_dec7=1000000:2000000/points_per_dec:2000000;
% f_dec8=2000000:4000000/points_per_dec:4000000;
% f_dec9=6000000:8000000/points_per_dec:8000000;
% f_dec10=8000000:100000000/points_per_dec:100000000;
% f_dec11=100000000:200000000/points_per_dec:200000000;
% f_dec12=200000000:400000000/points_per_dec:400000000;
% f_dec13=400000000:800000000/points_per_dec:800000000;
% f_dec14=800000000:1000000000/points_per_dec:1000000000;
% f_dec15=1000000000:10000000000/points_per_dec:10000000000;
f=transpose([f_dec1(1:length(f_dec1)-1) f_dec2(1:length(f_dec2)-1) f_dec3(1:length(f_dec3)-1) f_dec4(1:length(f_dec4)-1) f_dec5(1:length(f_dec5)-1) f_dec6]);
%f=transpose([f_dec4(1:length(f_dec4)-1) f_dec5(1:length(f_dec5)-1) f_dec6]); % for NB-PLC
%f_dec7=1000000:10000:100000000;
%f=transpose(f_dec7); % for BB-PLC
%f=transpose([1E-6 f_dec1(1:length(f_dec1)-1) f_dec2(1:length(f_dec2)-1) f_dec3(1:length(f_dec3)-1) f_dec4(1:length(f_dec4)-1) f_dec5(1:length(f_dec5)-1) f_dec6(1:length(f_dec6)-1) f_dec7]);
%f=50;
f=transpose(logspace(0,6,500));
freq_siz=length(f);

%% Line Parameters

% made a small change here to facilitate parametrization
% note that the alternative LineData_fun_() is embedded in this same file
[line_length,ord,soil,h,d,Geom]=LineData_fun_(soil_rho,soil_eps);

% however, it remains perfectly possible to call the original
% LineData_fun()
% [line_length,ord,soil,h,d,Geom]=LineData_fun();


%% Calculations
tic
[Ztot_Carson,Ztot_Noda,Ztot_Deri,Ztot_AlDe,Ztot_Sunde,Ztot_Pettersson,Ztot_Semlyen,Ztot_Wise,Nph] = Z_clc_fun(f,ord,ZYprnt,FD_flag,freq_siz,soil,h,d,Geom,ZYsave,jobid); % Calculate Z pul parameters by different earth approaches

% added more outputs to Y_clc_fun - to make it easier to access soil data
% from the top level procedure
[Ytot_Imag,Ytot_Pettersson,Ytot_Wise,sigma_g_total,erg_total,Nph] = Y_clc_fun(f,ord,ZYprnt,FD_flag,freq_siz,soil,h,d,Geom,ZYsave,jobid); % Calculate Y pul parameters by different earth approaches

% added more parameters to mode_decomp_fun() to plot results versus soil
% data
[Zch_mod,Ych_mod,Zch,Ych,g_dis,a_dis,vel_dis,Ti_dis,Z_dis,Y_dis] = mode_decomp_fun(eval(Zmod_src),eval(Ymod_src),f,freq_siz,Nph,decmp_flag,sigma_g_total,erg_total,ZYprnt,jobid); % Modal decomposition
% [H_mod,F_mod,pol_co] = HF_VF_fun(Ti_dis,g_dis,line_length,f,ord); % Vector Fitting
toc


%% Save files

%eval is not pretty but gets the job done
eval([jobid '_data.Ztot_Wise = Ztot_Wise;' ])
eval([jobid '_data.Ztot_Pettersson = Ztot_Pettersson;' ])
eval([jobid '_data.Ytot_Pettersson = Ytot_Pettersson;' ])
eval([jobid '_data.Ytot_Wise = Ytot_Wise;' ])
eval([jobid '_data.Ztot_Carson = Ztot_Carson;' ]) % this the pul (per unit len) impedance
eval([jobid '_data.Ytot_Imag = Ytot_Imag;' ]) % this the pul (per unit len) admittance
eval([jobid '_data.Zch_mod = Zch_mod;' ]) % this is the modal characteristic impedance
eval([jobid '_data.Ych_mod = Ych_mod;' ]) % this is the modal characteristic admittance
eval([jobid '_data.Zch = Zch;' ])
eval([jobid '_data.Ych = Ych;' ])
eval([jobid '_data.g_dis = g_dis;' ]) % this is the propagation constant gamma
eval([jobid '_data.a_dis = a_dis;' ]) % this is the propagation constant gamma
eval([jobid '_data.vel_dis = vel_dis;' ]) % this is the propagation constant gamma
eval([jobid '_data.Ti_dis = Ti_dis;' ])
eval([jobid '_data.Z_dis = Z_dis;' ])
eval([jobid '_data.Y_dis = Y_dis;' ])
eval([jobid '_data.sigma_g_total = sigma_g_total;' ])
eval([jobid '_data.erg_total = erg_total;' ])

if (export2EMTP)
 punch2emtp
end

if (ZYsave)
    fname = [jobid '.mat'];
    save(fname,[jobid '_data'])
    
    mkdir(currPath,[jobid '_plots'])
    FolderName = [currPath [jobid '_plots\']];   % Your destination folder
    FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
    for iFig = 1:length(FigList)
        FigHandle = FigList(iFig);
        FigName   = get(FigHandle, 'Name');
        savefig(FigHandle, [FolderName FigName '.fig']);
    end
    
end


function [length,Ncon,soil,h,d,Geom]=LineData_fun_(soil_rho,soil_eps)
% Line Geometry
%
% 1 column -- number of phase (0 to CPR with kron reduction)
% 2 column -- x position of each conduntor in meters
% 3 column -- y position of each coductor in meters
% 4 column -- internal radii of each conductor
% 5 column -- external radii of each conductor
% 6 column -- resistivity of the aluminum
% 7 column -- permeability of the conductor
% 8 column -- external radii of insulation
% 9 column -- relative permeability of insulation
% 10 column -- relative permittivity of insulation
% 11 column -- line length in m


% Geom = [1   0.0     20   0.00463  0.01257  7.1221e-8   1     nan    nan   nan   1
%         2   10.0     20   0.00463  0.01257  7.1221e-8   1     nan    nan   nan   1];
 
UNIF_LEN = 1000;

% Geom = [1  -6.6     13.5   0.00463  0.01257  7.1221e-8   1     nan    nan   nan   UNIF_LEN
%         2   0.0     13.5   0.00463  0.01257  7.1221e-8   1     nan    nan   nan   UNIF_LEN
%         3   6.6     13.5   0.00463  0.01257  7.1221e-8   1     nan    nan   nan   UNIF_LEN
%         4  10.0     01.0   0.12450  0.12700  2.8444e-7   250   0.227    1     3   UNIF_LEN       % P46
%         5  -4.65    17.6   0.00000  0.004765 2.46925E-7   1     nan    nan   nan  UNIF_LEN
%         6   4.65    17.6   0.00000  0.004765 2.46925E-7   1     nan    nan   nan  UNIF_LEN];     % P66
% %        4  10.0     01.0   0.12450  0.12700  2.8444e-7   250   nan    nan   nan   1];    % P44
% %        4  10.0     01.0   0.12450  0.12700  2.8444e-7   1   nan    nan   nan   1];      % P43
% %        4  10.0     01.0   0.00463  0.01257  7.1221e-8   1   nan    nan   nan   1];      % P42
% %        4  10.0     13.5   0.00463  0.01257  7.1221e-8   1   nan    nan   nan   1];      % P41

Geom = [1  -13.312    13.500   0.00463  0.01257  3.9245e-8    1     nan    nan   nan   UNIF_LEN
        1  -11.206    13.250   0.00463  0.01257  3.9245e-8    1     nan    nan   nan   UNIF_LEN
        2  -12.812    13.500   0.00463  0.01257  3.9245e-8    1     nan    nan   nan   UNIF_LEN
        2  -11.206    13.750   0.00463  0.01257  3.9245e-8    1     nan    nan   nan   UNIF_LEN  
        2  -10.773    13.500   0.00463  0.01257  3.9245e-8    1     nan    nan   nan   UNIF_LEN
        0   -9.062    13.500   0.00152  0.00457  19.908E-8    1     nan    nan   nan   UNIF_LEN
        0   -7.062    13.500   0.00152  0.00457  19.908E-8    1     nan    nan   nan   UNIF_LEN];

length  = Geom(1,11);                                     % Line length
Ncon    = size(Geom,1);                        % Number of conductors

% Variables
%e0=8.854187817e-12;  % Farads/meters
m0=4*pi*1e-7;        % Henry's/meters


%Height of Line Calculation
[h]=height_fun(Ncon,Geom);

%Distance between conductor calculation
[d]=distance_fun(Ncon,Geom);

% Earth Electric Parameters
soil.erg=soil_eps; %relative permittivity of earth
mrg=1;          %relative permeability of earth
soil.m_g=m0*mrg;
soil.sigma_g=1/soil_rho; %conductivity of earth
end
