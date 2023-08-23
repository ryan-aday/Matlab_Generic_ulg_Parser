%% Writer: Ryan Aday
%% Contact: Ryan.Aday@rtx.com
%% .ulg Reader

% Clear all data
clear all; clc;
warning('off', 'all');
format long

fprintf('.ulg Table Generator\n');
fprintf('Written by Ryan Aday.\n');
fprintf('License: MIT 2023\n\n');

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

dataOutput = table(Date_UTC, Date_HMS_UTC, FlightTime_UTC, ...
    Longitude, Latitude, Altitude_m, Height_m, ...
    Vel_m_s, Vel_North_m_s, Vel_East_m_s, Vel_Hoz_m_s, ...
    Vel_Depth_m_s, Distance_Traveled_m);
writetable(dataOutput, filename_output)
