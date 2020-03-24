% Creates a 4x2 plot of the lag-1 correlations of the first differances of
% the deseasonalized TS values for the technote. At the top is the original
% data, on the left is the sz algorithm, and on the right is the zfp
% algorithm. Tolerance levels of 1.0, 0.5, 0.1, and 0.01 are included from
% top to bottom. 
function[] = corrCoefs_TS_zfp_comparison(orig_data, compress_datas, alg_prefix_list, tol_list_sz, tol_list_zfp, save_dir, N, nLat, nLon, variable)

    tol_list_zfp = {'1.0', '0.5', '1e-1', '1e-2'};
    %orig_data_deseas = reshape(orig_data, nLon, nLat, 365, N/365) - mean(reshape(orig_data, nLon, nLat, 365, N/365), 4);
    %orig_data_deseas = reshape(orig_data_deseas, nLon, nLat, N);
    %difforig_data_deseas = orig_data_deseas(:, :, 2:end) - orig_data_deseas(:, :, 1:(end-1));
    %ar1_orig = sum(difforig_data_deseas(:, :, 2:end) .* difforig_data_deseas(:, :, 1:(end-1)), 3) ./ ...
    %    sum(difforig_data_deseas.^2,3);

    set(gcf,'Units', 'inches', 'Position', [0 0 4 6], 'PaperUnits','inches','PaperPosition', [0 0 4 6]) 

%     ax_orig = subaxis(length(tol_list_zfp)+1,2,1.5,1, 'Spacing', 0, 'SpacingHoriz' , 0 , 'SpacingVert' , 0 , ... 
%                 'Padding', 0, 'PaddingRight', 0, 'PaddingLeft', 0.05 , 'PaddingTop', 0.01 , 'PaddingBottom', 0 , ... 
%                 'Margin', 0 , 'MarginRight', 0.03, 'MarginLeft', 0.1 , 'MarginTop', 0.1 , 'MarginBottom', 0);
%     axesm('robinson');
%     set(gca, 'LooseInset', get(gca,'TightInset'));
%     framem; tightmap;
%     load coast;
%     pcolorm([-90 90],[-180,180], ar1_orig');
%     plotm(lat,long, 'k');
%     cbar_max(1) = max(abs(ar1_orig(:)));
%     colormap(flipud(b2r(-cbar_max(1), cbar_max(1))));
%     %C2 = colorbar('southoutside', 'FontSize', 5);
%     text(-2.5, 2.2, 'Original');

    %% Make maps of annual power for each compression level/algorithm

    cbar_max = zeros(length(tol_list_zfp),length(alg_prefix_list));
    for alg_i = 1:length(alg_prefix_list)
        alg_prefix = alg_prefix_list{alg_i};
        if strcmp(alg_prefix, 'zfpATOL') 
            tol_list = tol_list_zfp;
            compress_alg = 'zfp 0.5.3';
        elseif strcmp(alg_prefix, 'beta_zfpATOL')
            tol_list = tol_list_zfp;
            compress_alg = 'zfp beta';
        elseif strcmp(alg_prefix, 'round_zfpATOL')
            tol_list = tol_list_zfp;
            compress_alg = 'zfp round';
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

            ax(alg_i, tol_j) = subaxis(length(alg_prefix_list),length(tol_list_zfp),tol_j,alg_i, 'Spacing', 0, 'SpacingHoriz' , 0 , 'SpacingVert' , 0 , ... 
                'Padding', 0, 'PaddingRight', 0, 'PaddingLeft', .02 , 'PaddingTop', 0.0 , 'PaddingBottom', 0 , ... 
                'Margin', 0 , 'MarginRight', 0.03, 'MarginLeft', 0.08 , 'MarginTop', 0.05 , 'MarginBottom', 0.05, 'HoldAxis', 1);

            axesm('robinson');
            set(gca, 'LooseInset', get(gca,'TightInset'));
            framem; tightmap;
            load coast;
            pcolorm([-90 90],[-180,180], ar1_compress');
            plotm(lat,long, 'k');
            cbar_max(alg_i, tol_j) = max(abs(ar1_compress(:)));
            colormap(ax(alg_i, tol_j), flipud(b2r(-cbar_max(alg_i, tol_j), cbar_max(alg_i, tol_j))));

            if alg_i == length(alg_prefix_list)
                originalSize = get(gca, 'Position');
                C2 = colorbar('southoutside', 'FontSize', 5);
                set(gca, 'Position', originalSize);
            end

            if strcmp(alg_prefix, string(alg_prefix_list(1)))
                text(0, 2, char(tol));
            end
            if strcmp(tol, char(tol_list(1)))
                text(-5, 0, compress_alg);
            end
            disp([alg_prefix, tol_list{tol_j}])
        end
    end

    cbar_lim = max(cbar_max(:));
    %cbar_lim = max(cbar_max(~isnan(cbar_max)),[],1);

%%
    %set(ax_orig, 'Clim', [-cbar_lim, cbar_lim]);
    for k=1:length(alg_prefix_list)
        for m=1:length(tol_list)
            set(ax(k,m), 'CLim', [-cbar_lim, cbar_lim]);
        end
    end


    set(gcf,'Units', 'inches', 'Position', [0 0 11 5], 'PaperUnits','inches','PaperPosition', [0 0 11 5])
    if strcmp('1.0', string(tol_list_zfp(1)))
        save_path = [save_dir, 'Corr_PlotArray_TS_new', '.png'];
    else
        save_path = [save_dir, 'Corr_PlotArray_TS_new', '_tight_tolerance', '.png'];
    end
    print(save_path, '-dpng', '-r300')
    close
end