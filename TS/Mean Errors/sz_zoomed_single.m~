% Creates a 1x3 plot of zoomed in mean errors for the zfp algorithm for TS 
% used in the technote. The left plot is centered around -120 degrees 
% longitude, the middle plot is centered around 0 degrees longitude, and 
% the right plot is centered around 120 degrees longitude.

function[] = sz_zoomed_single(model_lat_edge, model_lon_edge, diff_data, diff_data_name, save_dir, variable)

    diff_mean = mean(diff_data, 3);
%    diff_mean_reduced_1 = diff_mean(136:152,59:86);
    diff_mean_reduced_2 = diff_mean(201:217,120:147);
%    diff_mean_reduced_3 = diff_mean(40:56,59:86);
    boxLat = model_lat_edge(1:4:(end-4));
    boxLon = model_lon_edge(5:4:end);
    
    % graph 1
    %ax1 = subaxis(1,3,1, 'Spacing', 0.0, 'Padding', 0.01, 'Margin', 0.04);
    %axesm('robinson','MapLonLimit',[model_lon_edge(40) model_lon_edge(57)], 'MapLatLimit',[model_lat_edge(59) model_lat_edge(87)], 'Grid', 'on', 'ParallelLabel', 'on', 'MeridianLabel', 'on', 'MLineLocation', boxLon, 'PLineLocation', boxLat, 'FontSize', 5, 'LabelFormat', 'none');
    %framem;
    %load coast;
    %pcolorm([model_lat_edge(59)  model_lat_edge(87)],[model_lon_edge(40) model_lon_edge(57)], diff_mean_reduced_3');
    %plotm(lat,long, 'k');
    %colormap(ax1,flipud(b2r(-max(max(abs(diff_mean))), max(max(abs(diff_mean))))));
    %C2 = colorbar('SouthOutside');
    %xlabel(C2,'Mean','FontSize',8);
    
    % graph 2
    %ax2 = subaxis(1,3,2, 'Spacing', 0.0, 'Padding', 0.01, 'Margin', 0.04);
    %axesm('robinson','MapLonLimit',[model_lon_edge(136) model_lon_edge(153)], 'MapLatLimit',[model_lat_edge(59) model_lat_edge(87)], 'Grid', 'on', 'ParallelLabel', 'on', 'MeridianLabel', 'on', 'MLineLocation', boxLon, 'PLineLocation', boxLat, 'FontSize', 5, 'LabelFormat', 'none');
    %framem;
    %load coast;
    %pcolorm([model_lat_edge(59)  model_lat_edge(87)],[model_lon_edge(136) model_lon_edge(153)], diff_mean_reduced_1');
    %plotm(lat,long, 'k');
    %colormap(ax2, flipud(b2r(-max(max(abs(diff_mean))), max(max(abs(diff_mean))))));
    %C2 = colorbar('SouthOutside');
    %xlabel(C2,'Mean','FontSize',8);
    
    % graph 3
    ax3 = subaxis(1,1,1, 'Spacing', 0.0, 'Padding', 0.0, 'Margin', 0.1);
    axesm('robinson','MapLonLimit',[model_lon_edge(201) model_lon_edge(218)], 'MapLatLimit',[model_lat_edge(120) model_lat_edge(148)], 'Grid', 'on', 'ParallelLabel', 'on', 'MeridianLabel', 'on', 'MLineLocation', boxLon, 'PLineLocation', boxLat, 'FontSize', 5, 'LabelFormat', 'none');
    framem;
    set(ax3, 'XColor', 'none')
    set(ax3, 'YColor', 'none')
    load coast;
%    pcolorm([model_lat_edge(59)  model_lat_edge(87)],[model_lon_edge(232) model_lon_edge(249)], diff_mean_reduced_2');
    pcolorm([model_lat_edge(120)  model_lat_edge(148)],[model_lon_edge(201) model_lon_edge(218)], diff_mean_reduced_2');
    plotm(lat,long, 'k');
%    colormap(ax3,flipud(b2r(-max(max(abs(diff_mean))), max(max(abs(diff_mean))))));
    colormap(ax3,flipud(b2r(-.0005, .0005)));
    C2 = colorbar('SouthOutside');
    xlabel(C2,'Mean','FontSize',8);
    set(gcf,'Units', 'inches', 'Position', [0 0 4 3], 'PaperUnits','inches','PaperPosition', [0 0 4 3])
    
    % save and close
    save_sd_path = [save_dir,  diff_data_name, variable, 'zoom.png'];
    print(save_sd_path, '-dpng', '-r300')
    close
end