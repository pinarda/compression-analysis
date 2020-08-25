%Plots odds ratio of positive rainfall
function[] = dailyRainfall_oddsRain(orig_data, compress_datas, alg_prefix_list, N, save_dir)

    tol_list_zfp = {'1e-2', '1e-5', '1e-8', '1e-11', '0'};

    %tol_list_zfp = {'1e-2'};
    %Not doing 0.0001 and 1e-05 because zscores are all zero
    tol_list_sz = {'0.01', '1e-05', '1e-08', '1e-11'};
    %tol_list_sz = {'0.1'};

    %% Calculate Statistics for Original Data

    rainDays_orig = (orig_data > 0);
    probRain_orig = (sum(rainDays_orig, 3)+1)./(N+2);
    %note: I'm adding one rainy and one dry day day to avoid dividing 
    %by zero below.
    oddsRain_orig = probRain_orig./(1-probRain_orig);

    set(gcf,'Units', 'inches', 'Position', [0 0 7 8], 'PaperUnits','inches','PaperPosition', [0 0 7 8]) 
    ax_orig = subaxis(length(tol_list_zfp) + 1, 1, ...
        1, 1, 'Spacing', 0, 'SpacingHoriz' , 0 , 'SpacingVert' , 0 , ...
        'Padding', 0, 'PaddingRight', 0, 'PaddingLeft', 0 , 'PaddingTop', 0 , ...
        'PaddingBottom', 0 , 'Margin', 0 , 'MarginRight', 0.1, 'MarginLeft', 0.1 , ...
        'MarginTop', 0.1 , 'MarginBottom', 0.05);
    axesm('robinson');
    set(gca, 'LooseInset', get(gca,'TightInset'));
    framem; tightmap;
    load coast;
    pcolorm([-90 90],[-180,180],log10(oddsRain_orig)')
    plotm(lat,long, 'k');
    cbar_max_orig = max(abs(log10(oddsRain_orig(:))));
    colormap(ax_orig, flipud(b2r(-cbar_max_orig, cbar_max_orig)));
    C2 = colorbar('southoutside', 'FontSize', 10);
    title('log10(odds)')
    text(-2.5, 3.25,  'Original', 'FontSize', 15)


    %% Analyze Compressed Data

    cbar_max_odds = zeros(length(tol_list_zfp),length(alg_prefix_list));
    cbar_max_OR = zeros(length(tol_list_zfp),length(alg_prefix_list));

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

            %% Look at Percent of Rainy Days
            probRain_compress = (sum(compress_data > 0, 3)+1)./(N+2);
            %note: I'm adding one rainy and one dry day day to avoid dividing 
            %by zero below.

            oddsRain_compress = probRain_compress./(1-probRain_compress);

            odds_ratio = (probRain_compress./(1-probRain_compress)) ./ ...
                         (probRain_orig./(1-probRain_orig));

            ax_Odds(tol_j,alg_i) = subaxis(length(tol_list_zfp) + 1, length(alg_prefix_list)*2, ...
                alg_i*2-1, tol_j+1, ...
                'Spacing', 0, 'SpacingHoriz' , 0 , 'SpacingVert' , 0 , ... 
                'Padding', 0, 'PaddingRight', 0, 'PaddingLeft', 0 , 'PaddingTop', 0 , ...
                'PaddingBottom', 0 , 'Margin', 0 , 'MarginRight', 0.1, 'MarginLeft', 0.1 , ...
                'MarginTop', 0.1 , 'MarginBottom', 0.02);        

            axesm('robinson');
            set(gca, 'LooseInset', get(gca,'TightInset'));
            framem; tightmap;
            load coast;
            pcolorm([-90 90],[-180,180],log10(oddsRain_compress)')
            plotm(lat,long, 'k');
            cbar_max_odds(tol_j,alg_i) = prctile(abs(log10(oddsRain_compress(:))), 99);
            colormap(ax_Odds(tol_j,alg_i), flipud(b2r(-cbar_max_odds(tol_j,alg_i), cbar_max_odds(tol_j,alg_i))));
            C2 = colorbar('southoutside', 'FontSize', 10);

            if strcmp(tol, '1e-2') || strcmp(tol, '0.01')
                text(4, 3.25, upper(compress_alg), 'FontSize', 12,'interpreter','latex');
                title('log10(odds)')
            end

            if strcmp(alg_prefix, 'szAOn') || strcmp(tol, '0')
                text(-6, 0, char(tol), 'FontSize', 15);
            end

            ax_OR(tol_j,alg_i) = subaxis(length(tol_list_zfp) + 1, length(alg_prefix_list)*2, ...
                alg_i*2, tol_j+1, 'Spacing', 0, 'SpacingHoriz' , 0 , 'SpacingVert' , 0 , ... 
                'Padding', 0, 'PaddingRight', 0, 'PaddingLeft', 0 , 'PaddingTop', 0 , ...
                'PaddingBottom', 0 , 'Margin', 0 , 'MarginRight', 0.1, 'MarginLeft', 0.1 , ...
                'MarginTop', 0.1 , 'MarginBottom', 0.02);

            if strcmp(tol, '1e-2') || strcmp(tol, '0.01')
                title('log10(odds ratio)')
            end

            axesm('robinson');
            set(gca, 'LooseInset', get(gca,'TightInset'));
            framem; tightmap;
            load coast;
            pcolorm([-90 90],[-180,180],log10(odds_ratio)')
            plotm(lat,long, 'k');
            cbar_max_OR(tol_j,alg_i) = prctile(abs(log10(odds_ratio(:))), 99);
            colormap(ax_OR(tol_j,alg_i), flipud(b2r(-cbar_max_OR(tol_j,alg_i), cbar_max_OR(tol_j,alg_i))));
            C2 = colorbar('southoutside', 'FontSize', 10);

            disp([alg_prefix, tol_list{tol_j}])
            toc
        end
    end

    cbar_lim_odds = max(cbar_max_odds(:));
    cbar_lim_OR = max(cbar_max_OR(:));

    for alg_i=1:length(alg_prefix_list)
        for tol_j=1:length(tol_list_zfp)
            if ~(alg_i == 1 && tol_j == length(tol_list_zfp))
                set(ax_Odds(tol_j,alg_i), 'CLim', [-cbar_lim_odds cbar_lim_odds]);
                set(ax_OR(tol_j,alg_i), 'CLim', [-cbar_lim_OR, cbar_lim_OR]);
            end
        end
    end

    set(gcf,'Units', 'inches', 'Position', [0 0 8 8], 'PaperUnits','inches','PaperPosition', [0 0 8 8])
    save_path_OR = [save_dir, 'OR_array_new.png'];
    print(save_path_OR, '-dpng', '-r300')
    close
end