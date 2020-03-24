%   v = 'TS' or 'TSMX'
%   orig_data_path, a string
%   diff_data_paths, a containers.Map with string values 
%   compressed_data_paths, a containers.Map with string values 
function [data] = load_data(v, data_paths)

    variable = v;
    data = containers.Map;

    %% read in diff data
    if(not(isempty(data_paths)))
        for i=keys(data_paths)
            data(char(i)) = ncread(data_paths(char(i)), variable);
            temp = data(char(i));
            data(char(i)) = temp([146:288, 1:145], :, :); %reorganize longitudes
        end
    end
end
