clear *

addpath('/glade/u/home/apoppick/MATLABPackages/b2r');
addpath('/glade/u/home/apoppick/MATLABPackages/subaxis');
addpath('/glade/u/home/apoppick/MATLABPackages/freezeColors');
addpath('/glade/u/home/apoppick/MATLABPackages/cm_and_cb_utilities');

wd = '/glade/p/cisl/iowa/abaker_carleton/';

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
negRain_orig = (orig_data < 0);
probNegRain_orig = sum(negRain_orig, 3)./N;

probRain_orig = (sum(rainDays_orig, 3)+1)./(N+2);
%note: I'm adding one rainy and one dry day day to avoid dividing 
%by zero below.
oddsRain_orig = probRain_orig./(1-probRain_orig);

figure(1)
ax_orig_negRain = subaxis(5,2,1,1, 'Spacing', 0, 'SpacingHoriz' , 0 , 'SpacingVert' , 0 , ... 
            'Padding', 0, 'PaddingRight', 0, 'PaddingLeft', .05 , 'PaddingTop', 0.01 , 'PaddingBottom', 0 , ... 
            'Margin', 0 , 'MarginRight', 0.02, 'MarginLeft', 0.3 , 'MarginTop', 0.1 , 'MarginBottom', 0.02);
axesm('robinson');
set(gca, 'LooseInset', get(gca,'TightInset'));
framem; tightmap;
load coast;
pcolorm([-90 90],[-180,180],probNegRain_orig')
plotm(lat,long, 'k');
cbar_max_orig_negRain = max(probNegRain_orig(:));
colormap(ax_orig_negRain, w2k(0, cbar_max_orig_negRain));
C2 = colorbar('southoutside', 'FontSize', 5);
text(-1, 2, 'Original');
set(figure(1),'Units', 'inches', 'Position', [0 0 4 6], 'PaperUnits','inches','PaperPosition', [0 0 4 6])
        

figure(2)
ax_orig = subaxis(length(tol_list_zfp) + 1, 3, ...
    2, 1, 'Spacing', 0, 'SpacingHoriz' , 0 , 'SpacingVert' , 0 , ...
    'Padding', 0, 'PaddingRight', 0, 'PaddingLeft', 0 , 'PaddingTop', 0 , ...
    'PaddingBottom', 0 , 'Margin', 0 , 'MarginRight', 0.1, 'MarginLeft', 0.1 , ...
    'MarginTop', 0.1 , 'MarginBottom', 0.05);
axesm('robinson');
set(gca, 'LooseInset', get(gca,'TightInset'));
framem; tightmap;
load coast;
pcolorm([-90 90],[-180,180],log10(oddsRain_orig)')
plotm(lat,long, 'k');
cbar_max_orig = max(abs(log10(oddsRain_orig(:))));
colormap(ax_orig, flipud(b2r(-cbar_max_orig, cbar_max_orig)));
C2 = colorbar('southoutside', 'FontSize', 5);
title('log10(odds)')
text(-1.4, 2.5, 'Original', 'FontSize', 25)


%% Analyze Compressed Data

cbar_max_odds = zeros(length(tol_list_zfp),length(alg_prefix_list));
cbar_max_OR = zeros(length(tol_list_zfp),length(alg_prefix_list));
cbar_max_NegRain = zeros(length(tol_list_zfp),length(alg_prefix_list));
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
        
        %% Look at Negative Rainfall Days
               
        probNegRain = sum(compress_data < 0, 3)./N;
        
        % finish
        
%         save_path = ['/glade/work/apoppick/compress_plots/PRECT_odds/', alg_prefix, tol_list{tol_j}, variable, '_NegRain.png'];
%         print(save_path, '-dpng')
%         close
        
        %% Look at Percent of Rainy Days
        probRain_compress = (sum(compress_data > 0, 3)+1)./(N+2);
        %note: I'm adding one rainy and one dry day day to avoid dividing 
        %by zero below.
        
        oddsRain_compress = probRain_compress./(1-probRain_compress);
        
        odds_ratio = (probRain_compress./(1-probRain_compress)) ./ ...
                     (probRain_orig./(1-probRain_orig));

        figure(1)
        ax_NegRain(tol_j,alg_i) = subaxis(length(tol_list_zfp) + 1, length(alg_prefix_list),alg_i,tol_j+1, 'Spacing', 0, 'SpacingHoriz' , 0 , 'SpacingVert' , 0 , ... 
            'Padding', 0, 'PaddingRight', 0, 'PaddingLeft', 0 , 'PaddingTop', 0 , 'PaddingBottom', 0 , ... 
            'Margin', 0 , 'MarginRight', 0.1, 'MarginLeft', 0.1 , 'MarginTop', 0.1 , 'MarginBottom', 0.02);;
        axesm('robinson');
        set(gca, 'LooseInset', get(gca,'TightInset'));
        framem; tightmap;
        load coast;
        pcolorm([-90 90],[-180,180],probNegRain')
        plotm(lat,long, 'k');
        cbar_max_NegRain(tol_j,alg_i) = max(max(probNegRain(:)),0.01);
        colormap(ax_NegRain(tol_j,alg_i), w2k(0, cbar_max_NegRain(tol_j,alg_i)));
        C2 = colorbar('southoutside', 'FontSize', 5);
        
        if strcmp(alg_prefix, 'szAOn') || strcmp(tol, '0')
            text(-5, 0, char(tol));
        end
        if strcmp(tol, '1e-2') || strcmp(tol, '0.01')
            text(0, 2, compress_alg);
        end

        % odds ratio array
        
        figure(2)       
        
        ax_Odds(tol_j,alg_i) = subaxis(length(tol_list_zfp) + 1, length(alg_prefix_list)*2, ...
            alg_i*2-1, tol_j+1, 'Spacing', 0, 'SpacingHoriz' , 0 , 'SpacingVert' , 0 , ... 
            'Padding', 0, 'PaddingRight', 0, 'PaddingLeft', 0 , 'PaddingTop', 0 , ...
            'PaddingBottom', 0 , 'Margin', 0 , 'MarginRight', 0.1, 'MarginLeft', 0.1 , ...
            'MarginTop', 0.1 , 'MarginBottom', 0.02);
        
        axesm('robinson');
        set(gca, 'LooseInset', get(gca,'TightInset'));
        framem; tightmap;
        load coast;
        pcolorm([-90 90],[-180,180],log10(oddsRain_compress)')
        plotm(lat,long, 'k');
        cbar_max_odds(tol_j,alg_i) = prctile(abs(log10(oddsRain_compress(:))), 99);
        colormap(ax_Odds(tol_j,alg_i), flipud(b2r(-cbar_max_odds(tol_j,alg_i), cbar_max_odds(tol_j,alg_i))));
        C2 = colorbar('southoutside', 'FontSize', 10);
        
        if strcmp(tol, '1e-2') || strcmp(tol, '0.01')
            text(2.5, 2, compress_alg, 'FontSize', 25);
            title('log10(odds)')
        end
        
        if strcmp(alg_prefix, 'szAOn') || strcmp(tol, '0')
            text(-4.5, 0, char(tol), 'FontSize', 15);
        end
        
        ax_OR(tol_j,alg_i) = subaxis(length(tol_list_zfp) + 1, length(alg_prefix_list)*2, ...
            alg_i*2, tol_j+1, 'Spacing', 0, 'SpacingHoriz' , 0 , 'SpacingVert' , 0 , ... 
            'Padding', 0, 'PaddingRight', 0, 'PaddingLeft', 0 , 'PaddingTop', 0 , ...
            'PaddingBottom', 0 , 'Margin', 0 , 'MarginRight', 0.1, 'MarginLeft', 0.1 , ...
            'MarginTop', 0.1 , 'MarginBottom', 0.02);
        
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
        C2 = colorbar('southoutside', 'FontSize', 10);
        
        disp([alg_prefix, tol_list{tol_j}])
        toc
    end
end

figure(1)
cbar_lim_negRain = max(cbar_max_NegRain,[],2);
for alg_i=1:length(alg_prefix_list)
    for tol_j=1:length(tol_list)
        if ~(alg_i == 1 && tol_j == length(tol_list_zfp))
            set(ax_NegRain(tol_j,alg_i), 'CLim', [0, cbar_lim_negRain(tol_j)]);
        end
    end
end


figure(2)
cbar_lim_odds = max(cbar_max_odds,[],2);
cbar_lim_OR = max(cbar_max_OR,[],2);

for alg_i=1:length(alg_prefix_list)
    for tol_j=1:length(tol_list_zfp)
        if ~(alg_i == 1 && tol_j == length(tol_list_zfp))
            set(ax_Odds(tol_j,alg_i), 'CLim', [-cbar_lim_odds(tol_j), cbar_lim_odds(tol_j)]);
            set(ax_OR(tol_j,alg_i), 'CLim', [-cbar_lim_OR(tol_j), cbar_lim_OR(tol_j)]);
        end
    end
end

save_path_negRain = '/glade/work/apoppick/compress_plots/PRECT_odds/NegRain_array.png';
print(figure(1), save_path_negRain, '-dpng')
close

save_path_OR = '/glade/work/apoppick/compress_plots/PRECT_odds/OR_array.png';
print(figure(2), save_path_OR, '-dpng')
close