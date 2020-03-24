%% Setup

clear *

% add the path of helper functions load_data, get_data_paths
addpath('/glade/u/home/apinard/Code/');
%addpath('/Users/alex/Dropbox/newCode/Code/');

% add the path of matlab packages/functions
addpath('/gpfs/u/home/apoppick/MATLABPackages/b2r');
addpath('/gpfs/u/home/apoppick/MATLABPackages/subaxis');
addpath('/glade/u/home/apinard/Code/MatLabFunctions/autocorr_matrix');
addpath('/glade/u/home/apoppick/MATLABPackages/freezeColors');
addpath('/glade/u/home/apoppick/MATLABPackages/cm_and_cb_utilities');
addpath('/glade/u/home/apinard/Code/MatLabFunctions/cmocean');
addpath('/glade/u/home/apinard/Code/MatLabFunctions/latexTable');

%addpath('/Users/alex/Dropbox/newCode/Code/MATLABPackages/b2r');
%addpath('/Users/alex/Dropbox/newCode/Code/MATLABPackages/subaxis');
%addpath('/Users/alex/Dropbox/newCode/Code/MatLabFunctions/autocorr_matrix');
%addpath('/Users/alex/Dropbox/newCode/Code/MatLabFunctions/cmocean');
%addpath('/Users/alex/Dropbox/newCode/Code/MatLabFunctions/latexTable');
%addpath('/Users/alex/Dropbox/newCode/Code/MatLabPackages/cm_and_cb_utilities');
%addpath('/Users/alex/Dropbox/newCode/Code/MatLabPackages/freezeColors');

% set the path of the climate data and the save directory for the graphs   
data_dir = '/glade/p/cisl/iowa/abaker_carleton/';
save_dir = '/glade/work/apinard/3162020/';
%data_dir = '/Users/alex/Dropbox/newCode/Data/';
%save_dir = '/Users/alex/Dropbox/newCode/Plots/';

%% get TS paths

