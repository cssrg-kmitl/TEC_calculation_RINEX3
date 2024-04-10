function [Out] = PositionA2B(XYZa,XYZb)
% =====================================
% [Out] = PositionA2B(XYZa,XYZb)
% XYZa : Receiver Position in ECEF
% XYZb : Satellite Positon in ECEF
% =====================================
LLA = ecef2lla(XYZa(:)');
Lat0  = LLA(1);
Lon0 = LLA(2);

% The rotation matrix R of the ECEF coordinates to the local coordinates
E = [-sind(Lon0) cosd(Lon0) 0];
N = [-sind(Lat0)*cosd(Lon0) -sind(Lat0)*sind(Lon0) cosd(Lat0)];
U = [cosd(Lat0)*cosd(Lon0) cosd(Lat0)*sind(Lon0) sind(Lat0)];

r = [XYZb(1)-XYZa(1) XYZb(2)-XYZa(2) XYZb(3)-XYZa(3)];
P = r./norm(r); % Unit vector
Out.E = P*E';
Out.N = P*N';
Out.U = P*U';

% The ENU => Elevation & Azimuth 
Out.Ele = asin(P*U')*180/pi; % Elevation angle(deg)
Out.Azi = atan2(P*E',P*N')*180/pi; % Azimuth angle(deg)
end
% referenceEllipsoid
