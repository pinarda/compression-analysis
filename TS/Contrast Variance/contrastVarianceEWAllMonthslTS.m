% This code plots EW Contrast Variances and gives the ratio of the pooled
% variance to the pooled variance of the original data. Plots for each month (roughly).

clear *

addpath('/gpfs/u/home/apoppick/MATLABPackages/b2r');
addpath('/gpfs/u/home/apoppick/MATLABPackages/subaxis');
%/glade/p/cisl/iowa/abaker_carleton/

data_dir = '/glade/p/cisl/iowa/abaker_carleton/';
save_dir = '/gpfs/u/home/feldmann/';
variable = 'TS';
alg_prefix_list = {'szAOn', 'zfpATOL'};
%Not doing 1e-5 for zfp because zscores are all zero
tol_list_zfp = {'1.0', '0.5', '1e-1', '1e-2'};
%Not doing 0.0001 and 1e-05 because zscores are all zero
tol_list_sz = {'1.0', '0.5', '0.1', '0.01'};

%%Load Land Fractions
load /glade/u/home/apoppick/landfrac.mat
landfrac = landfrac([146:288, 1:145], :);
land = round((landfrac(2:end, :) + landfrac(1:end - 1, :))./2);
sea = (land * -1) + 1;
landPerc = mean(mean(land));
seaPerc = mean(mean(sea));

%% Original Data
% Original Data
monStarts = [1 32 60 91 121 152 182 213 244 274 305 336];
for month = 1:12
    figure(month)
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

    monFirsts = monStarts(month):365:obs;
    monObs = zeros(length(monFirsts), 30);
    for iDay = 1:30
       monObs(:, iDay) = monFirsts + iDay - 1; 
    end
    monObs = sort(reshape(monObs, length(monFirsts)*30, []));
    orig_mon = orig_data(:,:, monObs);

    %Find Contrast Variance Data: Lon, Lat, observation
    diff_sq = zeros(nLon-1, nLat, length(orig_mon));
    log_con_var = zeros(nLon-1, nLat);
    diff_sq(:, :, :) =  (orig_mon(2:end, :, :) - orig_mon(1:end - 1, :, :)).^2;
    log_con_var(:, :) =  log10(mean(diff_sq, 3));

    ax_orig = subaxis(length(tol_list_zfp)+1,length(alg_prefix_list),1.5,1, 'Spacing', 0, 'SpacingHoriz' , 0 , 'SpacingVert' , 0 , ... 
                'Padding', 0, 'PaddingRight', 0, 'PaddingLeft', .05 , 'PaddingTop', 0.01 , 'PaddingBottom', 0 , ... 
                'Margin', 0 , 'MarginRight', 0.03, 'MarginLeft', 0.1 , 'MarginTop', 0.1 , 'MarginBottom', 0.0);

    axesm('robinson');
    set(gca, 'LooseInset', get(gca,'TightInset'));
    framem; tightmap;
    load coast;
    pcolorm([-90 90],[-180,180], log_con_var');
    plotm(lat,long, 'k');
    cbar_max(1) = prctile(log_con_var(:), 95);
    colormap(flipud(w2k_new(-cbar_max(1), cbar_max(1))));
    %colormap(flipud('gray'))
    %caxis([-cbar_max_orig, cbar_max_orig])
    C2 = colorbar('southoutside', 'FontSize', 5);
    text(-2.5, 2.2, 'Original');
    meanVarianceOrig = mean(mean(mean(diff_sq, 3),2),1);
    landVarianceOrig = mean(mean(mean(diff_sq, 3) .* land)) / landPerc;
    seaVarianceOrig =mean(mean(mean(diff_sq, 3) .* sea)) / seaPerc;
    text(-3.1,1.6, ['Mean:', num2str(meanVarianceOrig, 4), ...
                    ' (Land:', num2str(landVarianceOrig, 4),  ...
                    ' Sea:', num2str(seaVarianceOrig, 4), ')'], 'FontSize', 7);

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
            comp_mon = compress_data(:,:, monObs);

            %Find Contrast Variance Data: Lon, Lat, observation

            diff_sq(:, :, :) =  (comp_mon(2:end, :, :) - comp_mon(1:end - 1, :, :)).^2; 
            log_con_var(:, :, :) =  log10(mean(diff_sq, 3));


            ax(j,i) = subaxis(length(tol_list_zfp)+1,length(alg_prefix_list),i,j+1, 'Spacing', 0, 'SpacingHoriz' , 0 , 'SpacingVert' , 0 , ... 
                'Padding', 0, 'PaddingRight', 0, 'PaddingLeft', .05 , 'PaddingTop', 0.01 , 'PaddingBottom', 0 , ... 
                'Margin', 0 , 'MarginRight', 0.03, 'MarginLeft', 0.1 , 'MarginTop', 0.1 , 'MarginBottom', 0.0);
            axesm('robinson');
            set(gca, 'LooseInset', get(gca,'TightInset'));
            framem; tightmap;
            load coast;
            pcolorm([-90 90],[-180,180], log_con_var');
            plotm(lat,long, 'k');
            cbar_max(j+i*5) = prctile(abs(log_con_var(:)), 95);
            colormap(ax(j,i), flipud(w2k_new(-cbar_max(j+i*5), cbar_max(j+i*5))));

            meanVariance = mean(mean(mean(diff_sq, 3),2),1);
            varRatio = meanVariance/meanVarianceOrig;
            landVariance = mean(mean(mean(diff_sq, 3) .* land)) / landPerc;
            landRatio = landVariance/landVarianceOrig;        
            seaVariance = mean(mean(mean(diff_sq, 3) .* sea)) / seaPerc;
            seaRatio = seaVariance/seaVarianceOrig;
            text(-3.1,1.6, ['Ratio:', num2str(varRatio, 4), ...
                    ' (Land:', num2str(landRatio, 4),  ...
                    ' Sea:', num2str(seaRatio, 4), ')'], 'FontSize', 7);
            %colormap(flipud('gray'))
            %caxis([-cbar_max(j,i), cbar_max(j,i)])
            C2 = colorbar('southoutside', 'FontSize', 5);
            if strcmp(alg_prefix, 'szAOn')
                text(-4.5, 0, char(tol));
            end
            if (strcmp(tol, '1.0'))
                text(0, 2.5, compress_alg);
            end
        end
    end

    cbar_lim = max(cbar_max);
    set(ax_orig, 'CLim', [-cbar_lim, cbar_lim]);
    for k=1:length(alg_prefix_list)
        for m=1:length(tol_list)
            set(ax(m,k), 'CLim', [-cbar_lim, cbar_lim]);
        end
    end

    save_path = ['/glade/u/home/feldmann/ContrastVarianceEWTS', num2str(month),'.png'];
    print(save_path, '-dpng', '-r300')
    close
end

        