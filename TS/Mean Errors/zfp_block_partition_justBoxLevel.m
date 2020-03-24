% Plots differences caused by zfp at the box level.

function[] = zfp_block_partition_justBoxLevel(orig_data, diff_data, compress_data, diff_data_name, obs, model_lat, model_lon, nLat, nLon, variable, save_dir)


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
boxPos_prep = ncread('/glade/p/cisl/iowa/abaker_carleton/zfp_boxes.nc', 'boxPos');
boxPos = boxPos_prep([146:288, 1:145], :); %Rearrange Longitudes 
boxNum_prep = ncread('/glade/p/cisl/iowa/abaker_carleton/zfp_boxes.nc', 'boxNum');
boxNum = boxNum_prep + 1;

boxLat = ncread('/glade/p/cisl/iowa/abaker_carleton/zfp_boxes.nc', 'lat');
boxLon = ncread('/glade/p/cisl/iowa/abaker_carleton/zfp_boxes.nc', 'lon');%- 178.75;
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
end
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
xlabel(C, 'Mean Error','FontSize',15)
save_sd_path = [save_dir, diff_data_name, variable, 'partition_mean_errors.png'];
print(save_sd_path, '-dpng', '-r300');
close

%% Get Data for Correlation comparisons
%select_box = 1 %Selects box of interest
%boxIndexes = find(boxNum== select_box)
%[lons lats] = size(diff_sd); 

%corrs = zeros(lons, lats, 16);
%for iLon = 1:lons
%    for iLat = 1:lats
%        for iBoxIndex = boxIndexes
%            iIndex = sub2ind(size(diff_sd), iLon, iLat);
%            [corr_values corr_lags] = xcorr(diff_mat(iIndex, :), diff_mat(iBoxIndex, :), 'coeff');
%            corrs(iLon, iLat, find(boxIndexes,iBoxIndex)) = corr_values(find(corr_lags == 0));
%        end
%    end
%end


end