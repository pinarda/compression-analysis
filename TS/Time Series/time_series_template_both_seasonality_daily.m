%Creates the error time series plot for sz overlaid with zfp for TS used in the technote. On the
%right is the first 3 years of the time series, in the middle is the
%histogram of the entire time series, and on the right is the periodogram
%of the time series. The z-score, mean, and standard deviation of the time
%series is also included to the right.

function[] = time_series_template_both_seasonality_daily(diff_data_1, diff_data_2, diff_data_name_1, diff_data_name_2, model_lat, model_lon, save_dir, n_frames, lat, lon)
    %% SZ Time Series 

    N =  n_frames;
    diff_mean = mean(diff_data_1, 3);
    diff_sd = std(diff_data_1, 0, 3);
    Zscore = diff_mean ./ (diff_sd/sqrt(N));
    
    lat_num = lat;
    lon_num = lon;
    lat = model_lat(lat_num);
    lon = model_lon(lon_num);
    point_1 = diff_data_1(lon_num,lat_num,:);
    point_1 = reshape(point_1, 1,[]);
    point_1_zscore = Zscore(lon_num,lat_num);
    point_1_mean = diff_mean(lon_num,lat_num);
    point_1_sd = diff_sd(lon_num,lat_num);

    %% graph 1
    ax1 = subaxis(1,3,1, 'Spacing', 0.0, 'Padding', 0.04, 'Margin', 0.1);
    point_1_reduced = point_1(1:1095);
    x = linspace(0,5,1095);
    plot(x,point_1_reduced, 'Color', [.47,0.29,0.10])
    xlim([0 3])
    xlabel('years')
    ylabel('error')
    set(gca,'FontSize',6)
    hold on;

    %% graph 2
    ax2 = subaxis(1,3,2, 'Spacing', 0.0, 'Padding', 0.04, 'Margin', 0.1);
    histogram(point_1, 100, 'FaceColor', [.47,0.29,0.10], 'EdgeColor', [.47,0.29,0.10])
    xlabel('error')
    ylabel('count')
    set(gca,'FontSize',6)
    hold on;

    %% graph 3
    ax3 = subaxis(1,3,3, 'Spacing', 0.0, 'Padding', 0.03, 'Margin', 0.1);
    Y = point_1;
    Y_tilde = fft(Y - mean(Y)); %FFT of every (de-meaned) column
    I = real(Y_tilde.*conj(Y_tilde)./N); %periogoram
    I = I(2:(N/2+1)); %periodogram values past N/2 simply repeat the first N/2 value
    freqs = (1:(N/2))./N;
    plot(freqs, log10(I), 'Color', [.47,0.29,0.10]) %usually plot periogoram on log scale
    xlim([0 0.5])
    xlabel('frequency') %units of frequency are cycles per month or day, depending on whether you're looking at daily or monthly data
    ylabel('log10(periodogram)')
    set(gca,'FontSize',6)
    hold on;

    %% ZFP Time Series 

    N =  n_frames;
    diff_mean = mean(diff_data_2, 3);
    diff_sd = std(diff_data_2, 0, 3);
    Zscore = diff_mean ./ (diff_sd/sqrt(N));
    
    
    point_1 = diff_data_2(lon_num,lat_num,:);
    point_1 = reshape(point_1, 1,[]);
    point_1_zscore = Zscore(lon_num,lat_num);
    point_1_mean = diff_mean(lon_num,lat_num);
    point_1_sd = diff_sd(lon_num,lat_num);

    % graph 1
    ax1 = subaxis(1,3,1, 'Spacing', 0.0, 'Padding', 0.04, 'Margin', 0.1);
    point_1_reduced = point_1(1:1095);
    x = linspace(0,5,1095);
    plot(x,point_1_reduced, 'Color', [0.23,0.49,0.47])
    xlim([0 3])
    xlabel('years')
    ylabel('error')
    set(gca,'FontSize',6)
    hold off;

    % graph 2
    ax2 = subaxis(1,3,2, 'Spacing', 0.0, 'Padding', 0.04, 'Margin', 0.1);
    histogram(point_1, 100, 'FaceColor', [0.23,0.49,0.47], 'EdgeColor', [0.23,0.49,0.47])
    xlabel('error')
    ylabel('count')
    set(gca,'FontSize',6)
    hold off;

    % graph 3
    ax3 = subaxis(1,3,3, 'Spacing', 0.0, 'Padding', 0.03, 'Margin', 0.1);
    Y = point_1;
    Y_tilde = fft(Y - mean(Y)); %FFT of every (de-meaned) column
    I = real(Y_tilde.*conj(Y_tilde)./N); %periogoram
    I = I(2:(N/2+1)); %periodogram values past N/2 simply repeat the first N/2 value
    freqs = (1:(N/2))./N;
    plot(freqs, log10(I), 'Color', [0.23,0.49,0.47]) %usually plot periogoram on log scale
    xlim([0 0.5])
    xlabel('frequency') %units of frequency are cycles per month or day, depending on whether you're looking at daily or monthly data
    ylabel('log10(periodogram)')
    set(gca,'FontSize',6)
    hold off;
    
        % graph 5
    ax5 = axes('Position',[0.2 0.35 1 1],'Visible','off');
    title = ['Time Series Lon ', num2str(lon,3), ' Lat ', num2str(lat,3), ' Tolerance 0.1'];
    axes(ax5)
    text(.025,0.6,title, 'FontWeight', 'bold', 'FontSize', 10)
    set(gcf,'Units', 'inches', 'Position', [0 0 6 4], 'PaperUnits','inches','PaperPosition', [0 0 6 4])
    
    %% save and close
    save_path = [save_dir,diff_data_name_1,diff_data_name_2,'timeseriesday', num2str(lat), '_', num2str(lon), '.png'];
    print(save_path, '-dpng', '-r300')
    close
end