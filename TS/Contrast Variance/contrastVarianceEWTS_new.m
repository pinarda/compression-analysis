% This code plots EW Contrast Variances and gives the ratio of the pooled
% variance to the pooled variance of the original data.
function[] = contrastVarianceEWTS_new(orig_data, compressed_datas, alg_prefix_list, tol_list_sz, tol_list_zfp, nLat, nLon, obs, save_dir, days, mo_length)

    %%Load Land Fractions
    load /glade/u/home/apoppick/landfrac.mat
    landfrac = landfrac([146:288, 1:145], :);
    land = round((landfrac(2:end, :) + landfrac(1:end - 1, :))./2);
    sea = (land * -1) + 1;
    landPerc = mean(mean(land));
    seaPerc = mean(mean(sea));

    %% Original Data
    % Original Data

    janFirsts = days:365:obs;
    janObs = zeros(length(janFirsts), mo_length);
    for iDay = 1:mo_length
       janObs(:, iDay) = janFirsts + iDay - 1; 
    end
    janObs = sort(reshape(janObs, length(janFirsts)*mo_length, []));
    orig_jan = orig_data(:,:, janObs);

    %Find Contrast Variance Data: Lon, Lat, observation
    diff_sq = zeros(nLon-1, nLat, length(janObs));
    log_con_var = zeros(nLon-1, nLat);
    diff_sq(:, :, :) =  (orig_jan(2:end, :, :) - orig_jan(1:end - 1, :, :)).^2;
    log_con_var(:, :) =  log10(mean(diff_sq, 3));

    %figure(1)
    set(gcf,'Units', 'inches', 'Position', [0 0 4 6], 'PaperUnits','inches','PaperPosition', [0 0 4 6]) 

    ax_orig = subaxis(length(tol_list_zfp)+1,length(alg_prefix_list),1.5,1, 'Spacing', 0, 'SpacingHoriz' , 0 , 'SpacingVert' , 0 , ... 
                'Padding', 0, 'PaddingRight', 0, 'PaddingLeft', .05 , 'PaddingTop', 0.01 , 'PaddingBottom', 0 , ... 
                'Margin', 0 , 'MarginRight', 0.03, 'MarginLeft', 0.1 , 'MarginTop', 0.1 , 'MarginBottom', 0.0, 'Holdaxis', 1);

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
    %C2 = colorbar('southoutside', 'FontSize', 5);
    text(-1.5, 2.2, 'Original');
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
        elseif strcmp(alg_prefix, 'beta_zfpATOL')
            tol_list = tol_list_zfp;
            compress_alg = 'zfp beta';
        elseif strcmp(alg_prefix, 'round_zfpATOL')
            tol_list = tol_list_zfp;
            compress_alg = 'zfp rounding';
        else
            tol_list = tol_list_sz;
            compress_alg = 'sz';
        end
    % Loop By Tolerance
        for j=1:length(tol_list)
            tol = tol_list{j};
    % Compressed Data
            compress_data = compressed_datas(strcat(alg_prefix, tol));
            comp_jan = compress_data(:,:, janObs);

            %Find Contrast Variance Data: Lon, Lat, observation

            diff_sq(:, :, :) =  (comp_jan(2:end, :, :) - comp_jan(1:end - 1, :, :)).^2; 
            log_con_var(:, :, :) =  log10(mean(diff_sq, 3));


            ax(j,i) = subaxis(length(tol_list_zfp)+1,length(alg_prefix_list),i,j+1, 'Spacing', 0, 'SpacingHoriz' , 0 , 'SpacingVert' , 0 , ... 
                'Padding', 0, 'PaddingRight', 0, 'PaddingLeft', .05 , 'PaddingTop', 0.01 , 'PaddingBottom', 0 , ... 
                'Margin', 0 , 'MarginRight', 0.03, 'MarginLeft', 0.1 , 'MarginTop', 0.1 , 'MarginBottom', 0.025, 'HoldAxis', 1);
            axesm('robinson');
            set(gca, 'LooseInset', get(gca,'TightInset'));
            framem; tightmap;
            load coast;
            pcolorm([-90 90],[-180,180], log_con_var');
            plotm(lat,long, 'k');
            cbar_max(j+i*5) = prctile(abs(log_con_var(:)), 80);
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
            if j == length(tol_list)
                originalSize = get(gca, 'Position');
                C2 = colorbar('southoutside', 'FontSize', 5);
                set(gca, 'Position', originalSize);
            end
            if strcmp(alg_prefix, string(alg_prefix_list(1)))
                text(-4, 0, char(tol));
            end
            if strcmp(tol, char(tol_list(1)))
                text(0, 2, compress_alg);
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

    %set(gcf,'Units', 'inches', 'Position', [0 0 5 6], 'PaperUnits','inches','PaperPosition', [0 0 5 6])
    if strcmp('1.0', string(tol_list_zfp(1)))
        save_path = [save_dir, 'ContrastVarianceEWTS_new', num2str(days),'.png'];
    else
        save_path = [save_dir, 'ContrastVarianceEWTS_new', '_tight_tolerance', char(days), '.png'];
    end
    print(save_path, '-dpng', '-r300')
    close
end
