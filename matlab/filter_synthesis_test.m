addpath("cosim")

ad_filter = hdlcosim_adaptive_filter;

ns = 1000;
fs = 100e3;

f_points = 100;     
f = linspace(0,fs/2,f_points)';
a = [ones(f_points/2,1);zeros(f_points/2,1)];
ph = linspace(0,7*2*pi,f_points)';
ph = mod(ph, 2*pi);
% stem(ph)

[Input, Desired] = filter_synthesis_input(f,a,ph,ones(f_points,1),fs,ns);

width = 32;
frac = 20;
taps = 50;

T = numerictype(true,width,frac);

Input = fi(Input,T);
Desired = fi(Desired,T);
StepSize = fi(0.2,T);
% StepSize = 0.2;

Out = int32(zeros(ns,1));
Error = int32(zeros(ns,1));
Weights = fi(zeros(ns, taps), numerictype(false, width, 0));
% Weights = false(ns, width*taps);
Ovr = fi(zeros(ns,1));

for i=1:ns
    [Out(i),Error(i),Weights(i,:),Ovr(i)] = ad_filter(Input(i), Desired(i), StepSize, fi(0, 0, 1));
%     ad_filter(Input(i), Desired(i), StepSize, fi(0, 0, 1));
end

% y = unpack_signal(Weights, width, taps, T);

plot(y)

function y = unpack_signal(x, width, len, T)
    x_bin = dec2bin(x, width);
    y = fi(zeros(length(x), len), T);
    
    for row = 1:length(x)
        for i = 1:len
            column_ind = width*(i-1)+1;
            item_bin = x_bin(row,column_ind:column_ind+width-1);
            item_fi = fi(0,T);
            item_fi.bin = item_bin;
            y(row,i) = item_fi;            
        end
    end   
end
