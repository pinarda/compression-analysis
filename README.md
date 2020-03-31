# compression-analysis

The code in this repository is used for generating the plots in "A Statistical Analysis of Lossily Compressed Climate Model Data," by authors Andrew Poppick, Joseph Nardi, Noah Feldman, Allison H. Baker, Alexander Pinard, Dorit M. Hammerling. The original, compressed, and diff data files are located in subdirectories at cheyenne.ucar.edu:/glade/p/cisl/iowa/abaker_carleton/. The CESM data files can be found at https://doi.org/10.5065/d6j101d1.

Generating the plots requires that the absolute paths of the matlab packages, data directory, save directory, and directory of the TS/ and PRECT/ folders containing the graphing scripts be specified in build_graphs.m. get_data_paths expects the data directory to look as follows:

DATA_DIR/VAR/ALGORITHMANDTOLERANCE/

where DATA_DIR is the specified data directory, VAR is 'TS' or 'PRECT', ALGORITHMANDTOLERANCE is 'szAOn' or 'zfpATOL' followed by the tolerance level, without any spaces. The diff data NetCDF file in this directory is called 'TS.diff-ALGORITHMANDTOLERANCE.nc', and the compressed data NetCDF file is called 'b.e11.B20TRC5CNBDRD.f09_g16.030.cam.h1.ALGORITHM.19200101-20051231.nc', where ALGORITHM is either 'szAOn' or 'zfpATOL'. 

Once this is done, run the file build_graph.m which will handle loading the data, plotting, and generating data for the tables.
