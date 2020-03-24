% Creates a plot of the amplitudes of the error annual harmonic
% relative to the 50 frequencies around the 50 frequencies around the
% annual frequency for TS errors. This plot looks at the lower error 
% tolenaces. On the left is sz and on the right is zfp. Error tolerances 
% of 1e-3 and 1e-4 for zfp and 1e-3 for sz are included in the plot. 
% Locations marked as significant are marked with a dot and the percent of 
% points that are significant are given in the title of each graph.

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

tol_list_zfp = {'1e-3', '1e-4'};
tol_list_sz = {'0.001'};

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
        
        diff_data_path = [wd, lower(variable), '/', char(alg_prefix), char(tol), '/', variable, '.diff-', char(alg_prefix), char(tol), '.nc'];
        diff_data = ncread(diff_data_path, variable);
        diff_data = diff_data([146:288, 1:145], :, :); %reorganize longitudes
        
        diff_mat = reshape(diff_data, nLat*nLon, []); % each row is  a time series
        diff_demean = bsxfun(@minus, diff_mat, mean(diff_mat,2)); % subtract mean
        
        DF_diff = fft(diff_demean,[],2); %FFT of every row
        DF_annual_diff = DF_diff(:, N/365 + 1);
        %S_annual_diff = real(DF_annual_diff.*conj(DF_annual_diff)./N); % annual power
        S_diff = real(DF_diff.*conj(DF_diff)./N);
        S_annual_diff = S_diff(:, N/365 + 1); % annual power
        S_mean_diff = mean(S_diff(:, [(N/365+1-25):(N/365), (N/365+2):(N/365+1+25)]),2);
        
        S_an_mat_diff = reshape(S_annual_diff, nLon, nLat); %reshape back to lon lat
        S_mean_mat_diff = reshape(S_mean_diff, nLon, nLat); %reshape back to lon lat
        logratio_diff = log10(S_an_mat_diff./S_mean_mat_diff);
        
        pvals = 1 - fcdf(10.^logratio_diff, 2, 100);
        sorted_pvals = sort(pvals(:));
        sig_cutoff = finv(1-sorted_pvals(find(sorted_pvals <= 0.01 * (1:(nLat*nLon))'/(nLat*nLon), 1, 'last')), 2, 50);
        [mapSigLon, mapSigLat]=find(10.^logratio_diff > sig_cutoff);
        
        ax(tol_j,alg_i) = subaxis(length(tol_list),length(alg_prefix_list),alg_i,tol_j, 'Spacing', 0, 'SpacingHoriz' , 0 , 'SpacingVert' , 0 , ... 
            'Padding', 0, 'PaddingRight', 0, 'PaddingLeft', 0 , 'PaddingTop', 0 , 'PaddingBottom', 0 , ... 
            'Margin', 0 , 'MarginRight', 0.1, 'MarginLeft', 0.1 , 'MarginTop', 0.1 , 'MarginBottom', 0.02);
        axesm('robinson');
        set(gca, 'LooseInset', get(gca,'TightInset'));
        framem; tightmap;
        load coast;
        pcolorm([-90 90],[-180,180],logratio_diff')
        plotm(model_lat(mapSigLat),model_lon(mapSigLon),'.', 'Color', [0.5 0.5 0.5], 'MarkerSize', 0.005);
        plotm(lat,long, 'k');
        cbar_max(tol_j,alg_i) = prctile(abs(logratio_diff(:)), 99);
        %cbar_max(tol_j,alg_i) = max(abs(logratio_diff(:)));
        colormap(ax(tol_j,alg_i), flipud(b2r(-cbar_max(tol_j,alg_i), cbar_max(tol_j,alg_i))));
        C2 = colorbar('southoutside', 'FontSize', 5);
        title([num2str(round(100 * mean(10.^logratio_diff(:) > sig_cutoff),1)), ...
                '% significant'], 'FontSize', 7)
        
        if strcmp(alg_prefix, 'szAOn')
            text(-4.5, 0, char(tol));
        end
        if (strcmp(alg_prefix, 'szAOn')) && (strcmp(tol, '1.0'))
            text(0, 2.5, compress_alg);
        end
        if (strcmp(alg_prefix, 'zfpATOL')) && (strcmp(tol, '1.0'))
            text(0, 2.5, compress_alg);
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

save_path = '/glade/work/apoppick/compress_plots/TSMX_seas/Seas_PlotArray_daily_OtherTols.png';
print(save_path, '-dpng', '-r300')
close

% do for a few locations:
% 1. plot periodogram of residuals
%         
% 2. plot mean seasonal cycle
% 
% 3. Plot annual cycle of residuals
