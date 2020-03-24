%   v = 'TS' or 'TSMX'
%   algorithms = {'szAOn', 'zfpATOL'}
%   sz_tols = {'1.0', '0.5', '0.1', '0.01'};
%   zfp_tols = {'1.0', '0.5', '1e-1', '1e-2'};
function [orig_data_path, diff_data_paths, compressed_data_paths] = get_data_paths(v, algorithms, tols_sz, tols_zfp, data_dir)

    variable = v;
    alg_prefix_list = algorithms;
    tol_list_sz = tols_sz;
    tol_list_zfp = tols_zfp;
    orig_data_path = containers.Map;
    diff_data_paths = containers.Map;
    compressed_data_paths = containers.Map;
    
    %% Get data paths
    if strcmp(variable, 'TSMX')
        orig_data_path('orig') = [data_dir, lower(variable), '/orig/', 'b.e11.B20TRC5CNBDRD.f09_g16.030.cam.h0.', variable, '.192001-200512.nc'];
    end
    if strcmp(variable, 'TS')
        orig_data_path('orig') = [data_dir, lower(variable), '/orig/', 'b.e11.B20TRC5CNBDRD.f09_g16.030.cam.h1.', variable, '.19200101-20051231.nc'];
    end
    if strcmp(variable, 'PRECT')
        orig_data_path('orig') = [data_dir, lower(variable), '/orig/', 'b.e11.B20TRC5CNBDRD.f09_g16.030.cam.h1.', variable, '.19200101-20051231.nc'];
    end

    orig_data_path('orig')

    for i=1:length(alg_prefix_list)
        alg_prefix = alg_prefix_list{i};
        if strcmp(alg_prefix, 'zfpATOL') 
            tol_list = tol_list_zfp;
        elseif strcmp(alg_prefix, 'beta_zfpATOL')
            tol_list = tol_list_zfp;
        elseif strcmp(alg_prefix, 'round_zfpATOL')
            tol_list = tol_list_zfp;
        else
            tol_list = tol_list_sz;
        end
        alg_prefix = alg_prefix_list{i};
        for j=1:length(tol_list)
            tol = tol_list{j};
            diff_data_paths(strcat(alg_prefix, tol)) = [data_dir, lower(variable), '/', char(alg_prefix), char(tol), '/', ...
                variable, '.diff-', char(alg_prefix), char(tol), '.nc'];
            if strcmp(alg_prefix, 'beta_zfpATOL') 
                diff_data_paths(strcat(alg_prefix, tol)) = [data_dir, 'zfp_beta', '/', lower(variable), '/', 'zfpATOL', char(tol), '/', ...
                    variable, '.diff-', 'zfpATOL', char(tol), '.nc'];
            end
            if strcmp(alg_prefix, 'round_zfpATOL') 
                diff_data_paths(strcat(alg_prefix, tol)) = [data_dir, 'zfp_round', '/', lower(variable), '/', 'zfp_ATOL', char(tol), '/', ...
                    variable, '.diff-', 'zfpATOL', char(tol), '.nc'];
            end
            compressed_data_paths(strcat(alg_prefix, tol)) = [data_dir, lower(variable), '/', char(alg_prefix), char(tol), '/', ...
                'b.e11.B20TRC5CNBDRD.f09_g16.030.cam.h1.', variable, '.19200101-20051231.nc'];
            if strcmp(alg_prefix, 'beta_zfpATOL') 
                compressed_data_paths(strcat(alg_prefix, tol)) = [data_dir, 'zfp_beta', '/', lower(variable), '/', 'zfpATOL', char(tol), '/', ...
                    'b.e11.B20TRC5CNBDRD.f09_g16.030.cam.h1.', variable, '.19200101-20051231.nc'];
            end
            if strcmp(alg_prefix, 'round_zfpATOL') 
                compressed_data_paths(strcat(alg_prefix, tol)) = [data_dir, 'zfp_round', '/', lower(variable), '/', 'zfp_ATOL', char(tol), '/', ...
                    'b.e11.B20TRC5CNBDRD.f09_g16.030.cam.h1.', variable, '.19200101-20051231.nc'];
            end
        end
    end
    
    
end
