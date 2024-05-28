%% Generate input
t = 1:0.01:10;
f = 10;
range_max = 2^15-1; 
in = range_max * 0.1 * sin(2*pi*f*t);
in = floor(in);
fid = fopen("input.txt", "w");
fprintf(fid, "%d\n", in);
fclose(fid);
% x_fft = fft(x);
% x_fft = fftshift(x_fft);
% plot(abs(x_fft))
%% Calculate output
out_model = filter([-1462 1438 6511 11068 11068 6511 1438 -1462], 1, in);
out_model = out_model';
%% Plot output
fid = fopen("../output.txt", "r");
out = fscanf(fid, "%d");
out_fft = fft(out);
out_fft = fftshift(out_fft);
plot(abs(out_fft))