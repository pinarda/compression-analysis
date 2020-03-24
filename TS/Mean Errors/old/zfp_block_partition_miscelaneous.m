% Describes ZFP compression data at the box level in several ways. This
% includes time series and correlation investigations.

%% Prep Statements !!!
clear *

addpath('/glade/u/home/apoppick/MATLABPackages/b2r');
addpath('/glade/u/home/apoppick/MATLABPackages/subaxis');
addpath('/glade/u/home/apoppick/MATLABPackages/freezeColors');
addpath('/glade/u/home/apoppick/MATLABPackages/cm_and_cb_utilities');
addpath('/glade/u/home/apoppick/MATLABPackages/fLOESS');

data_dir = '/glade/p/cisl/iowa/abaker_carleton/';
variable = 'TS';
alg_prefix = 'zfpATOL';
tol = '1e-2';

%% Read in Data
if strcmp(variable, 'TSMX')
    orig_data_path = [data_dir, lower(variable), '/orig/',...
       'b.e11.B20TRC5CNBDRD.f09_g16.030.cam.h0.', variable, '.192001-200512.nc'];
end
if strcmp(variable, 'TS')
    orig_data_path = [data_dir, lower(variable), '/orig/',...
                       'b.e11.B20TRC5CNBDRD.f09_g16.030.cam.h1.', variable, '.19200101-20051231.nc'];
end
orig_data = ncread(orig_data_path, variable);
orig_data = orig_data([146:288, 1:145], :, :); %reorganize longitudes

compress_data = ncread([wd, lower(variable), '/', alg_prefix, tol, '/', ...
                    'b.e11.B20TRC5CNBDRD.f09_g16.030.cam.h0.', ...
                    variable, '.192001-200512.nc'], ...
                    variable);
compress_data = compress_data([146:288, 1:145], :, :); %reorganize longitudes

diff_data = ncread([wd, lower(variable), '/', alg_prefix, tol, '/', ...
                    variable, '.diff-', alg_prefix, tol, ...
                    '.nc'], variable);
diff_data = diff_data([146:288, 1:145], :, :); %reorganize longitudes

model_lat = ncread([wd, lower(variable), '/orig/', ...
                    'b.e11.B20TRC5CNBDRD.f09_g16.030.cam.h0.', ...
                    variable, '.192001-200512.nc'], ...
                    'lat');
model_lon = ncread([wd, lower(variable), '/orig/', ...
                    'b.e11.B20TRC5CNBDRD.f09_g16.030.cam.h0.', ...
                    variable, '.192001-200512.nc'], ...
                    'lon');
model_lon(model_lon > 180) = model_lon(model_lon > 180) - 360;
model_lon = [model_lon(146:288); model_lon(1:145)];


%% Compute Values
nLon = size(model_lon, 1);
nLat =  size(model_lat, 1);
obs =  size(orig_data, 3);

% Reshape from corrdinate to index
orig_mat = reshape(orig_data, nLat*nLon, []);
comp_mat = reshape(compress_data, nLat*nLon, []);
diff_mat = reshape(diff_data, nLat*nLon, []);

diff_mean = mean(diff_data, 3);
diff_sd = std(diff_data, 0, 3);
Zscore = diff_mean ./ (diff_sd/sqrt(obs));

