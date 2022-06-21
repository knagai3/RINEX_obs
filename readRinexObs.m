%==========================================================================
%	Author:     Santiago Perea
%	Version:	1.0
%   Datum:      30.08.2016
%==========================================================================
%
%   [ Header, GAL_obsdata ] = readRinexObs(FileName,DecimateFactor)
%
%   This function reads GAL Rinex Observation data
%
%   Inputs: FileName        Rinex Observation file name
%           DecimateFactor  Decimation of input data. If '1' all data point
%                           are read. If '2'" every second data point is read.
%   Output: Header          Headear of the file
%           XXX_obsdata     observation messages
%
%   MODIFICATIONS:    
%     2022-06-20  :  Kana Nagai Add Beido and GLONASS
%
% =========================================================================

function [ Header, GPS_obsdata, GAL_obsdata, GLO_obsdata, BEI_obsdata, obsdata ] = ...
    readRinexObs(FileName,DecimateFactor)

% Open Input File
fileId=fopen(FileName);

if fileId == -1
    errordlg(['Problem when trying to open reference file ' FileName]);
end

% Decimate Factor
if (DecimateFactor<=0)
    DecimateFactor = 1;
else
    DecimateFactor = round(DecimateFactor);
end

% GPS
GPS_obsdata = [];
% Galileo
GAL_obsdata = [];
% GLONASS
GLO_obsdata = [];
% BeiDo
BEI_obsdata = [];
% All
obsdata = [];

numlines = 0;

%% Read Header ------------------------------------------------------------

linecount = 0;

while 1
 
    line = fgetl(fileId);
    linecount = linecount+1;
    
    len = length(line);
    if (len < 80)
        line(len+1:80) = '0';
    end
    
    if ( strcmp( line(61:73), 'END OF HEADER') ) 
        break
    end
    
    if ( strcmp( line(61:79), 'APPROX POSITION XYZ') )
        MARKER_XYZ(1) = str2double(line(1:14));
        MARKER_XYZ(2) = str2double(line(15:28));
        MARKER_XYZ(3) = str2double(line(29:42));
    end
    
    if ( strcmp( line(61:80), 'ANTENNA: DELTA H/E/N' ) )
        ANTDELTA(1) = str2double(line(1:14));
        ANTDELTA(2) = str2double(line(15:28));
        ANTDELTA(3) = str2double(line(29:42));
    end
    
    if ( strcmp( line(61:68), 'INTERVAL' ) )
        OBSINT = str2double(line(1:10));
    end
    
end

if (isempty(OBSINT))
    OBSINT = 30.0;
end

Header.interval = OBSINT;
Header.Antdelta = ANTDELTA;
Header.ApprPos = MARKER_XYZ;

bar1 = waitbar( 0,'Please, wait...','Name','Loading RINEX Observation Data');

%% Read DATA RECORD DESCRIPTION -------------------------------------------

k = 0;
breakflag = 0;

while 1
    
    k = k+1;    % 'k' is keeping track of our time steps
    
    for ideci = 1:DecimateFactor
        
        line = fgetl(fileId);
        linecount = linecount+1;
        
        if ~ischar(line)
            breakflag = 1;
            break,
        end
                
        UTC_time = [str2double(line(3:6)), ...
            str2double(line(8:9)), ...
            str2double(line(11:12)), ...
            str2double(line(14:15)), ...
            str2double(line(17:18)), ...
            str2double(line(20:22))];
        [gpsw,gpss] = utc2gps(UTC_time,0);
            
        numsvs = str2double(line(34:35));
        
        for i = 1:numsvs
            line = fgetl(fileId);
            linecount = linecount+1;
            
            if ~ischar(line)
                break,
            end
            
            len = length(line);
            if len < 80
                line(len+1:80) = '0';
            end            
            
            if (strcmp( line(1:1), 'G') )
            cons = 1; 
            prn = str2double(line(2:3));
            SSI = str2double(line(19));
            C1 = str2double(line(4:18));
            L1 = str2double(line(20:34));     
            GPS_obsdata = [GPS_obsdata; [gpsw gpss cons prn SSI C1 L1]];
            obsdata = [obsdata; [gpsw gpss cons prn SSI C1 L1]];
            end
            
            if (strcmp( line(1:1), 'E') )
            cons = 2; 
            prn = str2double(line(2:3));
            SSI = str2double(line(19));
            C1 = str2double(line(4:18));
            L1 = str2double(line(20:34));   
            GAL_obsdata = [GAL_obsdata; [gpsw gpss cons prn SSI C1 L1]];
            obsdata = [obsdata; [gpsw gpss cons prn SSI C1 L1]];
            end

            if (strcmp( line(1:1), 'R') )
            cons = 3; 
            prn = str2double(line(2:3));
            SSI = str2double(line(51));
            C2 = str2double(line(36:50));
            L2 = str2double(line(52:66));   
            GLO_obsdata = [GLO_obsdata; [gpsw gpss cons prn SSI C2 L2]];
            obsdata = [obsdata; [gpsw gpss cons prn SSI C2 L2]];
            end            
 
            if (strcmp( line(1:1), 'C') )
            cons = 4; 
            prn = str2double(line(2:3));
            SSI = str2double(line(19));
            C2 = str2double(line(4:18));
            L2 = str2double(line(20:34));   
            BEI_obsdata = [BEI_obsdata; [gpsw gpss cons prn SSI C2 L2]];
            obsdata = [obsdata; [gpsw gpss cons prn SSI C2 L2]];
            end            
            
        end
        
    end
    
    waitbar(linecount/numlines,bar1);
    
    if breakflag == 1
        waitbar(linecount/numlines,bar1);
        break,
    end
    
end  % End the WHILE 1 Loop

close(bar1)
