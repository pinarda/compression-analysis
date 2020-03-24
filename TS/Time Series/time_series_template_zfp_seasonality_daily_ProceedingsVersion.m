%Creates the error time series plot for zfp for TS used in the technote. On the
%right is the first 3 years of the time series, in the middle is the
%histogram of the entire time series, and on the right is the periodogram
%of the time series. The z-score, mean, and standard deviation of the time
%series is also included to the right.

clear *

addpath('/gpfs/u/home/apoppick/MATLABPackages/b2r');
addpath('/gpfs/u/home/apoppick/MATLABPackages/subaxis');
addpath('/gpfs/u/home/nardij/MATLABPackages/autocorr_matrix');

data_dir = '/glade/p/cisl/iowa/abaker_carleton/';
save_dir = '/gpfs/u/home/apoppick/';
variable = 'TS';
alg_prefix = 'zfpATOL';
tol = '1e-1';

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
nLon = size(model_lon, 1);
nLat =  size(model_lat, 1);
N =  size(orig_data, 3);
diff_data_path = [data_dir, lower(variable), '/', char(alg_prefix), char(tol), '/', variable, '.diff-', char(alg_prefix), char(tol), '.nc']
diff_data = ncread(diff_data_path, variable);
diff_data = diff_data([146:288, 1:145], :, :); %reorganize longitudes
diff_mean = mean(diff_data, 3);
diff_sd = std(diff_data, 0, 3);
Zscore = diff_mean ./ (diff_sd/sqrt(N));


%% Time Series 

lat_num = 9;
lon_num = 77;
lat = model_lat(lat_num);
lon = model_lon(lon_num);
point_1 = diff_data(lon_num,lat_num,:);
point_1 = reshape(point_1, 1,[]);
point_1_zscore = Zscore(lon_num,lat_num);
point_1_mean = diff_mean(lon_num,lat_num);
point_1_sd = diff_sd(lon_num,lat_num);

ax1 = subaxis(1,3,1, 'Spacing', 0.0, 'Padding', 0.04, 'Margin', 0.1);
point_1_reduced = point_1(1:1095);
x = linspace(0,5,1095);
plot(x,point_1_reduced)
xlim([0 3])
xlabel('years')
ylabel('error')
set(gca,'FontSize',8)
ax2 = subaxis(1,3,2, 'Spacing', 0.0, 'Padding', 0.04, 'Margin', 0.1);
histogram(point_1)
xlabel('error')
ylabel('count')
set(gca,'FontSize',8)
ax3 = subaxis(1,3,3, 'Spacing', 0.0, 'Padding', 0.03, 'Margin', 0.1);
Y = point_1;
Y_tilde = fft(Y - mean(Y)); %FFT of every (de-meaned) column
I = real(Y_tilde.*conj(Y_tilde)./N); %periogoram
I = I(2:(N/2+1)); %periodogram values past N/2 simply repeat the first N/2 value
freqs = (1:(N/2))./N;
plot(freqs, log10(I)) %usually plot periogoram on log scale
text((freqs(86)),(double(log10(I(86)))),'\leftarrow 1/365', 'FontSize',6)
xlim([0 0.5])
xlabel('frequency') %units of frequency are cycles per month or day, depending on whether you're looking at daily or monthly data
ylabel('log10(periodogram)')
set(gca,'FontSize',8)
ax4 = axes('Position',[0.85 -0.1 1 1],'Visible','off');
descr = {['Z-score:' , num2str(point_1_zscore,2)];
    ['Mean:' , num2str(point_1_mean,2)];
    ['SD:', num2str(point_1_sd,2)]};
axes(ax4)
text(.025,0.6,descr, 'FontSize', 10)
ax5 = axes('Position',[0.2 0.35 1 1],'Visible','off');
title = ['Time Series Lon ', num2str(lon,3), ' Lat ', num2str(lat,3), ' ', alg_prefix, tol];
axes(ax5)
text(.2,0.6,title, 'FontWeight', 'bold', 'FontSize', 9)
set(gcf,'Units', 'inches', 'Position', [0 0 10 4], 'PaperUnits','inches','PaperPosition', [0 0 10 4])
save_path = [save_dir,alg_prefix, tol,'timeseriesday_AllisonPlot.png'];
print(save_path, '-dpng', '-r300')
close