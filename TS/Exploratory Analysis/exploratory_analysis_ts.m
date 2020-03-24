% Plot of exploratory analysis graphs of the original TS data, used in the 
% technote. Includes the minimum TS on the top left, maximum TS on the top 
% right, mean TS on the bottom left and the 1og 10 (Standard Deviation) on 
% the bottom right.

%% Clean environment and set up paths
function[] = exploratory_analysis_ts(orig_data, save_dir, variable)
    %% get the relevant data
    min_orig_data = min(orig_data, [], 3);
    max_orig_data = max(orig_data, [], 3);
    mean_orig_data = mean(orig_data, 3);
    std_orig_data = std(orig_data, 0, 3);

    % setup first graph
    ax1 = subaxis(2,2,1, 'Spacing', 0.0, 'Padding', 0.01, 'Margin', 0.0, 'MarginTop', 0.1);
    axesm('robinson');
    set(gca, 'LooseInset', get(gca,'TightInset'));
    framem; tightmap;
    load coast;
    pcolorm([-90 90],[-180,180], min_orig_data');
    plotm(lat,long, 'k');
    colormap(ax1, bone);
    cbar_min(1) = prctile(min_orig_data(:), 5);
    cbar_max(1) = prctile(min_orig_data(:), 95);
    set(ax1, 'CLim', [cbar_min(1), cbar_max(1)]);
    C2 = colorbar('SouthOutside');
    title(['Minimum ', variable])

    % second graph
    ax2 = subaxis(2,2,2, 'Spacing', 0.0, 'Padding', 0.01, 'Margin', 0.0, 'MarginTop', 0.1);
    axesm('robinson');
    set(gca, 'LooseInset', get(gca,'TightInset'));
    framem; tightmap;
    load coast;
    pcolorm([-90, 90],[-180, 180], max_orig_data');
    plotm(lat,long, 'k');
    colormap(ax2, bone);
    cbar_min(2) = prctile(max_orig_data(:), 5);
    cbar_max(2) = prctile(max_orig_data(:), 95);
    set(ax2, 'CLim', [cbar_min(2), cbar_max(2)]);
    C = colorbar('SouthOutside');
    title(['Maximum ', variable])

    % third graph
    ax3 = subaxis(2,2,3, 'Spacing', 0.0, 'Padding', 0.01, 'Margin', 0, 'MarginTop', 0.1);
    axesm('robinson');
    set(gca, 'LooseInset', get(gca,'TightInset'));
    framem; tightmap;
    load coast;
    pcolorm([-90 90],[-180,180], mean_orig_data');
    plotm(lat,long, 'k');
    colormap(ax3, bone);
    cbar_min(3) = prctile(mean_orig_data(:), 5);
    cbar_max(3) = prctile(mean_orig_data(:), 95);


    cbar_min_limit = min(cbar_min);
    cbar_max_limit = max(cbar_max);
    set(ax3, 'CLim', [cbar_min_limit, cbar_max_limit]);
    set(ax2, 'CLim', [cbar_min_limit, cbar_max_limit]);
    set(ax1, 'CLim', [cbar_min_limit, cbar_max_limit]);

    % finish third graph
    C2 = colorbar('SouthOutside');
    title(['Mean ', variable])

    % fourth graph
    ax4 = subaxis(2,2,4, 'Spacing', 0.0, 'Padding', 0.01, 'Margin', 0, 'MarginTop', 0.1);
    axesm('robinson');
    set(gca, 'LooseInset', get(gca,'TightInset'));
    framem; tightmap;
    load coast;
    pcolorm([-90 90],[-180,180], std_orig_data');
    plotm(lat,long, 'k');
    colormap(ax4, bone);
    set(ax4, 'CLim', [0, max(max(std_orig_data))]);
    C3 = colorbar('SouthOutside');
    title('Standard Deviation')

    % save to file and close
    save_path = [save_dir, variable, 'exploratory.png'];
    print(save_path, '-dpng', '-r300')
    close
end