% Creates a 5x2 plot of z-scores for TS errors used in the technote. ZFP is 
% on the right and SZ is on the left. Tolerance levels of 1.0, 0.1,
% 0.01, 0.001, and 0.0001 are included from top to bottom. Each plot contains the 
% threshold for z-scores to be considered significant and the percent of 
% points that are significant in the title.
function[] = subaxis_template_zscore(diff_datas, alg_prefix_list, tol_list_sz, tol_list_zfp, save_dir, N, nLat, nLon, variable)
    %% Look at Z scores

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
        for j=1:length(tol_list)
            tol = tol_list{j};
            diff_data = diff_datas(strcat(alg_prefix, tol));
            diff_mean = mean(diff_data, 3);
            diff_sd = std(diff_data, 0, 3);
            Zscore = diff_mean ./ (diff_sd/sqrt(N));

            % calculate cutoff for FDR
            pvals_zscore = 2*(1 - normcdf(abs(Zscore), 0, 1));
            sorted_pvals_zscore = sort(pvals_zscore(:));
            Zscore_sorted = sort(abs(Zscore(:)));
            fdr_zscore = 0.01;
            pval_cutoff_zscore = sorted_pvals_zscore(find(sorted_pvals_zscore <= fdr_zscore * (1:(nLat*nLon))'/(nLat*nLon), 1, 'last'));
            if ~isempty(pval_cutoff_zscore)
                zscore_cutoff = norminv(1 - pval_cutoff_zscore/2);
                [mapSigLon_zscore, mapSigLat_zscore]=find(pvals_zscore  <= pval_cutoff_zscore);
                percent_sig = (100*(length(mapSigLat_zscore)/(nLon*nLat)));
            else
              percent_sig = 0;  
              zscore_cutoff = 'na';
            end

            ax(j,i) = subaxis(length(tol_list),length(alg_prefix_list),i,j, 'Spacing', 0, 'SpacingHoriz' , 0 , 'SpacingVert' , 0 , ... 
                'Padding', 0, 'PaddingRight', 0, 'PaddingLeft', 0 , 'PaddingTop', 0.02 , 'PaddingBottom', 0 , ... 
                'Margin', 0 , 'MarginRight', 0.1, 'MarginLeft', 0.1 , 'MarginTop', 0.1 , 'MarginBottom', 0.02, 'Holdaxis', 1);
            axesm('robinson');
            set(gca, 'LooseInset', get(gca,'TightInset'));
            framem; tightmap;
            load coast;
            pcolorm([-90 90],[-180,180], Zscore');
            plotm(lat,long, 'k');
            cbar_max(j,i) = prctile(abs(Zscore(:)), 95);
            if(~isnan(cbar_max(j,i)))
                colormap(ax(j,i), flipud(b2r(-cbar_max(j,i), cbar_max(j,i))));
            else
                colormap(ax(j,i), flipud(b2r(-1, 1)));
            end
            C2 = colorbar('southoutside', 'FontSize', 10);
            title(['Threshold:', num2str(zscore_cutoff,2), ' Sig:' ,num2str(percent_sig,2), '%'], 'FontSize', 10)
            
            if strcmp(alg_prefix, string(alg_prefix_list(1)))
                text(-4.8, 0, char(tol), 'FontSize', 15);
            end
            if strcmp(tol, char(tol_list(1)))
                text(-0.1, 2.5, compress_alg, 'FontSize', 15);
            end
        end
    end

    cbar_lim = max(cbar_max(),[],2);

    for k=1:length(alg_prefix_list)
        for m=1:length(tol_list)
            set(ax(m,k), 'CLim', [-cbar_lim(m), cbar_lim(m)]);
        end
    end

    set(gcf,'Units', 'inches', 'Position', [0 0 8 11], 'PaperUnits','inches','PaperPosition', [0 0 8 11])
    if strcmp('1.0', string(tol_list_zfp(1)))
        save_path = [save_dir, 'zscore', char(variable), '.png'];
    else
        save_path = [save_dir, 'zscore', char(variable), 'tight_tolerance', '.png'];
    end
    print(save_path, '-dpng', '-r300')
    close

end