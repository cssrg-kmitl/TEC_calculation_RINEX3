%% Total Electron Content (TEC) calculation from RINEX 3.04
% Calculate TEC based on dual-frequency receiver (GPS)
% Original by Napat Tongkasem, Somkit Sopan, Jirapoom Budtho, Nantavit Wongthodsarat
% Version 1.00 
% (08/2019) - Create the program
% (06/2023) - Upgrad the program to RINEX 3.04
% 1. The program need linux command. Cygwin must be installed
% - install Cygwin-setup-x86_64.exe (64-bit ver.)
% or download: http://cygwin.com/install.html
% 
% 2. Main program is ProcessTECCalculation.m
% 
% 3. We have laboratory website, you can visit
% - http://iono-gnss.kmitl.ac.th/
% =================================================
% Advisor: Prof.Dr. Pornchai Supnithi
% CSSRG Laboratory
% School of Telecommunication Engineering
% Faculty of Engineering
% King Mongkut's Institute of Technology Ladkrabang
% Bangkok, Thailand
% =================================================
% Output : data 1 day 
% TEC.vertical    = Vertical Total Electron Content(VTEC)
% TEC.slant       = Slant Total Electron Content(STEC)
% TEC.withrcvbias = STEC with receiver DCB
% TEC.withbias    = STEC with satellite and receiver DCB
% TEC.STECp       = STEC calculated from code range
% TEC.STECl       = STEC calculated from carrier phase
% DCB.sat         = Satellite DCB
% DCB.rcv         = Receiver DCB
% prm.elevation   = elevation angle
% ROTI            = Rate Of Change TEC Index

close all; clear; clc
warning off
tic
% 1. copy RINEX v 3.04 to /RINEX folder
% 2. define RINEX file's name
%% RINEX file
r_o_name = 'RUTI1700.23o'; % observation file's name
r_n_name = 'RUTI1700.23n'; % navigation file's name
% r_n_name = ''; % navigation file's name

% Setting#1
% =========== Program's path ==========================
p_path = [pwd '\'];             % Program path
R_path = [p_path 'RINEX\'];     % RINEX path
if ~isempty([R_path 'Results\']);mkdir([R_path 'Results\']);end
S_path = [R_path 'Results\'];   % Results path
DCB_path   = [R_path 'DCB\'];   % DCB path
if ~isempty(DCB_path);mkdir(DCB_path);end
path(path,[p_path 'function']);

%% 1. Read RINEX (using readrinex .mex file)
% Check file
checkfileRN(r_o_name,R_path);
% Read RINEX  
[obs,nav,doy,Year] = readrinex304(r_o_name,r_n_name,R_path); 
year  = num2str(obs.date(1));
month = num2str(obs.date(2),'%.2d');
date  = num2str(obs.date(3),'%.2d');
% download satellite bias
[satb.P1C1,satb.P1P2] = dlsat(obs,p_path,DCB_path);

%% 2. Calculate Total Electron Content(TEC)
TECcalculationRINEX304_OEM7(obs,nav,satb,S_path);

%% 3. Plot Error
plotTEC(year,month,date,obs.station,S_path);
toc
% remove file (reset)
% delete([S_path 'TEC_' obs.station '_' year '_' month '_' date '.mat']);
warning on

