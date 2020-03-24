% Creates a 4x2 plot of the lag-1 correlations of the deseasonalized errors
% for TS used in the technote. On the left is sz and on the right is zfp.
% Compression error tolerances of 1.0, 0.5, 0.1, and 0.01 are included from
% top to bottom. Locations where the lag-1 correlation is significant is
% marked with a dot and the percent of locations that are significant are
% given in the title.
function[] = subaxis_template_corr_day_new(diff_datas, alg_prefix_list, tol_list_sz, tol_list_zfp, save_dir, model_lat, model_lon, N, nLat, nLon, variable)

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
            diff_mean = mean(diff_data, 3);
            diff_sd = std(diff_data, 0, 3);
            Zscore = diff_mean ./ (diff_sd/sqrt(N));
            day_data = reshape(diff_data, [288,192,365, (size(diff_data,3)/365)]);
            deseason_data = day_data - mean(day_data,4);
            deseason_series = reshape(deseason_data, nLon*nLat, []);
            acf1_matrix = autocorr_matrix(deseason_series, 1);
            pvals_acf1 = 2*(1 - normcdf(sqrt(N)*abs(acf1_matrix)));
            sorted_pvals_acf1 = sort(pvals_acf1(:));
            fdr_acf1 = 0.01;
            pval_cutoff_acf1 = sorted_pvals_acf1(find(sorted_pvals_acf1 <= fdr_acf1 * (1:(nLat*nLon))'/(nLat*nLon), 1, 'last'));
            if ~isempty(pval_cutoff_acf1)
                [mapSigLon_acf1, mapSigLat_acf1]=find(pvals_acf1  <= pval_cutoff_acf1);
                len_sigpoint_acf1 = length(mapSigLon_acf1);
                if len_sigpoint_acf1 > 10000
                    point_size_acf1 = 0.05;
                elseif len_sigpoint_acf1 > 1000
                    point_size_acf1 = 0.2;
                elseif len_sigpoint_acf1 > 200
                    point_size_acf1 = 1;
                else
                    point_size_acf1 = 2;
                end
            end
            ax(j,i) = subaxis(length(tol_list),length(alg_prefix_list),i,j, 'Spacing', 0, 'SpacingHoriz' , 0 , 'SpacingVert' , 0 , ... 
                'Padding', 0, 'PaddingRight', 0, 'PaddingLeft', 0 , 'PaddingTop', 0 , 'PaddingBottom', 0 , ... 
                'Margin', 0 , 'MarginRight', 0.1, 'MarginLeft', 0.1 , 'MarginTop', 0.1 , 'MarginBottom', 0.02, 'Holdaxis', 1);
            axesm('robinson');
            set(gca, 'LooseInset', get(gca,'TightInset'));
            framem; tightmap;
            load coast;
            pcolorm([-90 90],[-180,180], acf1_matrix');
            plotm(lat,long, 'k');
            if ~isempty(pval_cutoff_acf1)
                plotm(model_lat(mapSigLat_acf1),model_lon(mapSigLon_acf1), '.', 'Color', [0.5 0.5 0.5], 'MarkerSize', point_size_acf1);
                percent_sig = (100*(length(mapSigLat_acf1)/(nLon*nLat)));
            else
                percent_sig = 0;
            end
            cbar_max(j,i) = prctile(abs(acf1_matrix(:)), 100);
            if(~isnan(cbar_max(j,i)))
                colormap(ax(j,i), flipud(b2r(-cbar_max(j,i), cbar_max(j,i))));
            else
                colormap(ax(j,i), flipud(b2r(-1, 1)));
            end
            C2 = colorbar('southoutside', 'FontSize', 5);
            title([num2str(percent_sig,2), '% significant'], 'FontSize', 6)
            if strcmp(alg_prefix, string(alg_prefix_list(1)))
                text(-4.5, 0, char(tol));
            end
            if strcmp(tol, char(tol_list(1)))
                text(0, 2.5, compress_alg);
            end
        end
    end

    cbar_lim = max(cbar_max(~isnan(cbar_max)),[],2);

    for k=1:length(alg_prefix_list)
        for m=1:length(tol_list)
            set(ax(m,k), 'CLim', [-cbar_lim(m), cbar_lim(m)]);
        end
    end

    set(gcf,'Units', 'inches', 'Position', [0 0 5 6], 'PaperUnits','inches','PaperPosition', [0 0 5 6])
    if strcmp('1.0', string(tol_list_zfp(1)))
        save_path = [save_dir, 'corr', char(variable), '.png'];
    else
        save_path = [save_dir, 'corr', char(variable), 'tight_tolerance', '.png'];
    end
    print(save_path, '-dpng', '-r300')
    close
end