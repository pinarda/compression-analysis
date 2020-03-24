function[] = subaxis_template_mean_zfp_comparison(diff_datas, alg_prefix_list, tol_list_sz, tol_list_zfp, save_dir, variable)
    %% Look at mean errors
    tol_list_zfp = {'1.0', '1e-1', '1e-2', '1e-4'};
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
            compress_alg = 'zfp round';
        else
            tol_list = tol_list_sz;
            compress_alg = 'sz';
        end
        for j=1:length(tol_list)
            tol = tol_list{j};
            diff_data = diff_datas(strcat(alg_prefix, tol));
            diff_mean = mean(diff_data, 3);
            overall_mean = mean(diff_data(:));
            ax(i,j) = subaxis(length(alg_prefix_list),length(tol_list),j,i, 'Spacing', 0, 'SpacingHoriz' , 0 , 'SpacingVert' , 0 , ... 
                'Padding', 0, 'PaddingRight', 0, 'PaddingLeft', .02 , 'PaddingTop', 0.0 , 'PaddingBottom', 0 , ... 
                'Margin', 0 , 'MarginRight', 0.03, 'MarginLeft', 0.08 , 'MarginTop', 0.05 , 'MarginBottom', 0.05, 'HoldAxis', 1);
            axesm('robinson');
            set(gca, 'LooseInset', get(gca,'TightInset'));
            framem; tightmap;
            load coast;
            pcolorm([-90 90],[-180,180], diff_mean');
            plotm(lat,long, 'k');
            cbar_max(i,j) = prctile(abs(diff_mean(diff_mean~=0)), 95);
            if(~isnan(cbar_max(i,j)))
                colormap(ax(i,j), flipud(b2r(-cbar_max(i,j), cbar_max(i,j))));
            else
                colormap(ax(i,j), flipud(b2r(-1, 1)));
            end
            if i == length(alg_prefix_list)
                originalSize = get(gca, 'Position');
                C2 = colorbar('southoutside', 'FontSize', 5);
                set(gca, 'Position', originalSize);
            end
            %C2 = colorbar('southoutside', 'FontSize', 5);
                
            %if(i ~= length(alg_prefix_list))
            %    colorbar(C2, 'hide')
            %end
            title(['Overall Mean:',num2str(overall_mean,2)], 'FontSize', 10)
            if strcmp(alg_prefix, string(alg_prefix_list(1)))
                text(0, 2, char(tol));
            end
            if strcmp(tol, char(tol_list(1)))
                text(-5, 0, compress_alg);
            end
        end
    end

    cbar_lim = max(reshape(cbar_max(~isnan(cbar_max)), 3, 4),[],1);

    for k=1:length(alg_prefix_list)
        for m=1:length(tol_list)
            set(ax(k,m), 'CLim', [-cbar_lim(m), cbar_lim(m)]);
        end
    end

    set(gcf,'Units', 'inches', 'Position', [0 0 11 5], 'PaperUnits','inches','PaperPosition', [0 0 11 5])
    if strcmp('1.0', string(tol_list_zfp(1)))
        save_path = [save_dir, 'mean', char(variable), '.png'];
    else
        save_path = [save_dir, 'mean', char(variable), 'tight_tolerance', '.png'];
    end
    print(save_path, '-dpng', '-r300')
    close
end
