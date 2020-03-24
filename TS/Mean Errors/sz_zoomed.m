% Creates a 1x3 plot of zoomed in mean errors for the sz algorithm for TS 
% used in the technote. The left plot is centered around -120 degrees 
% longitude, the middle plot is centered around 0 degrees longitude, and 
% the right plot is centered around 120 degrees longitude.

   function[] = sz_zoomed(diff_data, diff_data_name, save_dir, variable)

    diff_mean = mean(diff_data, 3);
    diff_mean_reduced_1 = diff_mean(40:56,112:134);
    diff_mean_reduced_2 = diff_mean(136:152,154:177);
    diff_mean_reduced_3 = diff_mean(232:248,11:33);
    
    % graph 1
    ax1 = subaxis(1,3,1, 'Spacing', 0.0, 'Padding', 0.01, 'Margin', 0.065);
    axesm('robinson','MapLonLimit',[-130 -110], 'MapLatLimit',[14.6073 35.3403], 'Grid', 'on', 'ParallelLabel', 'on', 'MeridianLabel', 'on', 'LabelFormat', 'none');
    framem;
    load coast;
    pcolorm([14.6073 35.3403],[-130 -110], diff_mean_reduced_1');
    plotm(lat,long);
    colormap(ax1, flipud(b2r(-max(max(abs(diff_mean))), max(max(abs(diff_mean))))));
    C2 = colorbar('SouthOutside');
    xlabel(C2,'Mean','FontSize',15);
    
    % graph 2
    ax2 = subaxis(1,3,2, 'Spacing', 0.0, 'Padding', 0.01, 'Margin', 0.0, 'MarginLeft', 0.01);
    axesm('robinson','MapLonLimit',[-10 10], 'MapLatLimit',[54.1885 75.8639], 'Grid', 'on', 'ParallelLabel', 'on', 'MeridianLabel', 'on', 'LabelFormat', 'none');
    framem;
    load coast;
    pcolorm([55.1309 74.9215],[-10 10], diff_mean_reduced_2');
    plotm(lat,long);
    colormap(ax2, flipud(b2r(-max(max(abs(diff_mean))), max(max(abs(diff_mean))))));
    C2 = colorbar('SouthOutside');
    xlabel(C2,'Mean','FontSize',15);
    
    % graph 3
    ax3 = subaxis(1,3,3, 'Spacing', 0.0, 'Padding', 0.01, 'Margin', 0.005);
    axesm('robinson','MapLonLimit',[110 130], 'MapLatLimit',[-80.5759 -59.8429], 'Grid', 'on', 'ParallelLabel', 'on', 'MeridianLabel', 'on', 'LabelFormat', 'none');
    framem;
    load coast;
    pcolorm([-80.5759 -59.8429],[110 130], diff_mean_reduced_3');
    plotm(lat,long);
    colormap(ax3, flipud(b2r(-max(max(abs(diff_mean))), max(max(abs(diff_mean))))));
    C2 = colorbar('SouthOutside');
    xlabel(C2,'Mean','FontSize',15);
    
    % save and close
    set(gcf,'Units', 'inches', 'Position', [0 0 6 4], 'PaperUnits','inches','PaperPosition', [0 0 6 4])
    save_sd_path = [save_dir, diff_data_name, variable, 'zoom.png'];
    print(save_sd_path, '-dpng')
    close
end
