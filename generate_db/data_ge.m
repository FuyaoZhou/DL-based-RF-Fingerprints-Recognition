% 生成相关数据的.mat文件

for i = 1: length(SNR_train)
    if SNR_train(i) < 0
        eval(['train_data_minus', num2str(abs(SNR_train(i))), '=', 'train_data(:, :, i)', ';']);
        eval(['train_label_minus', num2str(abs(SNR_train(i))), '=', 'train_label(:, i)', ';']);
        save(strcat('train_minus', num2str(abs(SNR_train(i))), '.mat'), strcat('train_data_minus', num2str(abs(SNR_train(i)))), strcat('train_label_minus', num2str(abs(SNR_train(i)))));
    else
        eval(['train_data_', num2str(SNR_train(i)), '=', 'train_data(:, :, i)', ';']);
        eval(['train_label_', num2str(SNR_train(i)), '=', 'train_label(:, i)', ';']);
        save(strcat('train_', num2str(SNR_train(i)), '.mat'), strcat('train_data_', num2str(SNR_train(i))), strcat('train_label_', num2str(SNR_train(i))));
    end
end


for i = 1: length(SNR_test)
    if SNR_test(i) < 0
        eval(['test_data_minus', num2str(abs(SNR_test(i))), '=', 'test_data(:, :, i)', ';']);
        eval(['test_label_minus', num2str(abs(SNR_test(i))), '=', 'test_label(:, i)', ';']);
        save(strcat('test_minus', num2str(abs(SNR_test(i))), '.mat'), strcat('test_data_minus', num2str(abs(SNR_test(i)))), strcat('test_label_minus', num2str(abs(SNR_test(i)))));
    else
        eval(['test_data_', num2str(SNR_test(i)), '=', 'test_data(:, :, i)', ';']);
        eval(['test_label_', num2str(SNR_test(i)), '=', 'test_label(:, i)', ';']);
        save(strcat('test_', num2str(SNR_test(i)), '.mat'), strcat('test_data_', num2str(SNR_test(i))), strcat('test_label_', num2str(SNR_test(i))));
    end
end

