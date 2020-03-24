% Creates a 4x2 plot of the day with the smallest mean absolute error for TS
% used in the technote. On the left is sz and on the right is zfp. The
% compression error tolances includes 1.0, 0.5, 0.1, and 0.01 from top to
% bottom.
function [] = spatial_plot_mae_min_day_new(diff_datas, alg_prefix_list, tol_list_sz, tol_list_zfp, save_dir, nLat, nLon, variable)

    for i=1:length(alg_prefix_list)
        alg_prefix = alg_prefix_list{i};
        if strcmp(alg_prefix, 'zfpATOL') 
            tol_list = tol_list_zfp;
            compress_alg = 'zfp 0.5.3';
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
        for j=1:length(tol_list)
            tol = tol_list{j};
            diff_data = diff_datas(strcat(alg_prefix, tol));
            time_series = reshape(abs(diff_data), nLon*nLat, 365, 31390/365);
            mae_location = mean(time_series, 3);
            [val, idx] = min(mae_location, [], 2);
            mae_min_location = reshape(idx, nLon, nLat);
            ax(j,i) = subaxis(length(tol_list),length(alg_prefix_list),i,j, 'Spacing', 0, 'SpacingHoriz' , 0 , 'SpacingVert' , 0 , ... 
                'Padding', 0, 'PaddingRight', 0, 'PaddingLeft', 0 , 'PaddingTop', 0 , 'PaddingBottom', 0 , ... 
                'Margin', 0 , 'MarginRight', 0.1, 'MarginLeft', 0.1 , 'MarginTop', 0.1 , 'MarginBottom', 0.02);
            axesm('robinson');
            set(gca, 'LooseInset', get(gca,'TightInset'));
            framem; tightmap;
            load coast;
            pcolorm([-90 90],[-180,180], mae_min_location');
            plotm(lat,long, 'k');
            C2 = colorbar('southoutside', 'FontSize', 5);
            cmocean('phase')
            if strcmp(alg_prefix, string(alg_prefix_list(1)))
                text(-4.5, 0, char(tol));
            end
            if strcmp(tol, char(tol_list(1)))
                text(0, 2.5, compress_alg);
            end
            if (strcmp(alg_prefix, string(alg_prefix_list(2))) && strcmp(tol, string(tol_list(1))))
                text(-8,3, ['Day with minimum MAE for ', char(variable)], 'FontWeight', 'bold', 'FontSize', 10)
            end
        end
    end

    set(gcf,'Units', 'inches', 'Position', [0 0 5 6], 'PaperUnits','inches','PaperPosition', [0 0 5 6])
    if strcmp('1.0', string(tol_list_zfp(1)))
        save_path = [save_dir, 'minmae', char(variable), '.png'];
    else
        save_path = [save_dir, 'minmae', char(variable), '_tight_tolerance', '.png'];
    end
    print(save_path, '-dpng', '-r300')
    close
end