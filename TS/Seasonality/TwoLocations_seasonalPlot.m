% Plot of seasonal cycles for TS for the locations used in the paper.
% The graphs are from a location at the North Pole.
% The left graphs show the seasonal cycles and the right graphs
% show the error seasonal cycles.

function[] = TwoLocations_seasonalPlot(orig_data, compress_datas, alg_prefix_list, tol_list_sz, tol_list_zfp, model_lat, model_lon, save_dir, variable, lat, lon)
    %% Make plots of seasonal cycles at two locations
    zfp_lonInd = lon;
    zfp_latInd = lat;
    sz_lonInd = lon;
    sz_latInd = lat;

    anCycle_orig_zfpLoc = mean(reshape(squeeze(orig_data(zfp_lonInd, zfp_latInd,:)),365,[]),2);
    anCycle_orig_szLoc = mean(reshape(squeeze(orig_data(sz_lonInd, sz_latInd,:)),365,[]),2);


    subplot(2,2,1)
    plot(1:365, anCycle_orig_zfpLoc, 'k', 'LineWidth', 2)
    xlim([1 365])
    xlabel('Day')
    ylabel('TS, zfp')
    title(['Lon ', num2str(model_lon(zfp_lonInd)), ...
        ' Lat ', num2str(round(model_lat(zfp_latInd),2))])
    hold on

    subplot(2,2,3)
    plot(1:365, anCycle_orig_szLoc, 'k', 'LineWidth', 2)
    xlim([1 365])
    xlabel('Day')
    ylabel('TS, sz')
    title(['Lon ', num2str(model_lon(sz_lonInd)), ...
        ' Lat ', num2str(round(model_lat(sz_latInd),2))])
    hold on

    % add zfp plots
    Markers = {'+', 'o', '*', 'x', 'square'};
    for tol_j = 1:length(tol_list_zfp)
        alg_prefix = 'zfpATOL'; %zfp
        tol = tol_list_zfp{tol_j};
        compress_data = compress_datas(strcat(alg_prefix, tol));

        anCycle_compress_zfpLoc = mean(reshape(squeeze(compress_data(zfp_lonInd, zfp_latInd,:)),365,[]),2);
        anCycle_resid_zfpLoc = anCycle_orig_zfpLoc - anCycle_compress_zfpLoc;
        standardized_zfpLoc = (anCycle_resid_zfpLoc - mean(anCycle_resid_zfpLoc)) ./ ...
                            std(anCycle_resid_zfpLoc);

        subplot(2,2,1)
        plot(1:365, anCycle_compress_zfpLoc, strcat('-',Markers{tol_j}), 'MarkerIndices', 1:30:365); hold on

        subplot(2,2,2)
        plot(1:365, standardized_zfpLoc, strcat('-',Markers{tol_j}), 'MarkerIndices', 1:30:365); hold on
        xlim([1 365])
        xlabel('Day')
        ylabel('Error (standardized)')
    end

    % add sz plots
    for tol_j = 1:length(tol_list_sz)
        alg_prefix = 'szAOn'; %sz
        tol = tol_list_sz{tol_j};
        compress_data = compress_datas(strcat(alg_prefix, tol));


        anCycle_compress_szLoc = mean(reshape(squeeze(compress_data(sz_lonInd, sz_latInd,:)),365,[]),2);
        anCycle_resid_szLoc = anCycle_orig_szLoc - anCycle_compress_szLoc;
        standardized_szLoc = (anCycle_resid_szLoc - mean(anCycle_resid_szLoc)) ./ ...
                            std(anCycle_resid_szLoc);

        subplot(2,2,3)
        plot(1:365, anCycle_compress_szLoc,  strcat('-',Markers{tol_j}), 'MarkerIndices', 1:30:365); hold on

        subplot(2,2,4)
        plot(1:365, standardized_szLoc, strcat('-',Markers{tol_j}), 'MarkerIndices', 1:30:365); hold on
        xlim([1 365])
        xlabel('Day')
        ylabel('Error (standardized)')
    end

    subplot(2,2,1)
    legend(['Original', tol_list_zfp])
    hold off
    subplot(2,2,2)
    hold off
    subplot(2,2,3)
    %legend(['Original', tol_list_sz])
    hold off
    subplot(2,2,4)
    hold off

    set(gcf,'Units', 'inches', 'Position', [0 0 8 7], 'PaperUnits','inches','PaperPosition', [0 0 8 7])

    save_path = [ save_dir, 'TwoLocations_Seas_daily', num2str(lat), '_', num2str(lon), '.png'];
    print(save_path, '-dpng', '-r300')

    close
end