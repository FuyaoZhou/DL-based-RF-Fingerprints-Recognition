%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
测试集和训练集所需的信噪比分开进行设置
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
nsymbol = 32;                                                               % 每种信噪比下的发送符号数
ndevice = 10;                                                               % 设备数量
ns_train = 1800;                                                            % 每个设备训练集采集次数，但仿真时经过6中SNR信道，实际采集是6000次
ns_test = 200;                                                              % 每个设备测试集采集次数

%%%%%%%%%%%%%%%%%%%%信号相关参数%%%%%%%%%%%%%%%%%%%%
T = 1;                                                                      % 符号周期
fs = 96;                                                                    % 每个符号的采样点数
ts = 1 / fs;                                                                % 采样时间间隔
t = 0:ts:T-ts;                                                              % 时间矢量
fc = 10;                                                                    % 载波频率
M = 4;                                                                      % QPSK
graycode = [0 1 3 2];                                                       % Gray编码规则
SNR_train = 0: 5: 30;                                                       % 训练集信噪比
SNR_test = 0: 5: 30;                                                        % 测试集信噪比

%%%%%%%%%%%%%%%%%%%设备相关参数%%%%%%%%%%%%%%%%%%%%%
beta = (rand(1, ndevice)+10) / 10;                                          % IQ失衡中的幅度 1~1.1
phi = (rand(1, ndevice) * 90 - 45) / 10;                                    % IQ失衡中的相位 -4.5~4.5
FcoFc = (rand(1, ndevice) * 2 - 1) / 1000000;                               % 载波偏置的频率比 fcr/fc -1~1ppm
g1 = 2;                                                                     % 功率放大器参数1
g2g1 = (rand(1, ndevice) - 1) / 10;                                         % 功率放大器参数g2/g1 -0.1~0
g3g1 = (rand(1, ndevice) * 15 - 5) / 10;                                    % 功率放大器参数g3/g1 -0.5~1

%%%%%%%%%%%%%%%%%%%生成数据集%%%%%%%%%%%%%%%%%%%%%
tmp_train = 0;      % 记录当前生成第几个数据
tmp_test = 0;       % 记录当前生成第几个测试集数据

train_data = zeros(ndevice*ns_train, nsymbol*fs, length(SNR_train));        % 记录训练采集数据
train_label = zeros(ndevice*ns_train, length(SNR_train));                   % 记录训练数据对应标签
test_data = zeros(ndevice*ns_test, nsymbol*fs, length(SNR_test));           % 记录测试采集数据
test_label = zeros(ndevice*ns_test, length(SNR_test));                      % 记录测试数据对应标签

for n_device = 1:ndevice
    % 设置每个设备的载波
    % 增加IQ失衡和频率相位偏置的载波信号
    c = sqrt(2/T) * (cos(2*pi*fc*t) + 1i * beta(n_device) * sin(2*pi*fc*t + phi(n_device)*2*pi/360)) .* exp(2*pi*fc*FcoFc(n_device)*t);
    
    % 生成训练数据
    for tt = 1:ns_train
        msg = randi(M, 1, nsymbol) - 1;         % 消息数据
        msg1 = graycode(mod(msg,M)+1);          % Gray映射
        msgmod = pskmod(msg1, M).';             % 基带QPSK调制
        tx = real(msgmod * c);                  % 载波调制
        tx1 = reshape(tx.', 1, length(msgmod) * length(c)); 
        % 对发送信号进行功率放大
        tx_PA = (g1 + g1*g2g1(n_device)*abs(tx1) + g1*g3g1(n_device)*abs(tx1).^2) .* tx1;

        % 信号通过不同SNR的AWGN信道
        tmp_train = tmp_train + 1;
        for i = 1: length(SNR_train)
            rx = awgn(tx_PA, SNR_train(i), 'measured');
            train_data(tmp_train, :, i) = rx;
            train_label(tmp_train, i) = n_device - 1;
        end
    end
    
    % 生成测试数据
    for tt = 1:ns_test
        msg = randi(M, 1, nsymbol) - 1;         % 消息数据
        msg1 = graycode(mod(msg,M)+1);          % Gray映射
        msgmod = pskmod(msg1, M).';             % 基带QPSK调制
        tx = real(msgmod * c);                  % 载波调制
        tx1 = reshape(tx.', 1, length(msgmod) * length(c)); 
        % 对发送信号进行功率放大
        tx_PA = (g1 + g1*g2g1(n_device)*abs(tx1) + g1*g3g1(n_device)*abs(tx1).^2) .* tx1;
        
        % 信号通过不同SNR的AWGN信道
        tmp_test = tmp_test + 1;
        for i = 1: length(SNR_test)
            rx = awgn(tx_PA, SNR_test(i), 'measured');
            test_data(tmp_test, :, i) = rx;
            test_label(tmp_test, i) = n_device - 1;
        end
    end
    
end