% setup
variable_list = {'PRECT'};
%variable_list = {'TS'};
for i = 1:length(variable_list)
    variable = char(variable_list(i));
    algorithms = {'szAOn', 'zfpATOL'};
    %algorithms = {'zfpATOL', 'round_zfpATOL', 'beta_zfpATOL'};
    if(strcmp(variable, 'TS'))
        clear diff_data compressed_data orig_data;
        addpath(genpath('/glade/u/home/apinard/newCode/Code/TS/'));
        rmpath(genpath('/glade/u/home/apinard/newCode/Code/PRECT/'));
        
        %addpath(genpath('/Users/alex/Dropbox/newCode/Code/TS/'));
        %rmpath(genpath('/Users/alex/Dropbox/newCode/Code/PRECT/'));
        sz_tols = {'1.0', '0.1', '0.01', '0.001', '0.0001'};
        %sz_tols = {'0.01', '0.001', '0.0001', '1e-05'};
        %sz_tols = {'1.0', '0.5', '0.1', '0.01', '0.001', '0.0001', '1e-05'};
        %sz_tols = {'1.0', '0.5', '0.1', '0.01'};
        
        %zfp_tols = {'1.0', '0.5', '1e-1', '1e-2'};
        %zfp_tols = {'1.0', '0.5', '1e-1', '1e-2', '1e-3', '1e-4', '1e-5'};
        zfp_tols = {'1.0', '1e-1', '1e-2', '1e-3', '1e-4'};
        %zfp_tols = {'1e-2', '1e-3', '1e-4', '1e-5'};
    end
    if(strcmp(variable, 'PRECT'))
        clear diff_data compressed_data orig_data;
        addpath(genpath('/glade/u/home/apinard/newCode/Code/PRECT/'));
        rmpath(genpath('/glade/u/home/apinard/newCode/Code/TS/'));
        %addpath(genpath('/Users/alex/Dropbox/newCode/Code/PRECT/'));
        %rmpath(genpath('/Users/alex/Dropbox/newCode/Code/TS/'));
        sz_tols = {'0.1', '0.01', '0.001', '0.0001', '1e-05', '1e-06', '1e-07', '1e-08', '1e-09', '1e-10', '1e-11', '1e-12'};
        %sz_tols = {'1e-11', '1e-12'};

        zfp_tols = {'1e-1', '1e-2', '1e-3', '1e-4', '1e-5', '1e-6','1e-7', '1e-8', '1e-9', '1e-10','1e-11', '1e-12', '0'};
        %zfp_tols = {'1e-1'};

    end

    % get_data_paths(v, algorithms, tols_sz, tols_zfp)
    %   v = 'TS' or 'TSMX'
    %   algorithms = {'szAOn', 'zfpATOL'}
    %   sz_tols = {'1.0', '0.5', '0.1', '0.01'};
    %   zfp_tols = {'1.0', '0.5', '1e-1', '1e-2'};
    [orig_data_path, diff_data_paths, compressed_data_paths] = get_data_paths(variable, algorithms, sz_tols, zfp_tols, data_dir);
    %diff_data_paths('szAOn1e-05') = '/glade/p/cisl/iowa/abaker_carleton/ts/szAOn1e-05/TS.diff-szAOn-5.nc';
    %diff_data_paths('szAOn1e-08') = '/glade/p/cisl/iowa/abaker_carleton/prect/rearranged/unR.PRECT.diff-szAOn1e-08.nc';
    %compressed_data_paths('szAOn1e-08') = '/glade/p/cisl/iowa/abaker_carleton/prect/rearranged/unRnew.big.sz.1e-8.nc';

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
    %model_lat = ncread('/Users/alex/Dropbox/newCode/Data/b.e11.B20TRC5CNBDRD.f09_g16.030.cam.h1.TS.19200101-20051231.nc', 'lat');
    %model_lon = ncread('/Users/alex/Dropbox/newCode/Data/b.e11.B20TRC5CNBDRD.f09_g16.030.cam.h1.TS.19200101-20051231.nc', 'lon');
    model_lon(model_lon > 180) = model_lon(model_lon > 180) - 360;
    model_lon = [model_lon(146:288); model_lon(1:145)];
    N = size(orig_data('orig'), 3)

    nLon = size(model_lon, 1);
    nLat =  size(model_lat, 1);

    model_lat_edge = ncread(orig_data_path('orig'), 'slat');
    model_lon_edge = ncread(orig_data_path('orig'), 'slon');
    %model_lat_edge = ncread('/Users/alex/Dropbox/newCode/Data/b.e11.B20TRC5CNBDRD.f09_g16.030.cam.h1.TS.19200101-20051231.nc', 'slat');
    %model_lon_edge = ncread('/Users/alex/Dropbox/newCode/Data/b.e11.B20TRC5CNBDRD.f09_g16.030.cam.h1.TS.19200101-20051231.nc', 'slon');
    model_lon_edge(model_lon_edge > 180) = model_lon_edge(model_lon_edge > 180) - 360;
    model_lon_edge = [model_lon_edge(146:288); model_lon_edge(1:145)];
%%
    obs =  size(orig_data('orig'), 3);

    %% Run graphing scripts

    if strcmp(variable, 'TS')
        % golden, arctic, himalayas, pacific, west britain, antarctica,
        % brazil, indian, atlantic
        % 6, 76, 6, 23, 52
%        lats_vec = [40, 87, 36, 18, 6, 76, 6, 23, 52];
        %105, 75, 60, 18
%        lons_vec = [105, 142, 76, 179, 150, 75, 60, 73, 18];
%        for i = 1:length(lats_vec)
%            time_series_template_sz_seasonality_daily(diff_data('szAOn0.1'), 'szAOn0.1', model_lat, model_lon, save_dir, N, lats_vec(i), lons_vec(i));
%            time_series_template_zfp_seasonality_daily(diff_data('zfpATOL1e-1'), 'zfpATOL1e-1', model_lat, model_lon, save_dir, N, lats_vec(i), lons_vec(i));
            %time_series_template_zfp_seasonality_daily(diff_data('beta_zfpATOL1e-1'), 'beta_zfpATOL1e-1', model_lat, model_lon, save_dir, N);
%        end
%        time_series_template_zfp_seasonality_daily(diff_data('zfpATOL1e-1'), 'zfpATOL1e-1', model_lat, model_lon, save_dir, N, 192, 144);
%        time_series_template_sz_seasonality_daily(diff_data('szAOn0.1'), 'szA0n0.1', model_lat, model_lon, save_dir, N, 192, 144);
%      time_series_template_both_seasonality_daily(diff_data('szAOn0.1'), diff_data('zfpATOL1e-1'), 'szA0n0.1', 'zfpATOL1e-1', model_lat, model_lon, save_dir, N, 192, 144);

