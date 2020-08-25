%% Setup

clear *

% add the path of helper functions load_data, get_data_paths
addpath('/glade/u/home/apinard/compression-analysis/');

% add the path of matlab packages/functions
addpath('/gpfs/u/home/apoppick/MATLABPackages/b2r');
addpath('/gpfs/u/home/apoppick/MATLABPackages/subaxis');
addpath('/glade/u/home/apinard/compression-analysis/MATLABPackages/cmocean');
addpath('/glade/u/home/apinard/compression-analysis/MATLABPackages/latexTable');

% set the path of the climate data and the save directory for the graphs   
data_dir = '/glade/p/cisl/iowa/abaker_carleton/';
save_dir = '/glade/work/apinard/Save/';

%% get TS paths

% setup
variable_list = {'TS','PRECT'};
for i = 1:length(variable_list)
    variable = char(variable_list(i));
    algorithms = {'szAOn', 'zfpATOL'};
    if(strcmp(variable, 'TS'))
        clear diff_data compressed_data orig_data;
        addpath(genpath('/glade/u/home/apinard/compression-analysis/TS/'));
        rmpath(genpath('/glade/u/home/apinard/compression-analysis/PRECT/'));
        
        
        sz_tols = {'1.0', '0.5' '0.1', '0.01', '0.001', '0.0001', '1e-05'};
        zfp_tols = {'1.0', '0.5', '1e-1', '1e-2', '1e-3', '1e-4', '1e-5'};
        %sz_tols = {'1.0', '0.5' '0.1', '0.01'};
        %zfp_tols = {'1.0', '0.5', '1e-1', '1e-2'};
    end
    if(strcmp(variable, 'PRECT'))
        clear diff_data compressed_data orig_data;
        addpath(genpath('/glade/u/home/apinard/compression-analysis/PRECT/'));
        rmpath(genpath('/glade/u/home/apinard/compression-analysis/TS/'));
        sz_tols = {'0.1', '0.01', '0.001', '0.0001', '1e-05', '1e-06', '1e-07', '1e-08', '1e-09', '1e-10', '1e-11', '1e-12'};
        zfp_tols = {'1e-1', '1e-2', '1e-3', '1e-4', '1e-5', '1e-6','1e-7', '1e-8', '1e-9', '1e-10','1e-11', '1e-12', '0'};

    end

    % get_data_paths(v, algorithms, tols_sz, tols_zfp)
    %   v = 'TS' or 'TSMX'
    %   algorithms = {'szAOn', 'zfpATOL'}
    %   sz_tols = {'1.0', '0.5', '0.1', '0.01'};
    %   zfp_tols = {'1.0', '0.5', '1e-1', '1e-2'};
    [orig_data_path, diff_data_paths, compressed_data_paths] = get_data_paths(variable, algorithms, sz_tols, zfp_tols, data_dir);
    diff_data_paths('szAOn1e-05') = '/glade/p/cisl/iowa/abaker_carleton/ts/szAOn1e-05/TS.diff-szAOn-5.nc';

    %% Load data

    % load_data(v, orig_data_path, diff_data_paths, compressed_data_paths)
    %   v = 'TS' or 'TSMX'
    %   data_paths, a containers.Map with string keys, values
    orig_data = load_data(variable, orig_data_path);
    if(strcmp(variable, 'TS'))
        diff_data = load_data(variable, diff_data_paths);
    end
    compressed_data = load_data(variable, compressed_data_paths);

    model_lat = ncread(orig_data_path('orig'), 'lat');
    model_lon = ncread(orig_data_path('orig'), 'lon');
    model_lon(model_lon > 180) = model_lon(model_lon > 180) - 360;
    model_lon = [model_lon(146:288); model_lon(1:145)];
    N = size(orig_data('orig'), 3)

    nLon = size(model_lon, 1);
    nLat =  size(model_lat, 1);

    model_lat_edge = ncread(orig_data_path('orig'), 'slat');
    model_lon_edge = ncread(orig_data_path('orig'), 'slon');
    model_lon_edge(model_lon_edge > 180) = model_lon_edge(model_lon_edge > 180) - 360;
    model_lon_edge = [model_lon_edge(146:288); model_lon_edge(1:145)];
