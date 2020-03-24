oldclear *

addpath('/glade/u/home/apoppick/MATLABPackages/b2r');
addpath('/glade/u/home/apoppick/MATLABPackages/subaxis');
addpath('/glade/u/home/apoppick/MATLABPackages/freezeColors');
addpath('/glade/u/home/apoppick/MATLABPackages/cm_and_cb_utilities');

wd = '/glade/p_old/tdd/asap/abaker_carleton/';

variable = 'PRECT';

alg_prefix_list = {'zfpATOL','szAOn'};

tol_list_zfp = {'1e-1', '1e-2', '1e-3', '1e-4', '1e-5', '1e-6', '1e-7', '1e-8', '1e-9', '1e-10', '1e-11', '0'};
%Not doing 0.0001 and 1e-05 because zscores are all zero
tol_list_sz = {'0.1', '0.01', '0.001', '0.0001', '1e-05', '1e-06', '1e-07', '1e-08', '1e-09', '1e-10', '1e-11'};

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

probRain_orig = (sum(rainDays_orig, 3)+1)./(N+2);
%note: I'm adding one rainy and one dry day day to avoid dividing 
%by zero below.
oddsRain_orig = probRain_orig./(1-probRain_orig);


%% Analyze Compressed Data

for alg_i = 1:2
    
    alg_prefix = alg_prefix_list{alg_i};
    if strcmp(alg_prefix, 'zfpATOL') 
        tol_list = tol_list_zfp;
    else
        tol_list = tol_list_sz;
    end
    for tol_j = 1:length(tol_list)
        tic
        %% Read in Compressed Data
        compress_data = ncread([wd, lower(variable), '/', alg_prefix, tol_list{tol_j}, '/', ...
            'b.e11.B20TRC5CNBDRD.f09_g16.030.cam.h1.', ...
            variable, '.19200101-20051231.nc'], ...
            variable);
        compress_data = compress_data([146:288, 1:145], :, :); %reorganize longitudes
        
        %% Look at Negative Rainfall Days
               
        probNegRain = sum(compress_data < 0, 3)./N;
        axesm('robinson')
        set(gca, 'LooseInset', get(gca,'TightInset'))
        framem; tightmap;
        load coast
        pcolorm([-90, 90],[-180, 180], probNegRain')
        plotm(lat,long)
        colormap(w2k(0,max(max(probNegRain(:)), 0.01)));        
        title([alg_prefix, tol_list{tol_j}]);
        colorbar('SouthOutside')
        
        save_path = ['/glade/work/apoppick/compress_plots/PRECT_odds/', alg_prefix, tol_list{tol_j}, variable, '_NegRain.png'];
        print(save_path, '-dpng')
        close
        
        %% Look at Percent of Rainy Days
        probRain_compress = (sum(compress_data > 0, 3)+1)./(N+2);
        %note: I'm adding one rainy and one dry day day to avoid dividing 
        %by zero below.
        
%         isRain_compress = (compress_data > 0);
%         isRainAvg = squeeze(mean(mean(isRain_compress,1),2));
%         unique(isRainAvg)
%         
        oddsRain_compress = probRain_compress./(1-probRain_compress);
        
        odds_ratio = (probRain_compress./(1-probRain_compress)) ./ ...
                     (probRain_orig./(1-probRain_orig));
                 
        subaxis(1,3,1, 'Spacing', 0.0, 'Padding', 0.01, 'Margin', 0);
        axesm('robinson')
        set(gca, 'LooseInset', get(gca,'TightInset'))
        framem; tightmap;
        load coast
        pcolorm([-90, 90],[-180, 180], log10(odds_ratio'))
        plotm(lat,long)
        colormap(flipud(b2r(-max(abs(log10(odds_ratio(:)))), max(abs(log10(odds_ratio(:)))))));        
        freezeColors
        
        subaxis(1,3,2, 'Spacing', 0.0, 'Padding', 0.01, 'Margin', 0);
        axesm('robinson')
        set(gca, 'LooseInset', get(gca,'TightInset'))
        framem; tightmap;
        load coast
        pcolorm([-90, 90],[-180, 180], log10(oddsRain_orig'))
        plotm(lat,long)
        colormap(flipud(b2r(-max(abs(log10(oddsRain_orig(:)))), max(abs(log10(oddsRain_orig(:)))))));        
        freezeColors
        
        subaxis(1,3,3, 'Spacing', 0.0, 'Padding', 0.01, 'Margin', 0);
        axesm('robinson')
        set(gca, 'LooseInset', get(gca,'TightInset'))
        framem; tightmap;
        load coast
        pcolorm([-90, 90],[-180, 180], log10(oddsRain_compress'))
        plotm(lat,long)
        colormap(flipud(b2r(-max(abs(log10(oddsRain_compress(:)))), max(abs(log10(oddsRain_compress(:)))))));        
        freezeColors
        title([alg_prefix, tol_list{tol_j}]);
        
        %add colorbar legends
        axes('Position', [0.02 0.15 0.3 0.2], 'Visible', 'off'); 
        colormap(flipud(b2r(-max(abs(log10(odds_ratio(:)))), max(abs(log10(odds_ratio(:)))))))
        C1 = colorbar('North');
        xlabel(C1, 'log10(Odds Ratio), Compressed/Orig')
        
        axes('Position', [0.35 0.15 0.3 0.2], 'Visible', 'off'); 
        colormap(flipud(b2r(-max(abs(log10(oddsRain_orig(:)))), max(abs(log10(oddsRain_orig(:)))))));        
        C2 = colorbar('North'); 
        xlabel(C2, 'log10(Odds), Original')
        
        axes('Position', [0.68 0.15 0.3 0.2], 'Visible', 'off');
        colormap(flipud(b2r(-max(abs(log10(oddsRain_orig(:)))), max(abs(log10(oddsRain_orig(:)))))));        
        C3 = colorbar('North');
        xlabel(C3, 'log10(Odds), Compressed')
        
        save_path = ['/glade/work/apoppick/compress_plots/PRECT_odds/', alg_prefix, tol_list{tol_j}, variable, '_OR.png'];
        print(save_path, '-dpng')
        close
       
        disp([alg_prefix, tol_list{tol_j}])
        toc
    end
end