%        subaxis_template_mean(diff_data, algorithms, sz_tols, zfp_tols, save_dir, variable);
%        subaxis_template_mean(diff_data, algorithms, sz_tols, zfp_tols(5:8), save_dir, variable);
 %       sz_zoomed(diff_data('szAOn0.01'), 'szAOn0.01', save_dir, variable);
%        exploratory_analysis_ts(orig_data('orig'), save_dir, variable);
%%%%%%        mae_day(diff_data, algorithms, sz_tols, zfp_tols(1:4), nLon, nLat, save_dir);
 %      zfp_zoomed_single(model_lat_edge, model_lon_edge, diff_data('zfpATOL1e-2'), 'zfpATOL1e-2', save_dir, variable);
 %      sz_zoomed_single(model_lat_edge, model_lon_edge, diff_data('szAOn0.01'), 'szAOn0.01', save_dir, variable);
      %  zfp_zoomed(model_lat_edge, model_lon_edge, diff_data('beta_zfpATOL1e-2'), 'beta_zfpATOL1e-1', save_dir, variable);
%        zfp_zoomed(model_lat_edge, model_lon_edge, diff_data('round_zfpATOL1e-2'), 'round_zfpATOL1e-1', save_dir, variable);

        %zfp_block_partition_justBoxLevel(orig_data('orig'), diff_data('zfpATOL1e-2'), compressed_data('zfpATOL1e-2'), 'zfpATOL1e-2', obs, model_lat, model_lon, nLat, nLon, variable, save_dir);
        %zfp_block_partition_justBoxLevel(orig_data('orig'), diff_data('beta_zfpATOL1e-2'), compressed_data('beta_zfpATOL1e-2'), 'beta_zfpATOL1e-2', obs, model_lat, model_lon, nLat, nLon, variable, save_dir);
        %zfp_block_partition_justBoxLevel(orig_data('orig'), diff_data('round_zfpATOL1e-2'), compressed_data('round_zfpATOL1e-2'), 'round_zfpATOL1e-2', obs, model_lat, model_lon, nLat, nLon, variable, save_dir);

 %      subaxis_template_zscore(diff_data, algorithms, sz_tols, zfp_tols, save_dir, N, nLat, nLon, variable)
%        subaxis_template_zscore(diff_data, algorithms, sz_tols, zfp_tols(5:8), save_dir, N, nLat, nLon, variable)

%        zfp1e_4_TSerrors(diff_data('zfpATOL1e-4'), 'zfpATOL1e-4', save_dir)
      %  zfp1e_4_TSerrors(diff_data('beta_zfpATOL1e-4'), 'beta_zfpATOL1e-4', save_dir)
%        zfp1e_4_TSerrors(diff_data('round_zfpATOL1e-4'), 'round_zfpATOL1e-4', save_dir)
%days_vec = [1, 32, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335]
%mo_length_vec = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
%for i = 1:length(days_vec)
%        contrastVarianceEWTS_new(orig_data('orig'), compressed_data, algorithms, sz_tols, zfp_tols(1:4), nLat, nLon, obs, save_dir, days_vec(i), mo_length_vec(i))
%       contrastVarianceNSTS_new(orig_data('orig'), compressed_data, algorithms, sz_tols, zfp_tols, nLat, nLon, obs, save_dir, days_vec(i), mo_length_vec(i))
%end
%        contrastVarianceEWTS_new(orig_data('orig'), compressed_data, algorithms, sz_tols, zfp_tols(1:4), nLat, nLon, obs, save_dir, 1, 30)
%       contrastVarianceNSTS_new(orig_data('orig'), compressed_data, algorithms, sz_tols(1:4), zfp_tols(1:4), nLat, nLon, obs, save_dir, 1, 31)

%        contrastVarianceEWTS_new_single(orig_data('orig'), compressed_data, algorithms, {}, zfp_tols(1), nLat, nLon, obs, save_dir, 1, 31)

       subaxis_template_sd(diff_data, algorithms, sz_tols, zfp_tols, save_dir, variable)
