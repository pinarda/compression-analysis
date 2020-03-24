% Plot of the mean absolute error by day of the year for both zfp and sz
% for TS, used in the technote. These include error tolerances of 1.0, 0.5,
% 0.1, and 0.01. 

function[] = mae_day(diff_datas, alg_prefix_list, tol_list_sz, tol_list_zfp, nLon, nLat, save_dir)
    %% 
    k = 1;
    for i=1:length(alg_prefix_list)
        %select tolerance list for corresponding compression algorithm
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
        % for each algorithm + tolerance pair, grab the diff in the directory
        % and plot it
        for j=1:length(tol_list)
            tol = tol_list{j};
            diff_data = diff_datas(strcat(alg_prefix, tol));
            time_series = reshape(abs(diff_data), nLon*nLat, 365, 31390/365);
            mae_location = mean(time_series, 3);
            mae_daily = mean(mae_location);
            %linespec = {'-b', '-r', '-g', '-m','--b', '--r', '--g', '--m'};
            linespec = {[1 0.75 0.75],[1 0.5 0.5],[1 0.25 0.25],[1 0 0],[0.75 0.75 1],[0.5 0.5 1],[0.25 0.25 1],[0 0 1]};
            width = {1, 1, 1, 1, 1, 1, 1, 1};
            style = {':', '-.', '--', '-', ':', '-.', '--', '-'}
            save_plot(k) = plot(log10(mae_daily), 'Color', linespec{k}, 'LineWidth', width{k}, 'LineStyle', style{k});
            xlim([1 365])
            hold on
            legendInfo{k}= [compress_alg, tol];
            k = k + 1;
        end
    end

    %%
    lgd = legend(save_plot,legendInfo, "Location", "eastoutside");
    %set(lgd,'Position',get(lgd,'Position')-[0 .14 0 0]);
    fig = gcf;
    set(gcf,'Units', 'inches', 'Position', [0 0 8 4], 'PaperUnits','inches','PaperPosition', [0 0 8 4])
    xlabel('day')
    ylabel('log10(error)')
    title('Mean Absolute Error by Day');
    if strcmp('1.0', string(tol_list_zfp(1)))
        save_path = [save_dir, 'maeday2', '.png'];
    else
        save_path = [save_dir, 'maeday', '_tight_tolerance', '.png'];
    end
    print(save_path, '-dpng')
    close
end