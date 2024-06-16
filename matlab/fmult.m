signed = 1;
word_len = 16;
frac_len = 7;
T = numerictype(signed, word_len, frac_len);
q = quantizer('DataMode', 'fixed', 'RoundMode', 'floor', 'Format', [word_len frac_len], 'OverflowMode', 'wrap');
vec_len = 100;


mult1 = randquant(q, vec_len, 1);
mult2 = randquant(q, vec_len, 1);
mult1 = fi(mult1, T);
mult2 = fi(mult2, T);
result = quantize(mult1.*mult2, T, 'Floor', 'Wrap');

writematrix([string(mult1.bin) string(mult2.bin) string(result.bin)], "test_vector.txt", 'Delimiter', ' ');