%% Read in partition data
%ncread('zfp_boxes.nc',
%ncdisp('zfp_boxes.nc')
%ncinfo('zfp_boxes.nc')
boxPos_prep = ncread('/glade/p_old/tdd/asap/abaker_carleton/zfp_boxes.nc', 'boxPos');
boxPos = boxPos_prep([146:288, 1:145], :); %Rearrange Longitudes 
boxNum_prep = ncread('/glade/p_old/tdd/asap/abaker_carleton/zfp_boxes.nc', 'boxNum');
boxNum = boxNum_prep + 1;

boxLat = ncread('/glade/p_old/tdd/asap/abaker_carleton/zfp_boxes.nc', 'lat');
boxLon = ncread('/glade/p_old/tdd/asap/abaker_carleton/zfp_boxes.nc', 'lon');%- 178.75;
boxLon(boxLon > 180) = boxLon(boxLon > 180) - 360;
boxLon = [boxLon(146:288); boxLon(1:145)];
%% Check that lon and lats match up.
%Check that arrangement is correct

if max(boxLat ~= model_lat) == 1
   error('Latitudes do not match up.');
end
if max(boxLon ~= model_lon) == 1
   error('Longitudes do not match up.');
end

%% Box level data 
box_count = max(max(boxNum));
[lons lats obs] = size(orig_data);
boxLons = lons/4;
boxLats = lats/4;
indexes = zeros(box_count, 16);
for iBox = 1:box_count
    indexes(iBox, 1:16) = find(boxNum ==  iBox);
end

orig_box = zeros(box_count, obs);
comp_box = zeros(box_count, obs);
diff_box = zeros(box_count, obs);
for iBox = 1:box_count

        orig_box(iBox, :) = mean(orig_mat(indexes(iBox, :), :));
        comp_box(iBox, :) = mean(comp_mat(indexes(iBox, :), :));
        diff_box(iBox, :) = mean(diff_mat(indexes(iBox, :), :),);
end;

%One point per coordinate
boxes_orig = reshape(orig_box, boxLons, boxLats, obs);
box_orig_mean = mean(boxes_orig, 3);
box_orig_sd = std(boxes_orig, 0, 3);
box_orig_Zscore = box_orig_mean ./ (box_diff_sd/sqrt(obs));

boxes_comp = reshape(comp_box, boxLons, boxLats, obs);
box_comp_mean = mean(boxes_comp, 3);
box_diff_sd = std(boxes_comp, 0, 3);
box_diff_Zscore = box_comp_mean ./ (box_diff_sd/sqrt(obs));

boxes_diff = reshape(diff_box, boxLons, boxLats, obs);
box_diff_mean = mean(boxes_diff, 3);
box_diff_sd = std(boxes_diff, 0, 3);
box_diff_Zscore = box_diff_mean ./ (box_diff_sd/sqrt(obs));

%% Just diff Means

box_count = max(max(boxNum));
[lons lats obs] = size(orig_data);
boxLons = lons/4;
boxLats = lats/4;
indexes = zeros(box_count, 16);
for iBox = 1:box_count
    indexes(iBox, 1:16) = find(boxNum ==  iBox);
end


diff_box = zeros(box_count, obs);
for iBox = 1:box_count
        diff_box(iBox, :) = mean(diff_mat(indexes(iBox, :),:),1);
end;
boxes_diff = reshape(diff_box, boxLons, boxLats, obs);
box_diff_mean = mean(boxes_diff, 3);

figure(1)
axesm('robinson')
set(gca, 'LooseInset', get(gca,'TightInset'))
framem;
load coast
pcolorm([-90, 90],[-180, 180], box_diff_mean')
plotm(lat,long)
colormap(flipud(b2r(-max(max(abs(box_diff_mean))), max(max(abs(box_diff_mean))))));
C = colorbar('SouthOutside');
xlabel(C, 'Box Mean Differences','FontSize',15)
title('Mean Compression Error by Box');
save_sd_path = ['/glade/u/home/feldmann/', char(alg_prefix), char(tol), variable, 'box_mean.png'];
print(save_sd_path, '-dpng', '-r300');

%% Get Data for Correlation comparisons
select_box = 0 %Selects box of interest
boxIndexes = find(boxNum== select_box)
[lons lats] = size(diff_sd); 

corrs = zeros(lons, lats, 16);
for iLon = 1:lons
    for iLat = 1:lats
        for iBoxIndex = boxIndexes
            iIndex = sub2ind(size(diff_sd), iLon, iLat);
            [corr_values corr_lags] = xcorr(diff_mat(iIndex, :), diff_mat(iBoxIndex, :), 'coeff');
            corrs(iLon, iLat, find(boxIndexes,iBoxIndex)) = corr_values(find(corr_lags == 0));
        end;
    end;
end;



%% Plot Correlations by location


%% Cross Covariances within box Version 2
box_count = max(max(boxNum));
[lons lats obs] = size(orig_data);
indexes = zeros(box_count, 16);
indexes = zeros(box_count, 16);
for iBox = 1:box_count
    indexes(iBox, 1:16) = find(boxNum ==  iBox);
end

covariances  = zeros(16,16, box_count);
correlations  = zeros(16,16, box_count);
variances = zeros(16, box_count);
for iBox = 1:box_count
    x_means = mean(diff_mat(indexes(iBox, :), :), 2);
    x_minus_mean = diff_mat(indexes(iBox, :), :) - x_means;
    covarianceMatrix = (1/obs) .* diff_mat(indexes(iBox, :), :) * ...
                            diff_mat(indexes(iBox, :), :)';
    covariances(:,:,iBox) = covarianceMatrix;
    variances(:, iBox) = diag(covarianceMatrix);
    correlations(:,:,iBox) = covarianceMatrix/(variances(:, iBox) * variances(:,  iBox)');%check this
end

%old
%find average variance
variances = zeros(16, 1);
box_select = 1
for kPoint = 1:16
    variances(kPoint, 1, box_select) = var(diff_mat(indexes(box_select, kPoint), :));
end
mean_variance = mean(variances);
corrs = covariances/mean_variance;

%% Plot means, zscores, and sds at Box Level
figure(1)
axesm('robinson')
set(gca, 'LooseInset', get(gca,'TightInset'))
framem;
load coast
pcolorm([-90, 90],[-180, 180], box_diff_mean')
plotm(lat,long)
colormap(flipud(b2r(-max(max(abs(box_diff_mean))), max(max(abs(box_diff_mean))))));
C = colorbar('SouthOutside');
xlabel(C, 'Box Mean Differences','FontSize',15)
title('Mean Compression Error by Box');
save_sd_path = ['/glade/u/home/feldmann/', char(alg_prefix), char(tol), variable, 'box_mean.png'];
%print(save_sd_path, '-dpng');


figure(2)
axesm('robinson')
set(gca, 'LooseInset', get(gca,'TightInset'))
framem;
load coast
pcolorm([-90 90],[-180,180], box_diff_Zscore')
plotm(lat,long)
colormap(flipud(b2r(-max(max(box_diff_Zscore')), max(max(box_diff_Zscore')))));
C = colorbar('SouthOutside');
xlabel(C,'Box Zscores','FontSize',15);
title('Mean Zscore of Errors by Box');
save_sd_path = ['/glade/u/home/feldmann/', char(alg_prefix), char(tol), variable, 'box_Zscore.png'];
%print(save_sd_path, '-dpng');


figure(3)
axesm('robinson')
set(gca, 'LooseInset', get(gca,'TightInset'))
framem;
load coast
pcolorm([-90 90],[-180,180], box_diff_sd')
plotm(lat,long)
colormap(w2k(0, max(max(box_diff_sd))));
C = colorbar('SouthOutside');
xlabel(C, 'Box Standard Deviations','FontSize',15);
title('Standard Deviations by Box');
save_sd_path = ['/glade/u/home/feldmann/', char(alg_prefix), char(tol), variable, 'box_sd.png'];
%print(save_sd_path, '-dpng');

%% Find points for time series
bdz = box_diff_Zscore
minLat = -30;
maxLat = 30;
minLon = -150;
maxLon = -100;

figure(1)
axesm('robinson', 'MapLatLimit', [minLat maxLat], 'MapLonLimit', [minLon maxLon]) % Window in on a specific region
set(gca, 'LooseInset', get(gca,'TightInset'))
framem;
load coast
pcolorm([-90, 90],[-180, 180], bdz')
plotm(lat,long)
colormap(flipud(b2r(-max(max(abs(bdz))), max(max(abs(bdz))))));
C = colorbar('SouthOutside');
xlabel(C, 'Box Zscores','FontSize',15)
title('Mean Compression Error by Box');

% Negative in Stripe, value -42.2665, position 1898
% Positive in Stripe, value 5.5478, position 1813
% West of Stripe, value -17.8792, position 1809

%% plots 3 time series at box level
figure(2)
plot(orig_box(1898, 1:90), 'b');
hold on
plot(comp_box(1898, 1:90), 'r');
title('Negative in Stripe');
save_sd_path = ['/glade/u/home/feldmann/', char(tol), 'box_redStripe.png'];
print(save_sd_path, '-dpng');

figure(3)
plot(orig_box(1813, 1:90), 'b');
hold on
plot(comp_box(1813, 1:90), 'r');
title('Positive in Stripe');
save_sd_path = ['/glade/u/home/feldmann/', char(tol), 'box_blueStripe.png'];
print(save_sd_path, '-dpng');

figure(4)
plot(orig_box(1809, 1:90), 'b');
hold on
plot(comp_box(1809, 1:90), 'r');
title('Outside of Stripes');
save_sd_path = ['/glade/u/home/feldmann/', char(tol), 'box_pinkStripe.png'];
print(save_sd_path, '-dpng');

figure(6)
plot(diff_box(1898, 1:90), 'r');
hold on
plot(diff_box(1813, 1:90), 'b');
hold on
plot(diff_box(1809, 1:90), 'k');
title('Time Series of Differences for 3 Points');
save_sd_path = ['/glade/u/home/feldmann/', char(tol), 'box_comparison.png'];
print(save_sd_path, '-dpng');

%% Deseasonalize time series at box level

%For Each point, finds averages for each month
monthAverages = zeros(box_count, 12);
for iCorr = 1:box_count
    for iMonth = 1:12
        obsInd = iMonth:12:obs;
        monthAverages(iCorr, iMonth) = mean(orig_box(iCorr, obsInd));
        orig_box_deseason(iCorr, obsInd) = orig_box(iCorr, obsInd) - monthAverages(iCorr, iMonth);
        comp_box_deseason(iCorr, obsInd) = comp_box(iCorr, obsInd) - monthAverages(iCorr, iMonth);    
    end
end

figure(2)
%Red
plot(orig_box_deseason(1898, 1:90), 'b');
hold on
plot(comp_box_deseason(1898, 1:90), 'r');
title('Negative in Stripe');
save_sd_path = ['/glade/u/home/feldmann/', char(tol), 'box_deseasoned_redStripe.png'];
print(save_sd_path, '-dpng');

figure(3)
%Blue
plot(orig_box_deseason(1813, 1:90), 'b');
hold on
plot(comp_box_deseason(1813, 1:90), 'r');
title('Positive in Stripe');
save_sd_path = ['/glade/u/home/feldmann/', char(tol), 'box_deseasoned_blueStripe.png'];
print(save_sd_path, '-dpng');

figure(4)
%Pink
plot(orig_box_deseason(1809, 1:90), 'b');
hold on
plot(comp_box_deseason(1809, 1:90), 'r');
title('Outside of Stripes');
save_sd_path = ['/glade/u/home/feldmann/', char(tol), 'box_deseasoned_pinkStripe.png'];
print(save_sd_path, '-dpng');

figure(5)
%Compare Differences
plot(orig_box_deseason(1898, 1:90) - comp_box_deseason(1898, 1:90), 'r');
hold on
plot(orig_box_deseason(1813, 1:90) - comp_box_deseason(1813, 1:90), 'b');
hold on
plot(orig_box_deseason(1809, 1:90) - comp_box_deseason(1809, 1:90), 'k');
title('Time Series of Differences for 3 Points');
save_sd_path = ['/glade/u/home/feldmann/', char(tol), 'box_deseasoned_Comparison.png'];
print(save_sd_path, '-dpng');


%cross correlation matrices for those 3 points
%Autocorrelations
% In Box Correlation