%        subaxis_template_sd(diff_data, algorithms, sz_tols, zfp_tols(5:8), save_dir, variable)
        %%%TwoLocations_seasonalPlot_zfp_comparison(orig_data('orig'), compressed_data, algorithms, sz_tols, zfp_tols(1:4), model_lat, model_lon, save_dir, variable)
        %%%TwoLocations_seasonalPlot_zfp_comparison(orig_data('orig'), compressed_data, algorithms, sz_tols, zfp_tols(5:8), model_lat, model_lon, save_dir, variable)

         % 6, 76, 6, 23, 52
 %       lats_vec = [40, 87, 36, 18, 6, 76, 6, 23, 52];
        %105, 75, 60, 18
 %       lons_vec = [105, 142, 76, 179, 150, 75, 60, 73, 18];
 %       for i = 1:length(lats_vec)
%%%%%%%%            TwoLocations_seasonalPlot(orig_data('orig'), compressed_data, algorithms, sz_tols, zfp_tols(1:4), model_lat, model_lon, save_dir, variable, 192, 144)
%        end
        
%        corrCoefs_TS_new(orig_data('orig'), compressed_data, algorithms, sz_tols(1:3), zfp_tols(1:3), save_dir, N, nLat, nLon, variable)
%        corrCoefs_TS_new(orig_data('orig'), compressed_data, algorithms, sz_tols, zfp_tols(5:8), save_dir, N, nLat, nLon, variable)

%        spatial_plot_mae_max_day_new(diff_data, algorithms, sz_tols, zfp_tols(1:4), save_dir, nLat, nLon, variable)
%        spatial_plot_mae_max_day_new(diff_data, algorithms, sz_tols, zfp_tols(5:8), save_dir, nLat, nLon, variable)
%        spatial_plot_mae_min_day_new(diff_data, algorithms, sz_tols, zfp_tols(1:4), save_dir, nLat, nLon, variable)
%        spatial_plot_mae_min_day_new(diff_data, algorithms, sz_tols, zfp_tols(5:8), save_dir, nLat, nLon, variable)

%        AnnualPowerMaps_daily_new(diff_data, algorithms, sz_tols, zfp_tols, save_dir, model_lat, model_lon, N, nLat, nLon, variable)
%%%        AnnualPowerMaps_daily_new(diff_data, algorithms, sz_tols, zfp_tols(5:8), save_dir, model_lat, model_lon, N, nLat, nLon, variable)

%        subaxis_template_corr_day_new(diff_data, algorithms, sz_tols, zfp_tols(1:4), save_dir, model_lat, model_lon, N, nLat, nLon, variable)
%        subaxis_template_corr_day_new(diff_data, algorithms, sz_tols, zfp_tols(5:8), save_dir, model_lat, model_lon, N, nLat, nLon, variable)
%         table_day(orig_data, compressed_data, diff_data, algorithms, sz_tols, zfp_tols, save_dir, variable)%
 %       subaxis_template_mean_zfp_comparison(diff_data, algorithms, sz_tols, zfp_tols(1:4), save_dir, variable)
%        subaxis_template_sd_zfp_comparison(diff_data, algorithms, sz_tols, zfp_tols(1:4), save_dir, variable)
%        contrastVarianceEWTS_zfp_comparison(orig_data('orig'), compressed_data, algorithms, sz_tols, zfp_tols(1:4), nLat, nLon, obs, save_dir)
 %       corrCoefs_TS_zfp_comparison(orig_data('orig'), compressed_data, algorithms, sz_tols, zfp_tols(1:4), save_dir, N, nLat, nLon, variable)

        
    end
    if strcmp(variable, 'PRECT')
%        ExploratoryWork(orig_data('orig'), compressed_data, algorithms, sz_tols, zfp_tols, N, save_dir)
       pctRainy(orig_data('orig'), compressed_data, algorithms, N, save_dir);
%        makeTimeSeriesPlots(model_lat(144), model_lon(69), model_lat(84), model_lon(64), variable, data_dir, save_dir)
 %       dailyRainfall_oddsRain(orig_data('orig'), compressed_data, algorithms, N, save_dir)
%        dailyRainfall_negRain_zfp_comparison(orig_data('orig'), compressed_data, algorithms, N, save_dir)
    end
end