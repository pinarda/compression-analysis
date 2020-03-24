function num = autocorr_matrix(data, lag) %Each row must be a time series
    if length(lag) == 1
        n = size(data, 2);
        ybar = mean(data, 2); 
        values = ((sum((data(:,lag+1:n) - ybar).*(data(:,1:(n-lag))- ybar),2)) ./ (sum(((data - ybar).^2), 2)));
        num = reshape(values, 288, []);
    end
    if length(lag) > 1
        p = 1;
        for i=1:length(lag)
            cur_lag = lag(i);
            n = size(data, 2);
            ybar = mean(data, 2);
            values = ((sum((data(:,cur_lag+1:n) - ybar).*(data(:,1:(n-cur_lag))- ybar),2)) ./ (sum(((data(:,1:n)- ybar).^2), 2)));
            cur_values = reshape(values, 288, []);
            if p == 1
                num = cur_values;
                p = p +1;
            end
            if p > 1
                num = cat(3, num, cur_values);  
            end 
        end
    end
end