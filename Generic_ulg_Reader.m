%% Writer: Ryan Aday
%% Contact: Ryan.Aday@rtx.com
%% .ulg Reader

% Clear all data
clear all; clc;
warning('off', 'all');
format long

fprintf('.ulg Table Generator\n');
fprintf('Written by Ryan Aday.\n');
fprintf('Contact: Ryan.Aday@rtx.com, 978.863.7162\n\n');

%[folder, name, ext] = fileparts(which('Aday_AltaX_ulog_Timestamp_GPS_Reader.m'));

filename = input("Type filename (DO NOT ENTER .ulg): ", "s");
filename_output = [pwd '\' filename ' Output Data.csv'];
filename = [pwd '\' filename '.ulg'];
ulogOBJ = ulogreader(filename);

%{
vehicleLocalPositionData = readTopicMsgs(ulogOBJ,'TopicNames', ...
    {'vehicle_local_position'}, 'InstanceID', {0});
vehicleLocalPositionDataTopicMessages = ...
    vehicleLocalPositionData.TopicMessages{:};

X = vehicleLocalPositionDataTopicMessages.x;
Y = vehicleLocalPositionDataTopicMessages.y;
Z = vehicleLocalPositionDataTopicMessages.z;

delX = X - X(1);
delY = Y - Y(1);
delZ = Z - Z(1);

delM = sqrt(delX .^ 2 + Y .^ 2 + Z .^ 2);
del_time = 0.1;
Speed_Mag_mps = delM./del_time;

vehicleLocalPositionSetpointData = ...
    readTopicMsgs(ulogOBJ,'TopicNames',...
    {'vehicle_local_position_setpoint'}, 'InstanceID', {0});
vehicleLocalPositionSetpointDataTopicMessages = ...
    vehicleLocalPositionSetpointData.TopicMessages{:};

%}
gpsPositionData = readTopicMsgs(ulogOBJ,'TopicNames',{'vehicle_gps_position'}, 'InstanceID', {0});
globalPositionData = readTopicMsgs(ulogOBJ,'TopicNames',{'vehicle_global_position'}, 'InstanceID', {0});

globalPositionDataTopicMessages = globalPositionData.TopicMessages{:};
gpsPositionDataTopicMessages = gpsPositionData.TopicMessages{:};

Latitude =single(gpsPositionDataTopicMessages.lat)/1e7;
Longitude = single(gpsPositionDataTopicMessages.lon)/1e7;
Altitude_m = single(gpsPositionDataTopicMessages.alt)/1e3;
Height_m = Altitude_m - Altitude_m(1);
Time_UTC = gpsPositionDataTopicMessages.time_utc_usec;

FlightTime_UTC = Time_UTC - Time_UTC(1);
FlightTime_UTC = string(datetime(FlightTime_UTC, 'ConvertFrom','epochtime',...
    'TicksPerSecond',1e6,'Format','HH:mm:ss.SSSSSS'));

Date_UTC = string(datetime(Time_UTC, 'ConvertFrom','epochtime',...
    'TicksPerSecond',1e6,'Format','dd-MMM-yyyy'));
Date_HMS_UTC = string(datetime(Time_UTC, 'ConvertFrom','epochtime',...
    'TicksPerSecond',1e6,'Format','HH:mm:ss.SSSSSS'));

Timestamp = gpsPositionDataTopicMessages.timestamp;
Vel_m_s = gpsPositionDataTopicMessages.vel_m_s;
Vel_North_m_s = gpsPositionDataTopicMessages.vel_n_m_s;
Vel_East_m_s = gpsPositionDataTopicMessages.vel_e_m_s;
Vel_Hoz_m_s = sqrt(Vel_North_m_s .^ 2 + Vel_East_m_s .^ 2);
Vel_Depth_m_s = gpsPositionDataTopicMessages.vel_d_m_s;

del_dist_m = 0.1 * Vel_m_s;
Distance_Traveled_m = cumsum(del_dist_m);

flightPlot = figure(1);
clf(flightPlot);
geoplot(Latitude, Longitude)
geobasemap streets


%Longitude_DMS = degrees2dms(Longitude);
Longitude_DMS = convertDMS(Longitude);

Long_Degrees = Longitude_DMS(:,1);
Long_Minutes = Longitude_DMS(:,2);
Long_Seconds = Longitude_DMS(:,3);

%Latitude_DMS = degrees2dms(Latitude);
Latitude_DMS = convertDMS(Longitude);

Lat_Degrees = Longitude_DMS(:,1);
Lat_Minutes = Longitude_DMS(:,2);
Lat_Seconds = Longitude_DMS(:,3);

Altitude_ft = mToFt(Altitude_m);
Height_ft = mToFt(Height_m);
Distance_Traveled_ft = mToFt(Distance_Traveled_m);

Vel_mps = mpsToMPH(Vel_m_s);
Vel_North_mps = mpsToMPH(Vel_North_m_s);
Vel_East_mps = mpsToMPH(Vel_East_m_s);
Vel_Hoz_mps = mpsToMPH(Vel_Hoz_m_s);
Vel_Depth_mps = mpsToMPH(Vel_Depth_m_s);

dataOutput = table(Date_UTC, Date_HMS_UTC, FlightTime_UTC, ...
    Longitude, Long_Degrees, Long_Minutes, Long_Seconds, ...
    Latitude, Lat_Degrees, Lat_Minutes, Lat_Seconds, ... 
    Altitude_m, Height_m, ...
    Vel_m_s, Vel_North_m_s, Vel_East_m_s, Vel_Hoz_m_s, ...
    Vel_Depth_m_s, Distance_Traveled_m, ...
    Altitude_ft, Height_ft, ...
    Vel_mps, Vel_North_mps, Vel_East_mps, Vel_Hoz_mps, ...
    Vel_Depth_mps, Distance_Traveled_ft);
writetable(dataOutput, filename_output)

clear

function ftMeas = mToFt(meterMeas)
    centiMeas = meterMeas * 100;
    inMeas = centiMeas/2.54;
    ftMeas = inMeas / 12;
end

function mphMeas = mpsToMPH(mpsMeas)
    mphMeas = 2.23693629 * mpsMeas;
end

function outputArray = convertDMS(coordinates)
    coordinates_mod = char(string(coordinates * 1e7));
    outputArray = [];

    offset = 0;

    if contains(string(coordinates_mod), "-")
        offset = 1;
    end

    outputArray = [cellstr(coordinates_mod(:, 1:2+offset)) ...
        cellstr(coordinates_mod(:, 3+offset:4+offset)) ...
        cellstr(coordinates_mod(:, 5+offset:end))];
end