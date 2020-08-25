%Creates a table with the summary statistics of TS errors for the technote. 
%Includes mean error, mean absolute error, and root mean squared error from 
%left to right. Includes both zfp and sz compression algorithms at all error
%tolerances. 
function[] = table_day(orig_data, compress_datas, diff_datas, alg_prefix_list, tol_list_sz, tol_list_zfp, save_dir, variable)
k = 1;
compression_array = {};
mean_error_array = [];
mae_array = [];
rmse_array = [];
mean_ts_array = [];
max_array = [];
for i=1:length(alg_prefix_list)
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
    for j=1:length(tol_list)
        tol = tol_list{j};
        diff_data = diff_datas(strcat(alg_prefix, tol));
        if ((strcmp(tol, '1e-05')) || (strcmp(tol, '1e-06')))
            tol2 = [tol(3), tol(5)];
        else
            tol2 = tol;
        end
        diff_data = diff_datas(strcat(alg_prefix, tol));
        compress_data = compress_datas(strcat(alg_prefix, tol));
        format longE
        mean_ts = mean(compress_data(:));
        mean_error = mean(diff_data(:));
        mae = mean(abs(diff_data(:)));
        rmse = sqrt(mean(diff_data(:).^2));
        max_error = max(abs(diff_data(:)));
        compression_info = [compress_alg, tol];
        mean_ts_array = [mean_ts_array, mean_ts];
        mean_error_array = [mean_error_array, mean_error];
        mae_array = [mae_array, mae];
        rmse_array = [rmse_array, rmse];
        compression_array{k} =  compression_info;
        max_array = [max_array, max_error];
        k = k+1;
    end
end

input.dataFormat = {'%.15f'}
input.data =  [mean_ts_array(:) mean_error_array(:) mae_array(:) rmse_array(:), max_array(:)];
input.tableColLabels = {'Mean', 'Mean Error','MAE','RMSE', 'Max Error'};
input.tableRowLabels = compression_array;
input.tableCaption = 'Summary Statistics of TS';
input.tableLabel = 'TStable';

latex = latexTable(input);
%%
fid=fopen('tstable.tex','w');
[nrows,ncols] = size(latex);
for row = 1:nrows
    fprintf(fid,'%s\n',latex{row,:});
end
%%
fclose(fid);
