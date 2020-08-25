% Creates a 5x2 plot of the amplitudes of the error annual harmonic
% relative to the 50 frequencies around the 50 frequencies around the
% annual frequency for TS errors used in the technote. On the left is sz 
% and on the right is zfp. Error tolerances of 1.0, 0.1, 0.01, 0.001, 0.0001 are 
% included from top to bottom. Locations marked as significant are marked 
% with a dot and the percent of points that are significant are given in 
% the title of each graph.
function AnnualPowerMaps_daily_new(diff_datas, alg_prefix_list, tol_list_sz, tol_list_zfp, save_dir, model_lat, model_lon, N, nLat, nLon, variable)

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

            diff_data = diff_datas(strcat(alg_prefix, tol)); %reorganize longitudes

            diff_mat = reshape(diff_data, nLat*nLon, []); % each row is  a time series
            diff_demean = bsxfun(@minus, diff_mat, mean(diff_mat,2)); % subtract mean

            DF_diff = fft(diff_demean,[],2); %FFT of every row
            %DF_annual_diff = DF_diff(:, N/365 + 1);
            %S_annual_diff = real(DF_annual_diff.*conj(DF_annual_diff)./N); % annual power
            S_diff = real(DF_diff.*conj(DF_diff)./N);
            S_annual_diff = S_diff(:, int64(N/365) + 1); % annual power
            S_mean_diff = mean(S_diff(:, [(int64(N/365)+1-25):(int64(N/365)), (int64(N/365)+2):(int64(N/365)+1+25)]),2);
            
            S_an_mat_diff = reshape(S_annual_diff, nLon, nLat); %reshape back to lon lat
            S_mean_mat_diff = reshape(S_mean_diff, nLon, nLat); %reshape back to lon lat
            logratio_diff = log10(S_an_mat_diff./S_mean_mat_diff);

            pvals = 1 - fcdf(10.^logratio_diff, 2, 100);
            sorted_pvals = sort(pvals(:));
            sig_cutoff = finv(1-sorted_pvals(find(sorted_pvals <= 0.01 * (1:(nLat*nLon))'/(nLat*nLon), 1, 'last')), 2, 50);
            if(~isempty(sig_cutoff))
                [mapSigLon, mapSigLat]=find(10.^logratio_diff > sig_cutoff);
            end
                

            ax(tol_j,alg_i) = subaxis(length(tol_list),length(alg_prefix_list),alg_i,tol_j, 'Spacing', 0, 'SpacingHoriz' , 0 , 'SpacingVert' , 0 , ... 
                'Padding', 0, 'PaddingRight', 0, 'PaddingLeft', 0 , 'PaddingTop', 0.02 , 'PaddingBottom', 0 , ... 
                'Margin', 0 , 'MarginRight', 0.1, 'MarginLeft', 0.1 , 'MarginTop', 0.1 , 'MarginBottom', 0.02, 'Holdaxis', 1);
            axesm('robinson');
            set(gca, 'LooseInset', get(gca,'TightInset'));
            framem; tightmap;
            load coast;
            pcolorm([-90 90],[-180,180],logratio_diff')
            if(~isempty(sig_cutoff))
                plotm(model_lat(mapSigLat),model_lon(mapSigLon),'.', 'Color', [0.5 0.5 0.5], 'MarkerSize', 0.005);
            end
            plotm(lat,long, 'k');
            cbar_max(tol_j,alg_i) = prctile(abs(logratio_diff(:)), 99);
            %cbar_max(tol_j,alg_i) = max(abs(logratio_diff(:)));
            if(~isnan(cbar_max(tol_j,alg_i)))
                colormap(ax(tol_j,alg_i), flipud(b2r(-cbar_max(tol_j,alg_i), cbar_max(tol_j,alg_i))));
            else
                colormap(ax(tol_j,alg_i), flipud(b2r(-1, 1)));
            end
            ticks = [-3, 3];
            if(cbar_max(tol_j) > 0)
                ticks = [int8(-max(cbar_max(tol_j),[],2)), int8(max(cbar_max(tol_j),[],2))];
            end
            C2 = colorbar('southoutside', 'FontSize', 10, 'Ticks', ticks);
            
            if(~isempty(sig_cutoff))
                title([num2str(round(100 * mean(10.^logratio_diff(:) > sig_cutoff),1)), ...
                    '% significant'], 'FontSize', 10)
            end

            if strcmp(alg_prefix, string(alg_prefix_list(1)))
                text(-4.8, 0, char(tol), 'FontSize', 15);
            end
            if strcmp(tol, char(tol_list(1)))
                text(-0.1, 2.5, upper(compress_alg), 'FontSize', 12,'interpreter','latex');
            end
            disp([alg_prefix, tol_list{tol_j}])
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
        save_path = [save_dir, 'Seas_PlotArray_daily', '.png'];
    else
        save_path = [save_dir, 'Seas_PlotArray_daily', '_tight_tolerance', '.png'];
    end
    print(save_path, '-dpng', '-r300')
    close
end
% do for a few locations:
% 1. plot periodogram of residuals
%         
% 2. plot mean seasonal cycle
% 
% 3. Plot annual cycle of residuals