%%
    obs =  size(orig_data('orig'), 3);

    %% Run graphing scripts

    if strcmp(variable, 'TS')
        % Figure 1
        exploratory_analysis_ts(orig_data('orig'), save_dir, variable);
        
        sz_tols_1 = {'1.0', '0.5', '0.1', '0.01'};
        zfp_tols_1 = {'1.0', '0.5', '1e-1', '1e-2'};
        % Figure 2
        mae_day(diff_data, algorithms, sz_tols_1, zfp_tols_1, nLon, nLat, save_dir);
        % Figure 5
        time_series_template_both_seasonality_daily(diff_data('szAOn0.1'), diff_data('zfpATOL1e-1'), 'szA0n0.1', 'zfpATOL1e-1', model_lat, model_lon, save_dir, N, 192, 144);
        % Figure 10
        TwoLocations_seasonalPlot(orig_data('orig'), compressed_data, algorithms, sz_tols_1, zfp_tols_1, model_lat, model_lon, save_dir, variable, 192, 144)
        
        sz_tols_2 = {'1.0', '0.1', '0.01', '0.001', '0.0001'};
        zfp_tols_2 = {'1.0', '1e-1', '1e-2', '1e-3', '1e-4'};
        % Figure 6
        subaxis_template_mean(diff_data, algorithms, sz_tols_2, zfp_tols_2, save_dir, variable);
        % Figure 7
        sz_zoomed_single(model_lat_edge, model_lon_edge, diff_data('szAOn0.01'), 'szAOn0.01', save_dir, variable);
        zfp_zoomed_single(model_lat_edge, model_lon_edge, diff_data('zfpATOL1e-2'), 'zfpATOL1e-2', save_dir, variable);
        % Figure 8
        subaxis_template_zscore(diff_data, algorithms, sz_tols_2, zfp_tols_2, save_dir, N, nLat, nLon, variable)
        % Figure 9
        subaxis_template_sd(diff_data, algorithms, sz_tols_2, zfp_tols_2, save_dir, variable)
        % Figure 11
        AnnualPowerMaps_daily_new(diff_data, algorithms, sz_tols_2, zfp_tols_2, save_dir, model_lat, model_lon, N, nLat, nLon, variable)
        % Figure 12
        contrastVarianceNSTS_new(orig_data('orig'), compressed_data, algorithms, sz_tols_2(1:4), zfp_tols_2(1:4), nLat, nLon, obs, save_dir, 1, 31)
        % Figure 13
        corrCoefs_TS_new(orig_data('orig'), compressed_data, algorithms, sz_tols_2(1:4), zfp_tols_2(1:4), save_dir, N, nLat, nLon, variable)
        % Table 1
        table_day(orig_data, compressed_data, diff_data, algorithms, sz_tols, zfp_tols, save_dir, variable)
        % Table 3 data
        days_vec = [1, 32, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335];
        mo_length_vec = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
        for j = 1:length(days_vec)
            %contrastVarianceNSTS_new(orig_data('orig'), compressed_data, algorithms, sz_tols_2(1:4), zfp_tols_2(1:4), nLat, nLon, obs, save_dir, days_vec(j), mo_length_vec(j))
        end
    end
    if strcmp(variable, 'PRECT')
        %Figure 3, Table 2
        ExploratoryWork(orig_data('orig'), compressed_data, algorithms, sz_tols, zfp_tols, N, save_dir)
        % Figure 4
        pctRainy(orig_data('orig'), compressed_data, algorithms, N, save_dir);
        % Figure 14
        makeTimeSeriesPlots(model_lat(144), model_lon(69), model_lat(84), model_lon(64), variable, data_dir, save_dir)
        % Figure 15
        dailyRainfall_oddsRain(orig_data('orig'), compressed_data, algorithms, N, save_dir)
        % Figure 16
        dailyRainfall_oddsRain_smallThreshold(save_dir, data_dir)
        % Figure 17
        dailyRainfall_avgError(save_dir, data_dir)
    end
end