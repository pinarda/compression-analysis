% This code plots verical contrast variances comparing TREFHT to TS

clear *

addpath('/glade/u/home/apoppick/MATLABPackages/b2r');
addpath('/glade/u/home/apoppick/MATLABPackages/subaxis');
addpath('/glade/u/home/apoppick/MATLABPackages/freezeColors');
addpath('/glade/u/home/apoppick/MATLABPackages/cm_and_cb_utilities');

wd = '/glade/p/cisl/iowa/abaker_carleton/';
variable = 'TS';

%% Read in original data
orig_data_path = [wd, lower(variable), '/orig/', 'b.e11.B20TRC5CNBDRD.f09_g16.030.cam.h1.', variable, '.19200101-20051231.nc'];
orig_data_TS = ncread(orig_data_path, variable);
orig_data_TS = orig_data_TS([146:288, 1:145], :, :); %reorganize longitudes
model_lat = ncread(orig_data_path,'lat');
model_lon = ncread(orig_data_path,'lon');
model_lon(model_lon > 180) = model_lon(model_lon > 180) - 360;
model_lon = [model_lon(146:288); model_lon(1:145)];
nLon = size(model_lon, 1);
nLat =  size(model_lat, 1);

orig_data_TREFHT = ncread('/glade/work/apoppick/b.e11.B20TRC5CNBDRD.f09_g16.030.cam.h1.TREFHT.19200101-20051231.nc', ...
    'TREFHT');
orig_data_TREFHT = orig_data_TREFHT([146:288, 1:145], :, :); %reorganize longitudes

cVert = mean((orig_data_TREFHT - orig_data_TS).^2, 3);

axesm('robinson');
set(gca, 'LooseInset', get(gca,'TightInset'));
framem; tightmap;
load coast;
pcolorm([-90 90],[-180,180],log10(cVert'))
plotm(lat,long, 'k');
colormap(flipud(w2k_new(-max(abs(log10(cVert(:)'))), max(abs(log10(cVert(:)'))))));
C2 = colorbar('southoutside', 'FontSize', 5);
%title([num2str(round(100 * mean(10.^logratio_diff(:) > sig_cutoff),1)), ...
%    '% significant'], 'FontSize', 7)