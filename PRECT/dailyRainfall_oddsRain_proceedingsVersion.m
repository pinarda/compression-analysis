%Plots odds ratio of positive rainfall

clear *

addpath('/glade/u/home/apoppick/MATLABPackages/b2r');
addpath('/glade/u/home/apoppick/MATLABPackages/subaxis');
addpath('/glade/u/home/apoppick/MATLABPackages/freezeColors');
addpath('/glade/u/home/apoppick/MATLABPackages/cm_and_cb_utilities');

wd = '/glade/p_old/tdd/asap/abaker_carleton/';

variable = 'PRECT';

alg_prefix_list = {'szAOn','zfpATOL'};

tol_list_zfp = {'1e-2', '1e-5', '1e-8', '1e-11', '0'};
%Not doing 0.0001 and 1e-05 because zscores are all zero
tol_list_sz = {'0.01', '1e-05', '1e-08', '1e-11'};

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

nLon = size(model_lon, 1);
nLat =  size(model_lat, 1);
N =  size(orig_data, 3);

%% Calculate Statistics for Original Data

rainDays_orig = (orig_data > 0);
probRain_orig = (sum(rainDays_orig, 3)+1)./(N+2);
%note: I'm adding one rainy and one dry day day to avoid dividing 
%by zero below.
oddsRain_orig = probRain_orig./(1-probRain_orig);

set(gcf,'Units', 'inches', 'Position', [0 0 7 5.5], 'PaperUnits','inches','PaperPosition', [0 0 7 5.5]) 

ax_orig = subaxis(length(tol_list_zfp), length(alg_prefix_list)*2, ...
            1, length(tol_list_zfp), 'Spacing', 0, 'SpacingHoriz' , 0 , 'SpacingVert' , 0 , ... 
            'Padding', 0, 'PaddingRight', 0, 'PaddingLeft', 0.05 , 'PaddingTop', 0.01 , 'PaddingBottom', 0 , ... 
            'Margin', 0 , 'MarginRight', 0.03, 'MarginLeft', 0.1 , 'MarginTop', 0.1 , 'MarginBottom', 0.025);
        
