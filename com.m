[message1,samplingFrequency1]=audioread("message1.mp3");
[message2,samplingFrequency2]=audioread("message2.mp3");
[message3,samplingFrequency3]=audioread("message3.mp3");
maxSamples = max(max(length(message2), length(message3)), length(message1));
if length(message1) ~= maxSamples
    message1 = padarray(message1, maxSamples - length(message1), 0, "post");
end
if length(message2) ~= maxSamples
    message2 = padarray(message2, maxSamples - length(message2), 0, "post");
end
if length(message3) ~= maxSamples
    message3 = padarray(message3, maxSamples - length(message3), 0, "post");
end
fcarrier1 = 10000;
fcarrier2 = 20000;
s1 = modulate(message1, fcarrier1, samplingFrequency1, "amssb");
s2 = modulate(message2, fcarrier2, samplingFrequency2, "qam",message3);
s = s1 + s2;
figure(1)
plot(s);
title("modulated signal in time domain")
ylabel("s")
xlabel("t")




s_mags = abs(fftshift(fft(s)));
num_bins = length(s_mags);
plot([- num_bins / 2: num_bins / 2 - 1], s_mags),grid on;
title('Magnitude spectrum of modulated signal');
xlabel('f(HZ)');
ylabel('|s|');

output1 = demod(s,fcarrier1,samplingFrequency1,"amssb");
[output2, output3] = demod(s,fcarrier2,samplingFrequency1,"qam");




