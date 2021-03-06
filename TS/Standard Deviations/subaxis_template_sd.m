% Creates a 5x2 plot of the standard deviations for TS errors used in the 
% technote. ZFP is on the right and SZ is on the left. Tolerance levels of 
% 1.0, 0.1, 0.01, 0.001, and 0.0001 are included from top to bottom. Each plot 
% contains the pooled standard deviation in the title.


%% Read in Data
function[] = subaxis_template_sd(diff_datas, alg_prefix_list, tol_list_sz, tol_list_zfp, save_dir, variable)

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
            diff_var = var(diff_data, 0, 3);
            pooled_var = mean(diff_var(:));
            pooled_sd = sqrt(pooled_var);
            diff_var_ratio = diff_var / pooled_var;
            ax(j,i) = subaxis(length(tol_list),length(alg_prefix_list),i,j, 'Spacing', 0, 'SpacingHoriz' , 0 , 'SpacingVert' , 0 , ... 
                'Padding', 0, 'PaddingRight', 0, 'PaddingLeft', 0 , 'PaddingTop', 0.02 , 'PaddingBottom', 0 , ... 
                'Margin', 0 , 'MarginRight', 0.1, 'MarginLeft', 0.1 , 'MarginTop', 0.1 , 'MarginBottom', 0.02, 'Holdaxis', 1);
            axesm('robinson');
            set(gca, 'LooseInset', get(gca,'TightInset'));
            framem; tightmap;
            load coast;
            pcolorm([-90 90],[-180,180], log10(diff_var_ratio)');
            plotm(lat,long, 'k');
            cbar_max(j,i) = prctile(abs(log10(diff_var_ratio(diff_var_ratio~=0))), 95);
            if(~isnan(cbar_max(j,i)))
                colormap(ax(j,i), flipud(b2r(-cbar_max(j,i), cbar_max(j,i))));
            else
                colormap(ax(j,i), flipud(b2r(-1, 1)));
            end
            
            C2 = colorbar('southoutside', 'FontSize', 10);
            title(['Pooled SD:', num2str(pooled_sd,2)], 'FontSize', 10);
            if strcmp(alg_prefix, string(alg_prefix_list(1)))
                text(-4.8, 0, char(tol), 'FontSize', 15);
            end
            if strcmp(tol, char(tol_list(1)))
                text(-0.1, 2.5, upper(compress_alg), 'FontSize', 12,'interpreter','latex');
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
        save_path = [save_dir, 'sd', char(variable), '.png'];
    else
        save_path = [save_dir, 'sd', char(variable), 'tight_tolerance', '.png'];
    end
    print(save_path, '-dpng', '-r300')
    close
end