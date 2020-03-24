% Creates a plot to look at the mean errors for TS for the lower error 
% tolerances for zfp. This only includes an error tolerance of 1e-4 for
% zfp.
function[] = zfp1_e_4_TSerrors(diff_data, diff_data_name, save_dir)

    mean_diff  = mean(diff_data,3);
    MAE = mean(abs(diff_data),3);
    mean(MAE(:) == 0)

    uValues = unique(diff_data(:));
    [hCounts, hEdges] = histcounts(diff_data(:), length(uValues));

    hCounts./sum(hCounts)
    uValues

    axesm('robinson');
    set(gca, 'LooseInset', get(gca,'TightInset'));
    framem; tightmap;
    load coast;
    pcolorm([-90 90],[-180,180],mean_diff')
    plotm(lat,long, 'k');
    colormap(flipud(b2r(-max(abs(mean_diff(:))), max(abs(mean_diff(:))))));
    C2 = colorbar('southoutside');

    save_path = [save_dir, 'meanError', diff_data_name, '.png'];
    print(save_path, '-dpng', '-r300')
    close
end