axesm('robinson');
set(gca, 'LooseInset', get(gca,'TightInset'));
framem; tightmap;
load coast;
pcolorm([-90 90],[-180,180],log10(oddsRain_orig)')
plotm(lat,long, 'k');
cbar_max_orig = max(abs(log10(oddsRain_orig(:))));
colormap(ax_orig, flipud(b2r(-cbar_max_orig, cbar_max_orig)));
 originalSize = get(gca, 'Position');
C2 = colorbar('southoutside', 'FontSize', 5);
set(gca, 'Position', originalSize);
text(-5, 0, 'orig', 'FontSize', 10);


%% Analyze Compressed Data

cbar_max_odds = zeros(length(tol_list_zfp),length(alg_prefix_list));
cbar_max_OR = zeros(length(tol_list_zfp),length(alg_prefix_list));

for alg_i = 1:2
    
    alg_prefix = alg_prefix_list{alg_i};
    if strcmp(alg_prefix, 'zfpATOL') 
        tol_list = tol_list_zfp;
        compress_alg = 'zfp';
    else
        tol_list = tol_list_sz;
        compress_alg = 'sz';
    end
    for tol_j = 1:length(tol_list) %non-lossless tolerances
        tol = tol_list{tol_j};
        tic
        %% Read in Compressed Data
        compress_data = ncread([wd, lower(variable), '/', alg_prefix, tol_list{tol_j}, '/', ...
            'b.e11.B20TRC5CNBDRD.f09_g16.030.cam.h1.', ...
            variable, '.19200101-20051231.nc'], ...
            variable);
        compress_data = compress_data([146:288, 1:145], :, :); %reorganize longitudes
        
        %% Look at Percent of Rainy Days
        probRain_compress = (sum(compress_data > 0, 3)+1)./(N+2);
        %note: I'm adding one rainy and one dry day day to avoid dividing 
        %by zero below.
        
        oddsRain_compress = probRain_compress./(1-probRain_compress);
        
        odds_ratio = (probRain_compress./(1-probRain_compress)) ./ ...
                     (probRain_orig./(1-probRain_orig));
        
        ax_Odds(tol_j,alg_i) = subaxis(length(tol_list_zfp), length(alg_prefix_list)*2, ...
            alg_i*2-1, tol_j, ...
            'Spacing', 0, 'SpacingHoriz' , 0 , 'SpacingVert' , 0 , ... 
            'Padding', 0, 'PaddingRight', 0, 'PaddingLeft', 0.05 , 'PaddingTop', 0.01 , 'PaddingBottom', 0 , ... 
            'Margin', 0 , 'MarginRight', 0.03, 'MarginLeft', 0.1 , 'MarginTop', 0.1 , 'MarginBottom', 0.025);
        
        
        axesm('robinson');
        set(gca, 'LooseInset', get(gca,'TightInset'));
        framem; tightmap;
        load coast;
        pcolorm([-90 90],[-180,180],log10(oddsRain_compress)')
        plotm(lat,long, 'k');
        cbar_max_odds(tol_j,alg_i) = prctile(abs(log10(oddsRain_compress(:))), 99);
        colormap(ax_Odds(tol_j,alg_i), flipud(b2r(-cbar_max_odds(tol_j,alg_i), cbar_max_odds(tol_j,alg_i))));
        
        if tol_j == length(tol_list) && strcmp(alg_prefix, 'zfpATOL')
            originalSize = get(gca, 'Position');
            C2 = colorbar('southoutside', 'FontSize', 5);
            set(gca, 'Position', originalSize);
        end
        
        if strcmp(tol, '1e-2') || strcmp(tol, '0.01')
            text(3, 3.25, compress_alg, 'FontSize', 15);
            title('log10(odds)')
        end
        
        if strcmp(alg_prefix, 'szAOn')
            text(-5, 0, char(tol), 'FontSize', 10);
        end
        
        if strcmp(tol, '0')
            text(-6, 0, '"lossless"', 'FontSize', 10);
        end
        
        ax_OR(tol_j,alg_i) = subaxis(length(tol_list_zfp), length(alg_prefix_list)*2, ...
            alg_i*2, tol_j, 'Spacing', 0, 'SpacingHoriz' , 0 , 'SpacingVert' , 0 , ... 
            'Padding', 0, 'PaddingRight', 0, 'PaddingLeft', 0.05 , 'PaddingTop', 0.01 , 'PaddingBottom', 0 , ... 
            'Margin', 0 , 'MarginRight', 0.03, 'MarginLeft', 0.1 , 'MarginTop', 0.1 , 'MarginBottom', 0.025);
        
        if strcmp(tol, '1e-2') || strcmp(tol, '0.01')
            title('log10(odds ratio)')
        end
        
        axesm('robinson');
        set(gca, 'LooseInset', get(gca,'TightInset'));
        framem; tightmap;
        load coast;
        pcolorm([-90 90],[-180,180],log10(odds_ratio)')
        plotm(lat,long, 'k');
        cbar_max_OR(tol_j,alg_i) = prctile(abs(log10(odds_ratio(:))), 99);
        colormap(ax_OR(tol_j,alg_i), flipud(b2r(-cbar_max_OR(tol_j,alg_i), cbar_max_OR(tol_j,alg_i))));
        
        if tol_j == length(tol_list)
            originalSize = get(gca, 'Position');
            C2 = colorbar('southoutside', 'FontSize', 5);
            set(gca, 'Position', originalSize);
        end
        
        disp([alg_prefix, tol_list{tol_j}])
        toc
    end
end


cbar_lim_odds = max(cbar_max_odds(:));
cbar_lim_OR = max(cbar_max_OR(:));

set(ax_orig, 'CLim', [-cbar_lim_odds cbar_lim_odds])
for alg_i=1:length(alg_prefix_list)
    for tol_j=1:length(tol_list_zfp)
        if ~(alg_i == 1 && tol_j == length(tol_list_zfp))
            set(ax_Odds(tol_j,alg_i), 'CLim', [-cbar_lim_odds cbar_lim_odds]);
            set(ax_OR(tol_j,alg_i), 'CLim', [-cbar_lim_OR, cbar_lim_OR]);
        end
    end
end

save_path_OR = '/glade/work/apoppick/compress_plots/PRECT_odds/OR_array_new_AllisonPlot.png';
print(save_path_OR, '-dpng', '-r300')
close