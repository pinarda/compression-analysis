function num = autocorrelation_new(data, lag)
    if length(lag) == 1
        n = length(data);
        ybar = mean(data);
        num = ((sum((data(lag+1:n) - ybar).*(data(1:(n-lag))- ybar))) / (sum(((data(1:n)- ybar).^2))));
    end
    if length(lag) > 1
        lag_array = zeros(1,length(lag));
        for i=1:length(lag)
            cur_lag = lag(i);
            n = length(data);
            ybar = mean(data);
            cur_num = ((sum((data(cur_lag+1:n) - ybar).*(data(1:(n-cur_lag))- ybar))) / (sum(((data(1:n)- ybar).^2))));
            lag_array(i) = cur_num;
        end
        num = lag_array;
    end
end