%% ============================================================
%              Orthogonal Frequency Division Multiplexing
%                     MATLAB Simulation (OFDM)
%                Author: Zunaira Khalid 
% ============================================================

clc; clear all; close all;

%% ------------------------------------------------------------
% 1. Transmitter
% ------------------------------------------------------------

N = 100;                                 % Number of bits
x = randsrc(1, N, [0,1]);                % Random bitstream
figure;
stem(x); title('Original Bitstream'); xlabel('Bit Index'); ylabel('Value');

% BPSK Mapping
x_BPSK = 2*x - 1;                         % 0 -> -1, 1 -> +1
figure;
stem(x_BPSK); title('BPSK Symbol Stream');

% IFFT (OFDM Modulation)
sig_ifft = ifft(x_BPSK, N);
figure;
subplot(1,2,1);
stem(sig_ifft,'k'); title('IFFT Output (OFDM Time Domain)');

% Add Cyclic Prefix (Guard Interval)
Ncp = N/4;
sig_cp = [sig_ifft(end-Ncp+1:end) sig_ifft];
subplot(1,2,2);
stem(sig_cp); title('Signal with Cyclic Prefix');

tx_signal = sig_cp;
len = length(tx_signal);

%% ------------------------------------------------------------
% 2. Channel (Multipath + Noise)
% ------------------------------------------------------------

h = [-1, 4, -2, 3, -3];                   % Example channel impulse response
channel_out = cconv(tx_signal, h, len);

% Add Gaussian Noise
noise = randn(1, len);
rx_signal = channel_out + noise;

figure;
stem(noise); title('Added Noise');

figure;
subplot(2,1,1);
stem(tx_signal); title('Transmitted Signal');

subplot(2,1,2);
stem(rx_signal); title('Received Signal (After Channel + Noise)');

%% ------------------------------------------------------------
% 3. Receiver
% ------------------------------------------------------------

% Remove Cyclic Prefix
rx_wo_cp = rx_signal(Ncp+1:end);

figure;
stem(rx_wo_cp); title('Signal after Removing Cyclic Prefix');

% FFT (OFDM Demodulation)
rx_fft = fft(rx_wo_cp);

figure;
stem(rx_fft); title('FFT Output at Receiver');

% Symbol Decisions
rx_decision = zeros(1, length(rx_fft));

for i = 1:length(rx_fft)
    if real(rx_fft(i)) > 0
        rx_decision(i) = 1;
    else
        rx_decision(i) = -1;
    end
end

figure;
stem(rx_decision); title('Detected BPSK Symbols');

% Convert BPSK → Bits
rx_bits = zeros(1, length(rx_decision));

for i = 1:length(rx_decision)
    if rx_decision(i) == -1
        rx_bits(i) = 0;
    else
        rx_bits(i) = 1;
    end
end

figure;
subplot(1,2,1);
stem(x); title('Original Bits');

subplot(1,2,2);
stem(rx_bits); title('Recovered Bits');

%% ------------------------------------------------------------
% 4. Error Calculation
% ------------------------------------------------------------

error = abs(x - rx_bits);
num_errors = sum(error);

fprintf('\nOriginal Bits:     %s\n', num2str(x));
fprintf('Recovered Bits:    %s\n', num2str(rx_bits));
fprintf('\nTotal Bit Errors: %d out of %d bits\n', num_errors, N);

