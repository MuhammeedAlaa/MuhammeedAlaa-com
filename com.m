% assumptions made on the signals: 
%     1- they have same sampling rate
%     2- they are less than 10 seconds
%     3- they are mono not stereo
    

[message1,samplingFrequency1]=audioread("time.wav");
[message2,samplingFrequency2]=audioread("intro.wav");
[message3,samplingFrequency3]=audioread("Cheers.wav");

% make lengths of all signals equal
padding1 = 0;
padding2 = 0;
padding3 = 0;
maxSamples = max(max(length(message2), length(message3)), length(message1));
if length(message1) ~= maxSamples
    padding1 = maxSamples - length(message1);
    message1 = padarray(message1, maxSamples - length(message1), 0, "post");
end
if length(message2) ~= maxSamples
    padding2 = maxSamples - length(message2);
    message2 = padarray(message2, maxSamples - length(message2), 0, "post");
end
if length(message3) ~= maxSamples
    padding3 = maxSamples - length(message3);
    message3 = padarray(message3, maxSamples - length(message3), 0, "post");
end

displaySignals(message1, message2, message3,'After extending to same length');

% upsampling to be able to raise the signals on high frequency carrier
upSamplingRate = 30;
message1 = resample(message1, upSamplingRate, 1);
message2 = resample(message2, upSamplingRate, 1);
message3 = resample(message3, upSamplingRate, 1);
displaySignals(message1, message2, message3,'After upsampling');

% modulating signals
m = samplingFrequency1 * upSamplingRate;
duration = length(message1) ./ m;
t=-(duration-1/m) / 2:1/m:(duration-1/m) / 2 ;

fcarrier1 = 115000; % current Fs is 240 so max carrier freq is less than 120kHz
fcarrier2 = 60000;

carrier1 = cos(2 * pi * fcarrier1 * t);
carrier2 = cos(2 * pi * fcarrier2 * t);
carrier3 = sin(2 * pi * fcarrier2 * t);


s1 = message1' .* carrier1;
s2 = message2' .* carrier2;
s3 = message3' .* carrier3;

displaySignals(s1, s2, s3, "signals after modulating the carriers");

s = s1 + s2 + s3;


% plot s in time and frequency domain
figure('name', 'modulated Signal');
set(gcf,'position',[100 100 1000 400]);
subplot(1,2,1);plot(s);ylabel("s[t]");xlabel("t");
subplot(1,2,2);[x, y] = audioMagnitudeSpectrum(s);plot(x, y);ylabel("|s|");xlabel("f(Hz)");

% demodulate the signal s

demodulator(s, 0, samplingFrequency1, upSamplingRate, fcarrier1, fcarrier2, padding1, padding2, padding3);
demodulator(s, 10, samplingFrequency1, upSamplingRate, fcarrier1, fcarrier2, padding1, padding2, padding3);
demodulator(s, 30, samplingFrequency1, upSamplingRate, fcarrier1, fcarrier2, padding1, padding2, padding3);
demodulator(s, 90, samplingFrequency1, upSamplingRate, fcarrier1, fcarrier2, padding1, padding2, padding3);



function [x, y] = audioMagnitudeSpectrum(signal)
    x = (length(signal))/2*linspace(-1,1,(length(signal)));
    y = abs(fftshift(fft(signal)));
end

function a = displaySignals(signal1, signal2, signal3, figureTitle)
    a = 0;
    figure('name', figureTitle)
    set(gcf,'position',[100 100 1000 400])

    subplot(2,3,1);
    plot(signal1);
    ylabel("x1[t]");xlabel("t");

    subplot(2,3,2);
    plot(signal2);
    ylabel("x2[t]");xlabel("t");

    subplot(2,3,3);
    plot(signal3);
    ylabel("x3[t]");xlabel("t");

    subplot(2,3,4);
    [x, y] = audioMagnitudeSpectrum(signal1);
    plot(x, y);
    ylabel("|x1|");xlabel("f(Hz)");

    subplot(2,3,5);
    [x, y] = audioMagnitudeSpectrum(signal2);
    plot(x, y);
    ylabel("|x2|");xlabel("f(Hz)");

    subplot(2,3,6);
    [x, y] = audioMagnitudeSpectrum(signal3);
    plot(x, y);
    ylabel("|x3|");xlabel("f(Hz)");
end

function c = demodulator(signal, phaseShiftDegrees, Fs, upSamplingRate, fcarrier1, fcarrier2, padding1, padding2, padding3)
    c=0;
    m = Fs * upSamplingRate;
    duration = length(signal) ./ m;
    t=-(duration-1/m) / 2:1/m:(duration-1/m) / 2 ;
    carrier1 = cos(2 * pi * fcarrier1 * t + (phaseShiftDegrees * pi / 180));
    carrier2 = cos(2 * pi * fcarrier2 * t + (phaseShiftDegrees * pi / 180));
    carrier3 = sin(2 * pi * fcarrier2 * t + (phaseShiftDegrees * pi / 180));

    output1 = 2*(carrier1 .* signal);
    output2 = 2*(carrier2 .* signal);
    output3 = 2*(carrier3 .* signal);

    % downsmapling the signals
    output1 = resample(output1, 1,upSamplingRate);
    output2 = resample(output2, 1,upSamplingRate);
    output3 = resample(output3, 1,upSamplingRate);
    
    % clip the audio to its original length
%     output1 = output1(1: (end - padding1));
%     output2 = output2(1: (end - padding2));
%     output3 = output3(1: (end - padding3));

    displaySignals(output1, output2, output3, ['demodulation output phase' int2str(phaseShiftDegrees)]);

    audiowrite(['time_' int2str(phaseShiftDegrees) '.wav'], output1, Fs);
    audiowrite(['intro_' int2str(phaseShiftDegrees) '.wav'], output2, Fs);
    audiowrite(['cheers_' int2str(phaseShiftDegrees) '.wav'], output3, Fs);
end

