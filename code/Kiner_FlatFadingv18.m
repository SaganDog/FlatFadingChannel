%% Modeling a Flat Fading Wireless Channel
% Author: Mitchell Kiner
% Date Created: 5/16/25
% Date Updated: 5/19/25
% Revision Number: v18
% This code simulates a wireless channel with Path loss, Shadowing, and Rayleigh Fading. 
% The simulation is then verfieid by comparing the distrubutions
% of the simulated Rayleigh Fading and Shadowing against their respective
% theoretical PDFs, as well as the PSD of the simulated Rayleigh Fading
% against the theoretical Doppler Spectrum (Jake's Spectrum).

clear; 
clc; 
close all;

%% PARAMETERS

d = logspace(0, 3, 1000);         % Distance from 1m to 1000m
d0 = 1;                           % Reference distance
alpha = 3.5;                      % Path loss exponent (urban environment with obstacles and non-line-of-sight)
shadow_std_db = 8;                % Shadowing std dev in dB (urban outdoor environment with large obstructions)
fs = 1000;                        % Samples/meter (for Clarke model)
fd = 83;                          % Doppler frequency in Hz (mobile user moving at ~30 km/h at 900 MHz)
M = 64;                           % Number of sinusoids in Clarke model
N = length(d);                    % Sample count

scaling_factor = 0.4;             % Compress Rayleigh amplitude toward 1

%% Path Loss

PL_db = 10 * alpha * log10(d / d0);

%% Shadowing (Log-Normal)

shadowing_db = shadow_std_db * randn(1, N);
shadowing_db_smooth = smoothdata(shadowing_db, 'movmean', 25);
PL_slow_db = PL_db + shadowing_db_smooth;

%% Clarke-Based Rayleigh Fading

t = (0:N-1) / fs;
phi = 2 * pi * rand(1, M);
theta = 2 * pi * rand(1, M);
omega_d = 2 * pi * fd;

rayleigh_complex = zeros(1, N);
for m = 1:M
    rayleigh_complex = rayleigh_complex + exp(1j * (omega_d * cos(theta(m)) * t + phi(m)));
end
rayleigh_complex = sqrt(2/M) * rayleigh_complex;

rayleigh_env = abs(rayleigh_complex);  % Raw envelope (Rayleigh-distributed)
rayleigh_env_smooth = smoothdata(rayleigh_env, 'movmean', 2);  % Smoothing
rayleigh_env_smooth = rayleigh_env_smooth / sqrt(mean(rayleigh_env_smooth.^2));  % Normalize to unit power

% Compress fluctuations toward mean
rayleigh_env_compressed = 1 + scaling_factor * (rayleigh_env_smooth - 1);
rayleigh_power_db = 10 * log10(rayleigh_env_compressed.^2);
PL_fast_db = PL_slow_db + rayleigh_power_db;

%% Plot

figure;
% Negating powers for channel gain (loss)
semilogx(d, -PL_db, 'r--', 'LineWidth', 2); 
hold on;
semilogx(d, -PL_slow_db, 'b:', 'LineWidth', 1.5);
semilogx(d, -PL_fast_db, 'k-', 'LineWidth', 1.2);
xlabel('Distance [m] (log-scale)');
ylabel('Channel Gain [dB]');
title('Flat Fading Wireless Channel');
legend('Path Loss', 'Shadowing', 'Rayleigh Fading', 'Location', 'northeast');
grid on;
ylim([-max(PL_db) 3]);

%% Verification I: Shadowing Distribution vs. Theoretical PDF

% Plot histogram of simulated shadowing
figure;
histogram(shadowing_db, 'Normalization', 'pdf', ...
    'DisplayName', 'Simulated', 'FaceAlpha', 0.6); 
hold on;

% Theoretical Shadowing PDF
x = linspace(min(shadowing_db), max(shadowing_db), 500);
theory_pdf = normpdf(x, 0, shadow_std_db);

plot(x, theory_pdf, 'r-', 'LineWidth', 2, 'DisplayName', 'Theoretical');

title('Shadowing Distribution');
xlabel('Shadowing Gain (dB)');
ylabel('Probability Density');
legend('show'); 
grid on;
%% Verification II: Rayleigh Envelope PDF

% Normalize Rayleigh envelope to unit average power
rayleigh_env_norm = rayleigh_env / sqrt(mean(rayleigh_env.^2));

% Plot histogram of simulated envelope
figure;
histogram(rayleigh_env_norm, 'Normalization', 'pdf', ...
    'DisplayName', 'Simulated', 'FaceAlpha', 0.6); 
hold on;

% Theoretical Rayleigh PDF
x = linspace(0, max(rayleigh_env_norm), 500);
sigma = 1 / sqrt(2);  % So mean power = 1
rayleigh_pdf = (x ./ sigma^2) .* exp(-x.^2 ./ (2 * sigma^2));

plot(x, rayleigh_pdf, 'r-', 'LineWidth', 2, 'DisplayName', 'Theoretical');

title('Rayleigh Envelope Distribution');
xlabel('Envelope Amplitude'); 
ylabel('Probability Density');
legend('show'); 
grid on;

%% Verification III: PSD of Rayleigh Fading vs. Jakes Spectrum (Improved)

% Parameters
segment_length = 256;
window = hamming(segment_length);
noverlap = round(0.5 * segment_length);

% Compute PSD using Welch's method
[psd_sim, f_sim] = pwelch(rayleigh_complex, window, noverlap, 2048, fs, 'centered');
psd_sim = psd_sim / max(psd_sim);  % Normalize

% Theoretical Jakes Spectrum
f_jakes = linspace(-fd, fd, 1000);
S_jakes = zeros(size(f_jakes));
inside = abs(f_jakes) < fd;
S_jakes(inside) = 1 ./ (pi * fd * sqrt(1 - (f_jakes(inside) / fd).^2));
S_jakes = S_jakes / max(S_jakes);

% Plot
figure;
plot(f_sim, 10*log10(psd_sim), 'b', 'LineWidth', 1.5); 
hold on;
plot(f_jakes, 10*log10(S_jakes), 'r--', 'LineWidth', 2);
title('PSD of Rayleigh Fading vs. Jakes Doppler Spectrum');
xlabel('Frequency (Hz)');
ylabel('Normalized Power (dB)');
legend('Simulated', 'Theoretical');
grid on;
xlim([-2*fd, 2*fd]);  % Focus around Doppler range