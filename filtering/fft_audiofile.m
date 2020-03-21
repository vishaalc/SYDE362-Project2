#audio_filename = '/home/munir/Downloads/SYDE362-P2/Option 3 - ML Files for Students/Isolated Failure Sounds/D.wav'
audio_filename = "/home/munir/Downloads/SYDE362-P2/Option 3 - ML Files for Students/Control Test Failures/Control Test-10.wav"
freq_csv_filename = "/home/munir/Documents/SYDE362-Project2/filtering/Control-Test-10-freqs.csv"

[data, fs] = audioread(audio_filename);
data_fft = fft(data);
abs_data_fft = abs(data_fft(:,1));
plot(abs_data_fft);
xbounds = xlim();
set(gca, 'xtick', xbounds(1):20000:xbounds(2));

data_w_index =[reshape(1:length(abs_data_fft), length(abs_data_fft), 1)  abs_data_fft];
csvwrite (freq_csv_filename, data_w_index);