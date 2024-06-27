signed = 1;
word_len = 16;
frac_len = 7;
T = numerictype(signed, word_len, frac_len);
q = quantizer('DataMode', 'fixed', 'RoundMode', 'floor', 'Format', [word_len frac_len], 'OverflowMode', 'wrap');

ns = 2000;
rng(0);
x = fi(randquant(q, ns, 1), T);

T2 = numerictype(1, 50, 21);
taps = 5;

coeffs = [1 2 3 4];
coeffs = fi(coeffs, T);
sums = fi(zeros(taps-1,1), T2);
y = fi(zeros(length(x),1), T);

for i = 1:length(x)
    sample = x(i);
    mults = sample.*fi(coeffs, T2);

    for j = length(sums):-1:2
        sums(j) = sums(j-1) + mults(j);
    end

    sums(1) = mults(1);
    y(i) = quantize(sums(end) + mults(end), T, 'Floor', 'Wrap');
end

save_dec_txt(x, T, "data/input.txt");
save_dec_txt(coeffs.', T, "data/coeffs.txt");
save_dec_txt(y, T, "data/output.txt");



