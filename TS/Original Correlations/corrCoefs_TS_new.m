% Creates a 5x2 plot of the lag-1 correlations of the first differances of
% the deseasonalized TS values for the technote. At the top is the original
% data, on the left is the sz algorithm, and on the right is the zfp
% algorithm. Tolerance levels of 1.0, 0.1, 0.01, 0.001, and 0.0001 are included from
% top to bottom. 
function[] = corrCoefs_TS_new(orig_data, compress_datas, alg_prefix_list, tol_list_sz, tol_list_zfp, save_dir, N, nLat, nLon, variable)

    orig_data_deseas = reshape(orig_data, nLon, nLat, 365, int64(N/365)) - mean(reshape(orig_data, nLon, nLat, 365, int64(N/365)), 4);
    orig_data_deseas = reshape(orig_data_deseas, nLon, nLat, N);
    difforig_data_deseas = orig_data_deseas(:, :, 2:end) - orig_data_deseas(:, :, 1:(end-1));
    ar1_orig = sum(difforig_data_deseas(:, :, 2:end) .* difforig_data_deseas(:, :, 1:(end-1)), 3) ./ ...
        sum(difforig_data_deseas.^2,3);

    set(gcf,'Units', 'inches', 'Position', [0 0 5 6], 'PaperUnits','inches','PaperPosition', [0 0 5 6]) 

    ax_orig = subaxis(length(tol_list_zfp)+1,2,1.5,1, 'Spacing', 0, 'SpacingHoriz' , 0 , 'SpacingVert' , 0 , ... 
                'Padding', 0, 'PaddingRight', 0, 'PaddingLeft', 0.0 , 'PaddingTop', 0.0 , 'PaddingBottom', 0 , ... 
                'Margin', 0 , 'MarginRight', 0.1, 'MarginLeft', 0.2 , 'MarginTop', 0.1 , 'MarginBottom', 0.1, 'Holdaxis', 1);
    axesm('robinson');
    set(gca, 'LooseInset', get(gca,'TightInset'));
    framem; tightmap;
    load coast;
    pcolorm([-90 90],[-180,180], ar1_orig');
    plotm(lat,long, 'k');
    cbar_max(1) = max(abs(ar1_orig(:)));
    colormap(flipud(b2r(-cbar_max(1), cbar_max(1))));
    %C2 = colorbar('southoutside', 'FontSize', 5);
    text(-1.5, 2.2, 'Original', 'FontSize', 15);

    %% Make maps of annual power for each compression level/algorithm

    cbar_max = zeros(length(tol_list_zfp),length(alg_prefix_list));
    for alg_i = 1:length(alg_prefix_list)
        alg_prefix = alg_prefix_list{alg_i};
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
        for tol_j=1:length(tol_list)
            tol = tol_list{tol_j};
            
            compress_data = compress_datas(strcat(alg_prefix, tol));

            compress_data_deseas = reshape(compress_data, nLon, nLat, 365, N/365) - mean(reshape(compress_data, nLon, nLat, 365, N/365), 4);
            compress_data_deseas = reshape(compress_data_deseas, nLon, nLat, N);
            diffcompress_data_deseas = compress_data_deseas(:, :, 2:end) - compress_data_deseas(:, :, 1:(end-1));
            ar1_compress = sum(diffcompress_data_deseas(:, :, 2:end) .* diffcompress_data_deseas(:, :, 1:(end-1)), 3) ./ ...
                sum(diffcompress_data_deseas.^2,3);

            ax(tol_j,alg_i) = subaxis(length(tol_list_zfp)+1,2,alg_i,tol_j+1, 'Spacing', 0, 'SpacingHoriz' , 0 , 'SpacingVert' , 0 , ... 
                'Padding', 0, 'PaddingRight', 0, 'PaddingLeft', 0.05 , 'PaddingTop', 0.02 , 'PaddingBottom', 0 , ... 
                'Margin', 0 , 'MarginRight', 0.03, 'MarginLeft', 0.1 , 'MarginTop', 0.1 , 'MarginBottom', 0.05, 'HoldAxis', 1);

            axesm('robinson');
            set(gca, 'LooseInset', get(gca,'TightInset'));
            framem; tightmap;
            load coast;
            pcolorm([-90 90],[-180,180], ar1_compress');
            plotm(lat,long, 'k');
            cbar_max(tol_j,alg_i) = max(abs(ar1_compress(:)));
            colormap(ax(tol_j,alg_i), flipud(b2r(-cbar_max(tol_j,alg_i), cbar_max(tol_j,alg_i))));

            if tol_j == length(tol_list)
                originalSize = get(gca, 'Position');
                C2 = colorbar('southoutside', 'FontSize', 10);
                set(gca, 'Position', originalSize);
            end

            if strcmp(alg_prefix, string(alg_prefix_list(1)))
                text(-4, 0, char(tol), 'FontSize', 15);
            end
            if strcmp(tol, char(tol_list(1)))
                text(-0.1, 1.8, upper(compress_alg), 'FontSize', 12,'interpreter','latex');
            end
            disp([alg_prefix, tol_list{tol_j}])
        end
    end

    cbar_lim = max(cbar_max(:));

    set(ax_orig, 'Clim', [-cbar_lim, cbar_lim]);
    for k=1:length(alg_prefix_list)
        for m=1:length(tol_list)
            set(ax(m,k), 'CLim', [-cbar_lim, cbar_lim]);
        end
    end


    set(gcf,'Units', 'inches', 'Position', [0 0 8 11], 'PaperUnits','inches','PaperPosition', [0 0 8 11])
    if strcmp('1.0', string(tol_list_zfp(1)))
        save_path = [save_dir, 'Corr_PlotArray_TS', '.png'];
    else
        save_path = [save_dir, 'Corr_PlotArray_TS', '_tight_tolerance', '.png'];
    end
    print(save_path, '-dpng', '-r300')
    close
end