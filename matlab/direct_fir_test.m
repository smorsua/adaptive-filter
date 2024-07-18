signed = 1;
word_len = 16;
frac_len = 7;
T = numerictype(signed, word_len, frac_len);
q = quantizer('DataMode', 'fixed', 'RoundMode', 'floor', 'Format', [word_len frac_len], 'OverflowMode', 'wrap');

ns = 2000;
rng(0);
x = fi(randquant(q, ns, 1), T);

taps = 4;
coeffs = [1 2 3 4];

coeffs = fi(coeffs, T);
mults = fi(zeros(ns,taps), T);
delay_line = fi(zeros(ns, taps-1), T);
y = fi(zeros(length(x),1), T);

for i=2:ns
    for j=length(delay_line(i,:)):-1:2
        delay_line(i,j) = delay_line(i-1,j-1);
    end
    delay_line(i,1) = x(i-1);

    for j=2:length(mults(i,:))
        mults(i,j) = quantize(delay_line(i-1,j-1) * coeffs(j), T, 'Floor', 'Wrap');
    end

    mults(i,1) = quantize(x(i-1)*coeffs(1), T, 'Floor', 'Wrap');

    y(i) = quantize(sum(mults(i,:)), T, 'Floor', 'Wrap');
end

save_dec_txt(x, T, "data/input.txt");
save_dec_txt(coeffs.', T, "data/coeffs.txt");
save_dec_txt(y, T, "data/output.txt");



