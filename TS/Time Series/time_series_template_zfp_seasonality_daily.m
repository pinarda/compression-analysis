%Creates the error time series plot for zfp for TS used in the technote. On the
%right is the first 3 years of the time series, in the middle is the
%histogram of the entire time series, and on the right is the periodogram
%of the time series. The z-score, mean, and standard deviation of the time
%series is also included to the right.

function[] = time_series_template_zfp_seasonality_daily(diff_data, diff_data_name, model_lat, model_lon, save_dir, n_frames, lat, lon)

    N =  n_frames;
    diff_mean = mean(diff_data, 3);
    diff_sd = std(diff_data, 0, 3);
    Zscore = diff_mean ./ (diff_sd/sqrt(N));


    %% Time Series 

    lat_num = lat;
    lon_num = lon;
    lat = model_lat(lat_num);
    lon = model_lon(lon_num);
    point_1 = diff_data(lon_num,lat_num,:);
    point_1 = reshape(point_1, 1,[]);
    point_1_zscore = Zscore(lon_num,lat_num);
    point_1_mean = diff_mean(lon_num,lat_num);
    point_1_sd = diff_sd(lon_num,lat_num);

    % graph 1
    ax1 = subaxis(1,3,1, 'Spacing', 0.0, 'Padding', 0.04, 'Margin', 0.1);
    point_1_reduced = point_1(1:1095);
    x = linspace(0,5,1095);
    plot(x,point_1_reduced)
    xlim([0 3])
    xlabel('years')
    ylabel('error')
    set(gca,'FontSize',6)

    % graph 2
    ax2 = subaxis(1,3,2, 'Spacing', 0.0, 'Padding', 0.04, 'Margin', 0.1);
    histogram(point_1, 'BinLimits', [-0.1, 0.1], 'BinWidth', 0.001)
    xlabel('error')
    ylabel('count')
    set(gca,'FontSize',6)

    % graph 3
    ax3 = subaxis(1,3,3, 'Spacing', 0.0, 'Padding', 0.03, 'Margin', 0.1);
    Y = point_1;
    Y_tilde = fft(Y - mean(Y)); %FFT of every (de-meaned) column
    I = real(Y_tilde.*conj(Y_tilde)./N); %periogoram
    I = I(2:(N/2+1)); %periodogram values past N/2 simply repeat the first N/2 value
    freqs = (1:(N/2))./N;
    plot(freqs, log10(I)) %usually plot periogoram on log scale
    xlim([0 0.5])
    xlabel('frequency') %units of frequency are cycles per month or day, depending on whether you're looking at daily or monthly data
    ylabel('log10(periodogram)')
    set(gca,'FontSize',6)

    % graph 4
    ax4 = axes('Position',[0.85 -0.1 1 1],'Visible','off');
    descr = {['Z-score:' , num2str(point_1_zscore,2)];
        ['Mean:' , num2str(point_1_mean,2)];
        ['SD:', num2str(point_1_sd,2)]};
    axes(ax4)
    text(.025,0.6,descr, 'FontSize', 6)

    % graph 5
    ax5 = axes('Position',[0.2 0.35 1 1],'Visible','off');
    title = ['Time Series Lon ', num2str(lon,3), ' Lat ', num2str(lat,3), ' ', diff_data_name];
    axes(ax5)
    text(.025,0.6,title, 'FontWeight', 'bold', 'FontSize', 10)
    set(gcf,'Units', 'inches', 'Position', [0 0 6 4], 'PaperUnits','inches','PaperPosition', [0 0 6 4])

    % save and close
    save_path = [save_dir, diff_data_name,'timeseriesday', num2str(lat), '_', num2str(lon), '.png'];
    print(save_path, '-dpng', '-r300')
    close
end