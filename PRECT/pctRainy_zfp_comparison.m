%Plots the probability of rain by day of year, globally and across years
function[] = pctRainy(orig_data, compress_datas, alg_prefix_list, N, save_dir)

    tol_list_zfp = {'1e-2', '1e-5', '1e-8', '1e-11', '0'};
    %Not doing 0.0001 and 1e-05 because zscores are all zero
    tol_list_sz = {'0.01', '1e-05', '1e-08', '1e-11'};
    
    %TEST
    %tol_list_zfp = {'1e-2'};
    %Not doing 0.0001 and 1e-05 because zscores are all zero
    %tol_list_sz = {'0.1'};
    
    %% Calculate Statistics for Original Data

    rainDays_orig = (orig_data > 0);
    pctRainy_orig = squeeze(mean(mean(rainDays_orig,1),2));
    pctRainy_zfp_beta = zeros(N, length(tol_list_zfp));
    pctRainy_zfp = zeros(N, length(tol_list_zfp));
    for alg_i = 1:2
        alg_prefix = alg_prefix_list{alg_i};
        if strcmp(alg_prefix, 'zfpATOL') 
            tol_list = tol_list_zfp;
            compress_alg = 'zfp';
        elseif strcmp(alg_prefix, 'beta_zfpATOL')
            tol_list = tol_list_zfp;
            compress_alg = 'zfp beta';
        else
            tol_list = tol_list_sz;
            compress_alg = 'sz';
        end
        for tol_j = 1:length(tol_list) %non-lossless tolerances
            tol = tol_list{tol_j};
            tic
            %% Read in Compressed Data
            compress_data = compress_datas(strcat(alg_prefix, tol));

            if strcmp(compress_alg, 'zfp beta')
                pctRainy_zfp_beta(:,tol_j) = squeeze(mean(mean(compress_data > 0,1),2));
            else
                pctRainy_zfp(:,tol_j) = squeeze(mean(mean(compress_data > 0,1),2));
            end
        end
    end

    seaspctRainy_orig = squeeze(mean(reshape(pctRainy_orig, 365, []),2));
    seaspctRainy_zfp = squeeze(mean(reshape(pctRainy_zfp, 365, N/365, length(tol_list_zfp)),2));
    seaspctRainy_zfp_beta = squeeze(mean(reshape(pctRainy_zfp_beta, 365, N/365, length(tol_list_zfp)),2));

    seaspctRainy_origAdj = (squeeze(sum(reshape(pctRainy_orig, 365, []),2)) + 1)./(N/365+2);
    seaspctRainy_zfpAdj = (squeeze(sum(reshape(pctRainy_zfp, 365, N/365, length(tol_list_zfp)),2)) + 1)./(N/365+2);
    seaspctRainy_zfp_betaAdj = (squeeze(sum(reshape(pctRainy_zfp_beta, 365, N/365, length(tol_list_zfp)),2)) + 1)./(N/365+2);

    logOR_zfp = log10( (seaspctRainy_zfpAdj./(1-seaspctRainy_zfpAdj)) ./ ...
                        (seaspctRainy_origAdj./(1-seaspctRainy_origAdj)) );
    logOR_zfp_beta = log10( (seaspctRainy_zfp_betaAdj./(1-seaspctRainy_zfp_betaAdj)) ./ ...
                        (seaspctRainy_origAdj./(1-seaspctRainy_origAdj)) );


    Markers = {'o', '*', 'x', 'square', '^'};
    Colors = {'r', 'b', 'g', 'm', 'c'};

    subplot(2,4,1), plot(seaspctRainy_orig, '+-k', 'MarkerSize', 10, 'LineWidth', 2, 'MarkerIndices', 1:30:365); hold on
    for k = 1:length(tol_list_zfp)
        subplot(2,4,1), plot(seaspctRainy_zfp(:,k), strcat( Markers{k}, '-', Colors{k}), 'MarkerSize', 7, 'MarkerIndices', 1:30:365)
    end
    xlim([1 365])
    ylim([0 1])
    ylabel("% rainy days")
    xlabel("day")
    title('zfp 0.5.3')
    subplot(2,4,1), legend(['Original', tol_list_zfp], 'Location', 'West')
    
    subplot(2,4,2), plot(seaspctRainy_orig, '+-k', 'MarkerSize', 10, 'LineWidth', 2, 'MarkerIndices', 1:30:365); hold on
    for k = 1:length(tol_list_zfp)
        subplot(2,4,2), plot(seaspctRainy_zfp_beta(:,k), strcat( Markers{k}, '-', Colors{k}), 'MarkerSize', 7, 'MarkerIndices', 1:30:365)
    end
    xlim([1 365])
    ylim([0 1])
    xlabel("day")
    title('zfp beta')

    subplot(2,4,3), plot(seaspctRainy_orig, '+-k', 'MarkerSize', 10, 'LineWidth', 2, 'MarkerIndices', 1:30:365); hold on
    for k = 1:length(tol_list_zfp)
        subplot(2,4,3), plot(seaspctRainy_zfp(:,k), strcat( Markers{k}, '-', Colors{k}), 'MarkerSize', 7, 'MarkerIndices', 1:30:365)
    end
    xlim([1 365])
    ylim([0.85 1])
    xlabel("day")
    title('zfp 0.5.3')

    subplot(2,4,4), plot(seaspctRainy_orig, '+-k', 'MarkerSize', 10, 'LineWidth', 2, 'MarkerIndices', 1:30:365); hold on
    for k = 1:length(tol_list_zfp)
        subplot(2,4,4), plot(seaspctRainy_zfp_beta(:,k), strcat( Markers{k}, '-', Colors{k}), 'MarkerSize', 7, 'MarkerIndices', 1:30:365)
    end
    xlim([1 365])
    ylim([0.85 1])
    xlabel("day")
    title('zfp beta')
    text(340, 1.01, 'Zoomed-in', 'FontSize', 15)

    subplot(2,4,5), plot(logOR_zfp(:,1), strcat( Markers{1}, '-', Colors{1}), 'MarkerSize', 7, 'MarkerIndices', 1:30:365); hold on
    if(length(tol_list_zfp) > 1)
        for k = 2:length(tol_list_zfp)
            subplot(2,4,5), plot(logOR_zfp(:,k), strcat( Markers{k}, '-', Colors{k}), 'MarkerSize', 7, 'MarkerIndices', 1:30:365)
        end
    end
    xlim([1 365])
    ylim([-4 0.5])
    ylabel("Log10(Odds Ratio)")
    xlabel("day")
    title('zfp 0.5.3')

    subplot(2,4,6), plot(logOR_zfp_beta(:,1), strcat( Markers{1}, '-', Colors{1}), 'MarkerSize', 7, 'MarkerIndices', 1:30:365); hold on
    if(length(tol_list_zfp) > 1)
        for k = 2:length(tol_list_zfp)
            subplot(2,4,6), plot(logOR_zfp_beta(:,k), strcat( Markers{k}, '-', Colors{k}), 'MarkerSize', 7, 'MarkerIndices', 1:30:365)
        end
    end
    xlim([1 365])
    ylim([-4 0.5])
    xlabel("day")
    title('zfp beta')

    set(gcf,'Units', 'inches', 'Position', [0 0 12 8], 'PaperUnits','inches','PaperPosition', [0 0 12 8])


    save_path = [save_dir, 'pctrainy_annual_new.png'];
    print(save_path, '-dpng')
    close
end