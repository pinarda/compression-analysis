%Plots Bias on Positive Rainfall Days
function[] = dailyRainfall_avgError(save_dir, data_dir)


    addpath('/glade/u/home/apoppick/MATLABPackages/b2r');
    addpath('/glade/u/home/apoppick/MATLABPackages/subaxis');

    wd = data_dir;

    variable = 'PRECT';

    alg_prefix_list = {'szAOn','zfpATOL'};

    tol_list_zfp = {'1e-5', '1e-8', '1e-11', '0'};
    tol_list_sz = {'1e-05', '1e-08', '1e-11'};

    %% read in lat / lon and original data
    model_lat = ncread([wd, lower(variable), '/orig/', ...
        'b.e11.B20TRC5CNBDRD.f09_g16.030.cam.h1.', ...
        variable, '.19200101-20051231.nc'], ...
        'lat');
    model_lon = ncread([wd, lower(variable), '/orig/', ...
        'b.e11.B20TRC5CNBDRD.f09_g16.030.cam.h1.', ...
        variable, '.19200101-20051231.nc'], ...
        'lon');
    model_lon(model_lon > 180) = model_lon(model_lon > 180) - 360;
    model_lon = [model_lon(146:288); model_lon(1:145)]; %reorganize longitudes

    orig_data = ncread([wd, lower(variable), '/orig/', ...
                'b.e11.B20TRC5CNBDRD.f09_g16.030.cam.h1.', ...
                variable, '.19200101-20051231.nc'], ...
                variable);
    orig_data = orig_data([146:288, 1:145], :, :); %reorganize longitudes

    threshold = 0.1 / (1000 * 60 * 60 * 24);

    orig_pos = orig_data;
    orig_pos(orig_data <= threshold) = nan;

    nLon = size(model_lon, 1);
    nLat =  size(model_lat, 1);
    N =  size(orig_data, 3);

    %% Calculate Statistics for Original Data

    for i=1:length(alg_prefix_list)
        alg_prefix = alg_prefix_list{i};
        if strcmp(alg_prefix, 'zfpATOL') 
            tol_list = tol_list_zfp;
            compress_alg = 'zfp';
        else
            tol_list = tol_list_sz;
            compress_alg = 'sz';
        end
        for j=1:length(tol_list)
            tol = tol_list{j};        
            compress_data_path = [wd, lower(variable), '/', char(alg_prefix), char(tol), '/b.e11.B20TRC5CNBDRD.f09_g16.030.cam.h1.PRECT.19200101-20051231.nc'];
            compress_data = ncread(compress_data_path, variable);
            compress_data = compress_data([146:288, 1:145], :, :); %reorganize longitudes
            compress_pos = compress_data;
            compress_pos(compress_data <= threshold) = nan;
            diff_data = orig_pos - compress_pos;
            diff_mean = mean(diff_data, 3, 'omitnan');
            overall_mean = mean(diff_data(:), 'omitnan');


            if(~isnan(overall_mean))
                ax(j,i) = subaxis(length(tol_list_zfp), length(alg_prefix_list), i, j, ...
                    'Spacing', 0, 'SpacingHoriz' , 0 , 'SpacingVert' , 0 , ...
                    'Padding', 0, 'PaddingRight', 0, 'PaddingLeft', 0 , 'PaddingTop', 0 , 'PaddingBottom', 0 , ...
                    'Margin', 0 , 'MarginRight', 0.1, 'MarginLeft', 0.1 , 'MarginTop', 0.1 , 'MarginBottom', 0);
                %         ax(j,i) = subaxis(length(tol_list),length(alg_prefix_list),i,j, 'Spacing', 0, 'SpacingHoriz' , 0 , 'SpacingVert' , 0 , ...
                %             'Padding', 0, 'PaddingRight', 0, 'PaddingLeft', 0 , 'PaddingTop', 0 , 'PaddingBottom', 0 , ...
                %             'Margin', 0 , 'MarginRight', 0.1, 'MarginLeft', 0.1 , 'MarginTop', 0.1 , 'MarginBottom', 0.02);
                axesm('robinson');
                set(gca, 'LooseInset', get(gca,'TightInset'));
                framem; tightmap;
                load coast;
                pcolorm([-90 90],[-180,180], diff_mean');
                plotm(lat,long, 'k');
                cbar_max(j,i) = prctile(abs(diff_mean(:)), 95);
                colormap(ax(j,i), flipud(b2r(-cbar_max(j,i), cbar_max(j,i))));
                C2 = colorbar('southoutside', 'FontSize', 5);
                title(['Overall Mean:',num2str(overall_mean,2)], 'FontSize', 6)
                if strcmp(alg_prefix, 'szAOn')
                    text(-4.5, 0, char(tol));
                end
                if (j == 1)
                    text(0, 2.5, upper(compress_alg),'FontSize', 12','interpreter','latex');
                end
            end
        end
    end

    cbar_lim = max(cbar_max,[],2);

    for i=1:length(alg_prefix_list)
        alg_prefix = alg_prefix_list{i};
        if strcmp(alg_prefix, 'zfpATOL') 
            tol_list = tol_list_zfp;
            compress_alg = 'zfp';
        else
            tol_list = tol_list_sz;
            compress_alg = 'sz';
        end
        for j=1:length(tol_list)
            set(ax(j,i), 'CLim', [-cbar_lim(j), cbar_lim(j)]);
        end
    end

    set(gcf,'Units', 'inches', 'Position', [0 0 5 6], 'PaperUnits','inches','PaperPosition', [0 0 5 6])
    save_path = strcat( save_dir, 'PRECT_avgError.png');
    print(save_path, '-dpng', '-r300')
end