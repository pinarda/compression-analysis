%data = ncread('/Users/alex/Dropbox/NewComStatEval/Data/ts/szAOn0.1/b.e11.B20TRC5CNBDRD.f09_g16.030.cam.h1.TS.19200101-20051231.nc', 'TS', [1 1 1], [Inf Inf 3], [1, 1, 1]);
%diff_data = ncread('/Users/alex/Dropbox/newCode/data/TS.diff-szAOn0.1.nc', 'TS', [1 1 1], [Inf Inf 3], [1, 1, 1]);
fake_orig_data = ncread('/Users/alex/Dropbox/NewComStatEval/Data/ts/szAOn0.1/b.e11.B20TRC5CNBDRD.f09_g16.030.cam.h1.TS.19200101-20051231.nc', 'lat', [1 1 1], [Inf Inf 3], [1, 1, 1])

%nccreate('/Users/alex/Dropbox/newCode/data/b.e11.B20TRC5CNBDRD.f09_g16.030.cam.h1.TS.19200101-20051231_test.nc', 'TS', 'Dimensions', {'r' 288 'c' 192 't' 3});
%nccreate('/Users/alex/Dropbox/newCode/data/TS.diff-szAOn0.1_new.nc', 'TS', 'Dimensions', {'r' 288 'c' 192 't' 3});
nccreate('/Users/alex/Dropbox/NewComStatEval/Data/ts/szAOn0.1/b.e11.B20TRC5CNBDRD.f09_g16.030.cam.h1.TS.19200101-20051231.nc', 'TS', 'Dimensions', {'r' 288 'c' 192 't' 3});

%ncwrite('/Users/alex/Dropbox/newCode/data/b.e11.B20TRC5CNBDRD.f09_g16.030.cam.h1.TS.19200101-20051231_test.nc', 'TS', data);
ncwrite('/Users/alex/Dropbox/newCode/data/TS.diff-szAOn0.1_new.nc', 'TS', diff_data);

%data_new = ncread('/Users/alex/Dropbox/newCode/data/b.e11.B20TRC5CNBDRD.f09_g16.030.cam.h1.TS.19200101-20051231_test.nc', 'TS');
diff_data_new = ncread('/Users/alex/Dropbox/newCode/data/TS.diff-szAOn0.1_new.nc', 'TS');