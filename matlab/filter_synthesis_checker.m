function filter_synthesis_checker(weights, f, a, ph, fs)
    h = freqz(weights,f,fs);
    tiledlayout(2,1);
    nexttile;
    plot(abs(h));
    nexttile;
    plot(angle(h));
end

