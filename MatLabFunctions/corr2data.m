function [table, minLat_data, maxLat_data, minLon_data, maxLon_data] = ...
    corr2data(data, minLat,maxLat, minLon, maxLon)
% Version 6/27.2
% This function takes global positions, in terms of latitudes and
% longitudes, and an associated data set which is being plotted onto those
% positions. It outputs the x and y coordinates at the edges of the region
% and the  the matrix of datapoints. The outputs are rounded
% conservatively. If only one input is entered, returns the whole globe.
% If no output is requested, prints the region in a reoriented pattern.
%
%   minLat - the low end of the Latitudes of interest
%   maxLat - the high end of the Latitudes of interest
%   minLon - the low end of the Longitudes of interest
%   maxLon - the high end of the Longitudes of interest
%   data - The data set being investigated
%   minLat_data - the low end of the columns of interest
%   maxLat_data - the high end of the columns of interest
%   minLon_data - the low end of the rows of interest
%   maxLon_data - the high end of the rows of interest
%   table - the table of values being investigated.

if maxLat < minLat
   error('Maximum Latitude must be greater than the minimum.')
end
if maxLon < minLon
   error('Maximum Longitude must be greater than the minimum.')
end

[dataLons dataLats] = size(data);
switch nargin
    case 1
        minLat = -90;
        maxLat = 90;
        minLon = -180;
        maxLon = 180;
    otherwise
end

minLat_data = floor((dataLats - 1) * minLat/180 + (dataLats + 1)/2)
maxLat_data = ceil((dataLats - 1) * maxLat/180 + (dataLats + 1)/2)
minLon_data = floor((dataLons - 1) * minLon/358.75 + (dataLons+1)/2)
maxLon_data = ceil((dataLons - 1) * maxLon/358.75 + (dataLons+1)/2)
table = data(minLon_data:maxLon_data, minLat_data:maxLat_data);
if minLat_data < 1
    minLat_data = 1;
end
if minLon_data < 1
    minLon_data = 1;
end
if maxLat_data < 1
    maxLat_data = 1;
end
if maxLon_data < 1
    maxLon_data = 1;
end

if nargout < 1
    disp('Map of Values Called')
    yflippedtable = table(end:-1:1, :);
    yflippedtable'
end
end

