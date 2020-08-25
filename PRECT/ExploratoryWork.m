% Explores PRECT distributions and creates a table summarizing error
% statistics.
function [] = ExploratoryWork(orig_data, compressed_datas, alg_prefix_list, tol_list_sz, tol_list_zfp, N, save_dir)
    %% Calculate Statistics for Original Data

    rainDays_orig = (orig_data > 0);
    negRain_orig = (orig_data < 0);
    %probNegRain_orig = sum(negRain_orig, 3)./N;
    maxRain_orig = max(orig_data, [], 3);
    minRain_orig = min(orig_data, [], 3);
    meanRain_orig = mean(orig_data, 3);
    probRain_orig = mean(rainDays_orig, 3);


    %% Original Data Exploratory Plots
    ax1 = subaxis(2,2,1, 'Spacing', 0.0, 'Padding', 0.01, 'Margin', 0.0, 'MarginTop', 0.1);
    axesm('robinson');
    set(gca, 'LooseInset', get(gca,'TightInset'));
    framem; tightmap;
    load coast;
    pcolorm([-90 90],[-180,180], log10(minRain_orig + 1e-18)');
    plotm(lat,long);
    colormap(ax1, bone);
    set(ax1, 'CLim', [min(log10(minRain_orig(:) + 1e-18)) max(log10(minRain_orig(:) + 1e-18))]);
    colorbar('SouthOutside');
    title('log10(Minimum PRECT + 1e-18)')

    ax2 = subaxis(2,2,2, 'Spacing', 0.0, 'Padding', 0.01, 'Margin', 0.0, 'MarginTop', 0.1);
    axesm('robinson');
    set(gca, 'LooseInset', get(gca,'TightInset'));
    framem; tightmap;
    load coast;
    pcolorm([-90, 90],[-180, 180], log10(maxRain_orig)');
    plotm(lat,long);
    colormap(ax2, bone);
    set(ax2, 'CLim', [min(log10(maxRain_orig(:))) max(log10(maxRain_orig(:)))]);
    colorbar('SouthOutside');
    title('log10(Maximum PRECT)')

    ax3 = subaxis(2,2,3, 'Spacing', 0.0, 'Padding', 0.01, 'Margin', 0, 'MarginTop', 0.1);
    axesm('robinson');
    set(gca, 'LooseInset', get(gca,'TightInset'));
    framem; tightmap;
    load coast;
    pcolorm([-90 90],[-180,180], log10(meanRain_orig)');
    plotm(lat,long);
    colormap(ax3, bone);
    set(ax3, 'CLim', [min(log10(minRain_orig(:))) max(log10(maxRain_orig(:)))]);
    colorbar('SouthOutside');
    title('log10(Mean Rainfall)')

    ax4 = subaxis(2,2,4, 'Spacing', 0.0, 'Padding', 0.01, 'Margin', 0, 'MarginTop', 0.1);
    axesm('robinson');
    set(gca, 'LooseInset', get(gca,'TightInset'));
    framem; tightmap;
    load coast;
    pcolorm([-90 90],[-180,180], probRain_orig');
    plotm(lat,long);
    colormap(ax4, bone);
    set(ax4, 'CLim', [0, 1]);
    colorbar('SouthOutside');
    title('Probability of Positive Rainfall')

    set(gcf,'Units', 'inches', 'Position', [0 0 8 6], 'PaperUnits','inches','PaperPosition', [0 0 8 6])


   
    save_path = [save_dir, 'PRECTexploratory.png'];
    print(save_path, '-dpng', '-r300')
    close


    %% Compression Error Summaries

    SummaryTable = NaN(length(tol_list_zfp) + 1, 5);
    % average, mae, rmse, prob(pos), prob(neg)
    SummaryTable(1,1) = mean(orig_data(:));
    SummaryTable(1,4) = mean(rainDays_orig(:));
    SummaryTable(1,5) = mean(negRain_orig(:));

    for alg_i = 1:2
        alg_prefix = alg_prefix_list{alg_i};
        if strcmp(alg_prefix, 'zfpATOL') 
            tol_list = tol_list_zfp;
        else
            tol_list = tol_list_sz;
        end
        for tol_j = 1:length(tol_list)

            tic

            tol = tol_list{tol_j};
            compress_data = compressed_datas(strcat(alg_prefix, tol));
            diff_data = orig_data - compress_data;

            compress_data = compress_data(:);
            diff_data = diff_data(:);

            I = find(compress_data ~= 0);
            [I J K] = ind2sub(size(compress_data), I);

            TableRow = 1 + tol_j + (alg_i-1)*(length(tol_list_sz)+1);
            format longE
            SummaryTable(TableRow, 1) = convertCharsToStrings(strcat(alg_prefix, tol));
            SummaryTable(TableRow, 2) = mean(diff_data(:));
            SummaryTable(TableRow, 3) = mean(compress_data);
            SummaryTable(TableRow, 4) = mean(abs(diff_data));
            SummaryTable(TableRow, 5) = sqrt(mean(diff_data.^2));
            SummaryTable(TableRow, 6) = mean(compress_data > 0);
            SummaryTable(TableRow, 7) = mean(compress_data < 0);
            SummaryTable(TableRow, 8) = max(diff_data(:));

            disp([alg_prefix, tol_list{tol_j}])
            toc
        end
    end

    save_path = [save_dir, 'PRECTErrorTable.csv'];
    dlmwrite(save_path, SummaryTable, 'delimiter', ',', 'precision', 16)
    close
end