% Creates a 4x2 plot of the lag-1 correlations of the first differances of
% the deseasonalized TS values for the technote. At the top is the original
% data, on the left is the sz algorithm, and on the right is the zfp
% algorithm. Tolerance levels of 1.0, 0.5, 0.1, and 0.01 are included from
% top to bottom. 

clear *

addpath('/glade/u/home/apoppick/MATLABPackages/b2r');
addpath('/glade/u/home/apoppick/MATLABPackages/subaxis');
addpath('/glade/u/home/apoppick/MATLABPackages/freezeColors');
addpath('/glade/u/home/apoppick/MATLABPackages/cm_and_cb_utilities');

wd = '/glade/p_old/tdd/asap/abaker_carleton/';
variable = 'TS';
alg_prefix_list = {'szAOn', 'zfpATOL'};
% %Not doing 1e-5 for zfp because zscores are all zero
% tol_list_zfp = {'1.0', '0.5', '1e-1', '1e-2', '1e-3'};
% %Not doing 0.0001 and 1e-05 because zscores are all zero
% tol_list_sz = {'1.0', '0.5', '0.1', '0.01', '0.001'};

tol_list_zfp = {'1.0', '0.5', '1e-1', '1e-2'};
tol_list_sz = {'1.0', '0.5', '0.1', '0.01'};

%% Read in original data
orig_data_path = [wd, lower(variable), '/orig/', 'b.e11.B20TRC5CNBDRD.f09_g16.030.cam.h1.', variable, '.19200101-20051231.nc'];
orig_data = ncread(orig_data_path, variable);
orig_data = orig_data([146:288, 1:145], :, :); %reorganize longitudes
model_lat = ncread(orig_data_path,'lat');
model_lon = ncread(orig_data_path,'lon');
model_lon(model_lon > 180) = model_lon(model_lon > 180) - 360;
model_lon = [model_lon(146:288); model_lon(1:145)];
nLon = size(model_lon, 1);
nLat =  size(model_lat, 1);
N =  size(orig_data, 3);

orig_data_deseas = reshape(orig_data, nLon, nLat, 365, N/365) - mean(reshape(orig_data, nLon, nLat, 365, N/365), 4);
orig_data_deseas = reshape(orig_data_deseas, nLon, nLat, N);
difforig_data_deseas = orig_data_deseas(:, :, 2:end) - orig_data_deseas(:, :, 1:(end-1));
ar1_orig = sum(difforig_data_deseas(:, :, 2:end) .* difforig_data_deseas(:, :, 1:(end-1)), 3) ./ ...
    sum(difforig_data_deseas.^2,3);

ax_orig = subaxis(length(tol_list_zfp)+1,1,1,1, 'Spacing', 0, 'SpacingHoriz' , 0 , 'SpacingVert' , 0 , ... 
            'Padding', 0, 'PaddingRight', 0, 'PaddingLeft', 0 , 'PaddingTop', 0 , 'PaddingBottom', 0 , ... 
            'Margin', 0 , 'MarginRight', 0.1, 'MarginLeft', 0.1 , 'MarginTop', 0.1 , 'MarginBottom', 0);
        
axesm('robinson');
set(gca, 'LooseInset', get(gca,'TightInset'));
framem; tightmap;
load coast;
pcolorm([-90 90],[-180,180], ar1_orig');
plotm(lat,long, 'k');
cbar_max(1) = max(abs(ar1_orig(:)));
colormap(flipud(b2r(-cbar_max(1), cbar_max(1))));
C2 = colorbar('southoutside', 'FontSize', 5);
text(-2.5, 2.2, 'Original');

%% Make maps of annual power for each compression level/algorithm

cbar_max = zeros(length(tol_list_zfp),length(alg_prefix_list));
for alg_i = 1:length(alg_prefix_list)
    alg_prefix = alg_prefix_list{alg_i};
    if strcmp(alg_prefix, 'zfpATOL') 
        tol_list = tol_list_zfp;
        compress_alg = 'zfp';
    else
        tol_list = tol_list_sz;
        compress_alg = 'sz';
    end
    for tol_j=1:length(tol_list)
        tol = tol_list{tol_j};
                
        compress_data_path = [wd, lower(variable), '/',...
            char(alg_prefix), char(tol), '/', 'b.e11.B20TRC5CNBDRD.f09_g16.030.cam.h1.', variable, '.19200101-20051231.nc'];
        
        compress_data = ncread(compress_data_path, variable);
        compress_data = compress_data([146:288, 1:145], :, :); %reorganize longitudes
        
        compress_data_deseas = reshape(compress_data, nLon, nLat, 365, N/365) - mean(reshape(compress_data, nLon, nLat, 365, N/365), 4);
        compress_data_deseas = reshape(compress_data_deseas, nLon, nLat, N);
        diffcompress_data_deseas = compress_data_deseas(:, :, 2:end) - compress_data_deseas(:, :, 1:(end-1));
        ar1_compress = sum(diffcompress_data_deseas(:, :, 2:end) .* diffcompress_data_deseas(:, :, 1:(end-1)), 3) ./ ...
            sum(diffcompress_data_deseas.^2,3);
        
        ax(tol_j,alg_i) = subaxis(length(tol_list_zfp)+1,2,alg_i,tol_j+1, 'Spacing', 0, 'SpacingHoriz' , 0 , 'SpacingVert' , 0 , ... 
            'Padding', 0, 'PaddingRight', 0, 'PaddingLeft', 0 , 'PaddingTop', 0 , 'PaddingBottom', 0 , ... 
            'Margin', 0 , 'MarginRight', 0.1, 'MarginLeft', 0.1 , 'MarginTop', 0.1 , 'MarginBottom', 0);
        axesm('robinson');
        set(gca, 'LooseInset', get(gca,'TightInset'));
        framem; tightmap;
        load coast;
        pcolorm([-90 90],[-180,180], ar1_compress');
        plotm(lat,long, 'k');
        cbar_max(tol_j,alg_i) = max(abs(ar1_compress(:)));
        colormap(ax(tol_j,alg_i), flipud(b2r(-cbar_max(tol_j,alg_i), cbar_max(tol_j,alg_i))));
        colorbar('southoutside', 'FontSize', 5);
        
        
        if strcmp(alg_prefix, 'szAOn')
            text(-4, 0, char(tol));
        end
        if (strcmp(alg_prefix, 'szAOn')) && (strcmp(tol, '1.0'))
            text(0, 2, compress_alg);
        end
        if (strcmp(alg_prefix, 'zfpATOL')) && (strcmp(tol, '1.0'))
            text(0, 2, compress_alg);
            %text(-5,3, 'log10(Amplitude of Annual Harmonic / Avg Periodogram in Neighborhood)', 'FontWeight', 'bold', 'FontSize', 10)
        end
        disp([alg_prefix, tol_list{tol_j}])
    end
end

cbar_lim = max(cbar_max,[],2);

for k=1:length(alg_prefix_list)
    for m=1:length(tol_list)
        set(ax(m,k), 'CLim', [-cbar_lim(m), cbar_lim(m)]);
    end
end

set(gcf,'Units', 'inches', 'Position', [0 0 4 7], 'PaperUnits','inches','PaperPosition', [0 0 4 7]) 
save_path = '/glade/work/apoppick/compress_plots/TS_corr/Corr_PlotArray_TS.png';
print(save_path, '-dpng', '-r300')


close