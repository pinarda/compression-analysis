%Plots Probability of Negative Rain
function[] = daily_Rainfall_negRain(orig_data, compress_datas, alg_prefix_list, N, save_dir)

    tol_list_zfp = {'1e-2', '1e-5', '1e-8', '1e-11', '0'};
    %tol_list_zfp = {'1e-5'};
    tol_list_sz = {'0.01', '1e-05', '1e-08', '1e-11'};
    %tol_list_sz = {'1e-08'};


    %% Calculate Statistics for Original Data

    negRain_orig = (orig_data < 0);
    probNegRain_orig = sum(negRain_orig, 3)./N;

    set(gcf,'Units', 'inches', 'Position', [0 0 5 9], 'PaperUnits','inches','PaperPosition', [0 0 5 9]) 

    ax_orig_negRain = subaxis(length(tol_list_zfp),1,1,1, 'Spacing', 0, 'SpacingHoriz' , 0 , 'SpacingVert' , 0 , ... 
                'Padding', 0, 'PaddingRight', 0, 'PaddingLeft', 0 , 'PaddingTop', 0 , 'PaddingBottom', 0 , ... 
                'Margin', 0 , 'MarginRight', 0.1, 'MarginLeft', 0.1 , 'MarginTop', 0.1 , 'MarginBottom', 0);

    axesm('robinson');
    set(gca, 'LooseInset', get(gca,'TightInset'));
    framem; tightmap;
    load coast;
    pcolorm([-90 90],[-180,180],probNegRain_orig')
    plotm(lat,long, 'k');
    cbar_max_orig_negRain = max(probNegRain_orig(:));
    colormap(ax_orig_negRain, w2k(0, cbar_max_orig_negRain));
    C2 = colorbar('southoutside', 'FontSize', 5);
    text(-1.25, 2, 'Original');


    %% Analyze Compressed Data

    cbar_max_NegRain = zeros(length(tol_list_zfp),length(alg_prefix_list));
    for alg_i = 1:2

        alg_prefix = alg_prefix_list{alg_i};
        if strcmp(alg_prefix, 'zfpATOL') 
            tol_list = tol_list_zfp;
            compress_alg = 'zfp 0.5.3';
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

            %% Look at Negative Rainfall Days

            probNegRain = sum(compress_data < 0, 3)./N;

            ax_NegRain(tol_j,alg_i) = subaxis(length(tol_list_zfp) + 1, length(alg_prefix_list),alg_i,tol_j+1, ...
                'Spacing', 0, 'SpacingHoriz' , 0 , 'SpacingVert' , 0 , ... 
                'Padding', 0, 'PaddingRight', 0, 'PaddingLeft', 0 , 'PaddingTop', 0 , 'PaddingBottom', 0 , ... 
                'Margin', 0 , 'MarginRight', 0.1, 'MarginLeft', 0.1 , 'MarginTop', 0.1 , 'MarginBottom', 0, 'Holdaxis', 1);

            axesm('robinson');
            set(gca, 'LooseInset', get(gca,'TightInset'));
            framem; tightmap;
            load coast;
            pcolorm([-90 90],[-180,180],probNegRain')
            plotm(lat,long, 'k');
            cbar_max_NegRain(tol_j,alg_i) = max(max(probNegRain(:)),0.01);
            colormap(ax_NegRain(tol_j,alg_i), w2k(0, cbar_max_NegRain(tol_j,alg_i)));
            C2 = colorbar('southoutside', 'FontSize', 5);

            if strcmp(alg_prefix, 'zfpATOL') || strcmp(tol, '0')
                text(-4.75, 0, char(tol));
            end
            if strcmp(tol, '1e-2') || strcmp(tol, '0.01')
                text(0, 2, compress_alg);
            end

            disp([alg_prefix, tol_list{tol_j}])
            toc
        end
    end

    cbar_lim_negRain = max(cbar_max_NegRain,[],2);
    for alg_i=1:length(alg_prefix_list)
        for tol_j=1:length(tol_list)
            if ~(alg_i == 1 && tol_j == length(tol_list_zfp))
                set(ax_NegRain(tol_j,alg_i), 'CLim', [0, cbar_lim_negRain(tol_j)]);
            end
        end
    end


    save_path_negRain = [save_dir, 'NegRain_array.png'];
    print(save_path_negRain, '-dpng', '-r300')
    close
end