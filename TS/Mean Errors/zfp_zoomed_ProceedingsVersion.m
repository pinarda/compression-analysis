% Creates a 1x3 plot of zoomed in mean errors for the zfp algorithm for TS 
% used in the technote. The left plot is centered around -120 degrees 
% longitude, the middle plot is centered around 0 degrees longitude, and 
% the right plot is centered around 120 degrees longitude.

clear *

addpath('/gpfs/u/home/apoppick/MATLABPackages/b2r');
addpath('/gpfs/u/home/apoppick/MATLABPackages/subaxis');
addpath('/gpfs/u/home/nardij/MATLABPackages/autocorr_matrix');

data_dir = '/glade/p_old/tdd/asap/abaker_carleton/';
save_dir = '/gpfs/u/home/apoppick/';
variable = 'TS';
alg_prefix = 'zfpATOL';
tol = '1e-2';

%% Read in Data

if strcmp(variable, 'TSMX')
    orig_data_path = [data_dir, lower(variable), '/orig/', 'b.e11.B20TRC5CNBDRD.f09_g16.030.cam.h0.', variable, '.192001-200512.nc']
end
if strcmp(variable, 'TS')
    orig_data_path = [data_dir, lower(variable), '/orig/', 'b.e11.B20TRC5CNBDRD.f09_g16.030.cam.h1.', variable, '.19200101-20051231.nc']
end
orig_data = ncread(orig_data_path, variable);
orig_data = orig_data([146:288, 1:145], :, :); %reorganize longitudes
model_lat = ncread(orig_data_path,'lat');
model_lon = ncread(orig_data_path,'lon');
model_lon(model_lon > 180) = model_lon(model_lon > 180) - 360;
model_lon = [model_lon(146:288); model_lon(1:145)];
model_lat_edge = ncread(orig_data_path, 'slat');
model_lon_edge = ncread(orig_data_path, 'slon');
model_lon_edge(model_lon_edge > 180) = model_lon_edge(model_lon_edge > 180) - 360;
model_lon_edge = [model_lon_edge(146:288); model_lon_edge(1:145)];
nLon = size(model_lon, 1);
nLat =  size(model_lat, 1);
N =  size(orig_data, 3);
diff_data_path = [data_dir, lower(variable), '/', char(alg_prefix), char(tol), '/', variable, '.diff-', char(alg_prefix), char(tol), '.nc']
diff_data = ncread(diff_data_path, variable);
diff_data = diff_data([146:288, 1:145], :, :); %reorganize longitudes
diff_mean = mean(diff_data, 3);
diff_mean_reduced_1 = diff_mean(136:152,59:86);
diff_mean_reduced_2 = diff_mean(232:248,59:86);
diff_mean_reduced_3 = diff_mean(40:56,59:86);
boxLat = model_lat_edge(1:4:(end-4));
boxLon = model_lon_edge(5:4:end);

set(gcf,'Units', 'inches', 'Position', [0 0 6 4], 'PaperUnits','inches','PaperPosition', [0 0 6 4])

ax1 = subaxis(1,3,1, 'Spacing', 0.0, 'Padding', 0.01, 'Margin', 0.04);
axesm('robinson','MapLonLimit',[model_lon_edge(40) model_lon_edge(57)], 'MapLatLimit',[model_lat_edge(59) model_lat_edge(87)], 'Grid', 'on', 'ParallelLabel', 'on', 'MeridianLabel', 'on', 'MLineLocation', boxLon, 'PLineLocation', boxLat, 'FontSize', 5, 'LabelFormat', 'none');
framem;
load coast;
pcolorm([model_lat_edge(59)  model_lat_edge(87)],[model_lon_edge(40) model_lon_edge(57)], diff_mean_reduced_3');
plotm(lat,long, 'k');
colormap(ax1,flipud(b2r(-max(max(abs(diff_mean))), max(max(abs(diff_mean))))));
C2 = colorbar('SouthOutside', 'Position', [0.0500    0.19   0.2875    0.025]);
xlabel(C2,'Mean','FontSize',8);

ax2 = subaxis(1,3,2, 'Spacing', 0.0, 'Padding', 0.01, 'Margin', 0.04);
axesm('robinson','MapLonLimit',[model_lon_edge(136) model_lon_edge(153)], 'MapLatLimit',[model_lat_edge(59) model_lat_edge(87)], 'Grid', 'on', 'ParallelLabel', 'on', 'MeridianLabel', 'on', 'MLineLocation', boxLon, 'PLineLocation', boxLat, 'FontSize', 5, 'LabelFormat', 'none');
framem;
load coast;
pcolorm([model_lat_edge(59)  model_lat_edge(87)],[model_lon_edge(136) model_lon_edge(153)], diff_mean_reduced_1');
plotm(lat,long, 'k');
colormap(ax2, flipud(b2r(-max(max(abs(diff_mean))), max(max(abs(diff_mean))))));
C2 = colorbar('SouthOutside', 'Position', [0.3571  0.19   0.2875    0.025]);
xlabel(C2,'Mean','FontSize',8);

ax3 = subaxis(1,3,3, 'Spacing', 0.0, 'Padding', 0.01, 'Margin', 0.04);
axesm('robinson','MapLonLimit',[model_lon_edge(232) model_lon_edge(249)], 'MapLatLimit',[model_lat_edge(59) model_lat_edge(87)], 'Grid', 'on', 'ParallelLabel', 'on', 'MeridianLabel', 'on', 'MLineLocation', boxLon, 'PLineLocation', boxLat, 'FontSize', 5, 'LabelFormat', 'none');
framem;
load coast;
pcolorm([model_lat_edge(59)  model_lat_edge(87)],[model_lon_edge(232) model_lon_edge(249)], diff_mean_reduced_2');
plotm(lat,long, 'k');
colormap(ax3,flipud(b2r(-max(max(abs(diff_mean))), max(max(abs(diff_mean))))));
C2 = colorbar('SouthOutside', 'Position', [0.6625    0.19   0.2875    0.025]);
xlabel(C2,'Mean','FontSize',8);

save_sd_path = [save_dir, char(alg_prefix), char(tol), variable, 'zoom_new.png'];
print(save_sd_path, '-dpng', '-r300')
close

