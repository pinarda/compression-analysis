% This code plots NS gradient fields.

clear *

addpath('/gpfs/u/home/apoppick/MATLABPackages/b2r');
addpath('/gpfs/u/home/apoppick/MATLABPackages/subaxis');

data_dir = '/glade/p/cisl/iowa/abaker_carleton/';
save_dir = '/gpfs/u/home/feldmann/';
variable = 'TS';
alg_prefix_list = {'szAOn', 'zfpATOL'};
%Not doing 1e-5 for zfp because zscores are all zero
tol_list_zfp = {'1.0', '0.5', '1e-1', '1e-2'};
%Not doing 0.0001 and 1e-05 because zscores are all zero
tol_list_sz = {'1.0', '0.5', '0.1', '0.01'};

%% Original Data
% Original Data
figure(1)
set(gcf,'Units', 'inches', 'Position', [0 0 4 8], 'PaperUnits','inches','PaperPosition', [0 0 4 8]) 
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
model_lat = ncread(orig_data_path,'lat');
model_lon = ncread(orig_data_path,'lon');
model_lon(model_lon > 180) = model_lon(model_lon > 180) - 360;
model_lon = [model_lon(146:288); model_lon(1:145)];
nLon = size(model_lon, 1);
nLat =  size(model_lat, 1);
obs =  size(orig_data, 3);

janFirsts = 1:365:obs;
janObs = zeros(length(janFirsts), 30);
for iDay = 1:30
   janObs(:, iDay) = janFirsts + iDay - 1; 
end
janObs = sort(reshape(janObs, length(janFirsts)*30, []));
orig_jan = orig_data(:,:, janObs);

%Find Gradient Data: Lon, Lat, observation
grad_lat = zeros(nLon, nLat-1, length(orig_jan));
grad_lat(:, :, :) =  orig_jan(:, 2:end, :) - orig_jan(:, 1:end - 1, :);
mean_grad_lat = mean(grad_lat, 3);

subaxis(length(tol_list_zfp)+1,length(alg_prefix_list),1,1, 'Spacing', 0, 'SpacingHoriz' , 0 , 'SpacingVert' , 0 , ... 
            'Padding', 0, 'PaddingRight', 0, 'PaddingLeft', .05 , 'PaddingTop', 0.01 , 'PaddingBottom', 0 , ... 
            'Margin', 0 , 'MarginRight', 0.02, 'MarginLeft', 0.3 , 'MarginTop', 0.1 , 'MarginBottom', 0.0);
axesm('robinson');
set(gca, 'LooseInset', get(gca,'TightInset'));
framem; tightmap;
load coast;
pcolorm([-90 90],[-180,180], mean_grad_lat');
plotm(lat,long, 'k');
cbar_max_orig = prctile(mean_grad_lat(:), 95);
cbar_min_orig = prctile(mean_grad_lat(:), 5);
colormap(flipud(b2r(cbar_min_orig, cbar_max_orig)));
C2 = colorbar('southoutside', 'FontSize', 5);
text(-2.5, 2, 'Original');
text(-7,3.5, ['Mean Gradient of ', char(variable), ' Across Latitudes'], 'FontWeight', 'bold', 'FontSize', 10);

% Loop By Algorithm
for i=1:length(alg_prefix_list)
    alg_prefix = alg_prefix_list{i};
    if strcmp(alg_prefix, 'zfpATOL') 
        tol_list = tol_list_zfp;
        compress_alg = 'zfp';
    else
        tol_list = tol_list_sz;
        compress_alg = 'sz';
    end
% Loop By Tolerance
    for j=1:length(tol_list)
        tol = tol_list{j};
% Compressed Data
        if strcmp(variable, 'TSMX')
            compress_data_path = [data_dir, lower(variable), '/',...
                char(alg_prefix), char(tol), '/', 'b.e11.B20TRC5CNBDRD.f09_g16.030.cam.h0.', variable, '.192001-200512.nc'];
        end
        if strcmp(variable, 'TS')
           compress_data_path = [data_dir, lower(variable), '/',...
                char(alg_prefix), char(tol), '/', 'b.e11.B20TRC5CNBDRD.f09_g16.030.cam.h1.', variable, '.19200101-20051231.nc'];
        end
        compress_data = ncread(compress_data_path, variable);
        compress_data = compress_data([146:288, 1:145], :, :); %reorganize longitudes
        
        compress_jan = compress_data(:,:, janObs);
        grad_lat =  compress_jan(:, 2:end, :) - compress_jan(:, 1:end - 1, :);
        mean_grad_lat = mean(grad_lat, 3);

        ax(j,i) = subaxis(length(tol_list_zfp)+1,length(alg_prefix_list),i,j+1, 'Spacing', 0, 'SpacingHoriz' , 0 , 'SpacingVert' , 0 , ... 
            'Padding', 0, 'PaddingRight', 0, 'PaddingLeft', .05 , 'PaddingTop', 0.01 , 'PaddingBottom', 0 , ... 
            'Margin', 0 , 'MarginRight', 0.03, 'MarginLeft', 0.1 , 'MarginTop', 0.1 , 'MarginBottom', 0.0);
        axesm('robinson');
        set(gca, 'LooseInset', get(gca,'TightInset'));
        framem; tightmap;
        load coast;
        pcolorm([-90 90],[-180,180], mean_grad_lat');
        plotm(lat,long, 'k');
        cbar_max(j,i) = prctile(mean_grad_lat(:), 95)
        colormap(ax(j,i), flipud(b2r(-cbar_max(j,i), cbar_max(j,i))));
        C2 = colorbar('southoutside', 'FontSize', 5);
        if strcmp(alg_prefix, 'szAOn')
            text(-4.5, 0, char(tol));
        end
        if (strcmp(tol, '1.0'))
            text(0, 2.5, compress_alg);
        end
    end
end

cbar_lim = max(cbar_max,[],2);

for k=1:length(alg_prefix_list)
    for m=1:length(tol_list)
        set(ax(m,k), 'CLim', [-cbar_lim(m), cbar_lim(m)]);
    end
end

save_path = ['/glade/u/home/feldmann/GradientLatTS.png'];
print(save_path, '-dpng', '-r300')

        