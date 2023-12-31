# Matlab_Generic_ulg_Parser
Simple Matlab script that spits out UTC time, latitude, longitude, altitude, speed, distance traveled from a .ulg file. Sends the data to a .csv file, and also spits out a flight path map.

# Instructions:

1. Please download Matlab R2023a. The version doesn't matter, but please download the latest version if possible.
2. Open Aday_Generic_ulg_Parser.m.
3. Click on the "Run" button.
4. Enter the .ulg file name in the console at the bottom of the Matlab screen, without entering '.ulg' at the end. Example: myFilenameWithoutTheExtension
5. Press the enter key.
6. Wait for about a minute. A plot of the drone flight + a .csv file with the timestamp & coordinates should generate.

**NOTE:**
If the columns for the date or time come out odd, change the column format to 'Date' and 'Time' in the .xlsx sheet, respectively.
