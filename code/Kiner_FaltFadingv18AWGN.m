%% Path Loss + AWGN Simulation
% Author: Mitchell Kiner
% Date Created: 5/16/25
% Date Updated: 5/19/25
% Revision Number: v18
% This code simulates a wireless channel with Path loss and AWGN

clear; 
clc; 
close all;

%% PARAMETERS
d = logspace(0, 3, 1000);         % Distance from 1m to 1000m
d0 = 1;                           % Reference distance
alpha = 3.5;                      % Path loss exponent
tx_power_db = 0;                  % Transmit power in dB
awgn_var = 0.01;                  % Noise power
N = length(d);

% Preallocate
rx_power = zeros(1, N);

%% Path Loss + AWGN Loop
for i = 1:N
    % Path loss (in linear scale)
    pl_db = -10 * alpha * log10(d(i) / d0);
    pl_lin = 10^((tx_power_db + pl_db) / 10);  % Received signal power

    % AWGN (complex)
    noise = sqrt(awgn_var/2) * (randn + 1j*randn);

    % Total received signal
    y = sqrt(pl_lin) + noise;

    % Measured power
    rx_power(i) = abs(y)^2;
end

% Convert to dB
rx_power_db = 10 * log10(rx_power);

%% Plot
figure;
semilogx(d, 10 * log10(10.^((tx_power_db - 10 * alpha * log10(d / d0)) / 10)), 'r--', 'LineWidth', 2); 
hold on;
semilogx(d, rx_power_db, 'k-', 'LineWidth', 1.5);
xlabel('Distance [m] (log-scale)');
ylabel('Channel Gain (dB)');
title('Flat Fading Wireless Channel');
legend('Ideal Path Loss', 'Path Loss with AWGN');
grid on;