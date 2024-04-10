function [obs,nav,doy,Year] = readrinex304(r_o_name,r_n_name,rinex_path)
% Read observation and navigation RINEX file V. 3.02 - 3.04
% Inputs  : 
%          r_o_name - Observation RINEX's name
%          r_n_name - Navigation RINEX's name
% Outputs :
%          ----------- obs - observation ---------------
%          obs.date    - date, month, year
%          obs.epoch   - epoch of day (second of day)
%          obs.type    - type of pseudorange
%          obs.station - station name
%          obs.data    - data (pseudorange, SNR, etc.)
%          obs.index   - number of satellites
%          obs.rcvpos  - receiver position
%          ----------- nav - navigation ----------------
%          nav.eph     - ephemaris data of satellites
%          nav.index   - number of satellites
%          nav.ionprm  - Ionospheric coefficients
% You can change IGS station to download nav file
% Look at : ftp://anonymous:anonymous@cddis.gsfc.nasa.gov/pub/gps/data/daily/'year'/'doy'/'*n'/
%
% ****** If there are many lost data, the RINEX files cannot be read. ******

n_name = 'cusv'; %amu2, ankr, cnmr, chpi
current_path = [pwd '\'];
cd(rinex_path)
% Read RINEX Observation Files
[Obs.Com,Obs.XYZr,Obs.Type,Obs.Date,Obs.Ep,Obs.Data,Obs.PRN] = ReadOBSrinex304(r_o_name);
obs.date = round(Obs.Date.St(:)');
obs.epoch = Obs.Ep.G';
obs.type = Obs.Type.G;
obs.data = Obs.Data.G';
obs.index = Obs.PRN.G';
obs.rcvpos = Obs.XYZr;
obs.station = r_o_name(1:4);

%     [obs.date, obs.epoch, obs.type, ~, ~, obs.station, obs.data, obs.index, obs.rcvpos,...
%         ~, ~, ~] = readrinexobs(r_o_name);

% Calculate Date Of Year (DOY)
disp('The data date:');
disp(datetime(obs.date(1:3)));
D1  = obs.date(1:3); % obs.date
D2  = D1; D2(:,2:3) = 0;
ydoy = cat(2, D1(:,1), datenum(D1) - datenum(D2));
Year = num2str(ydoy(1,1));
doy  = num2str(ydoy(1,2),'%.3d');
    
% Check NAV file \ Get online ephemeris
n = dir([rinex_path '*' r_o_name(end-7:end-1) 'n']);

if isempty(n) % Download Navigation file
    try
        nav_filename = [n_name doy '0.' Year(3:4) 'n.Z'];
        disp(['Download NAV RINEX file ' nav_filename])
        % download nav file
        nav_dl_cmd = ['curl.exe -s -v -O --retry 50 --retry-max-time 0 ftp://anonymous:anonymous@cddis.gsfc.nasa.gov/pub/gps/data/daily/' Year '/' doy '/' Year(3:4) 'n/' nav_filename];
        system(nav_dl_cmd)
        % unzip nav file
        nav_uz_cmd    = ['gzip.exe -d ' nav_filename];
        system(nav_uz_cmd)
        n = dir([rinex_path nav_filename(1:end-2)]);
        r_n_name = n.name;
        disp(['Nav file: ' r_n_name ' is downloaded'])
    catch
        cd(current_path)
        error(['error to download Nav file: ' n_name '. Please edit new Nav name in **readrinex304**'])
    end
end

% Read RINEX Navigation File
% --- Check D-, D+ --> E-, E+
Temp ='Temp.n';
Fnav = fileread(r_n_name); % read file (string)
if contains(Fnav,'D-')||contains(Fnav,'D+')
    nFnav = strrep(Fnav,'\','/');
    nFnav = strrep(nFnav,'D-','E-');
    nFnav = strrep(nFnav,'D+','E+');
    nFnav = strsplit(nFnav,'\n');
    [~,Col] = size(nFnav);
    nFid = fopen(Temp,'wt');
    [~,n] = size(nFnav{1});
    if n>80
        for i = 1:Col
            fprintf(nFid,[nFnav{i}(1:end-1) '\n']);
        end
    else
        for i = 1:Col
            fprintf(nFid,[nFnav{i} '\n']);
        end
    end
    fclose(nFid);
    clear nFnav
end
clear Fnav

[Nav.Com,Nav.Ion,Nav.dTime,Nav.Leap,Nav.Eph,Nav.PRN] = ReadNAVrinex304(Temp);
nav.eph = Nav.Eph.G';
nav.index = Nav.PRN.G';
nav.ionprm = Nav.Ion;
%     [~, ~, nav.eph, nav.index, nav.ionprm,...
%         ~, ~] = readrinexnav(r_n_name);
    
cd(current_path)
end
