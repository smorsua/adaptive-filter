signed = 1;
word_len = 32;
frac_len = 25;

T = numerictype(signed, word_len, frac_len);
q = quantizer('DataMode', 'fixed', 'RoundMode', 'floor', 'Format', [word_len frac_len], 'OverflowMode', 'wrap');

ns = 1000;
taps = 2;
rng(0);
din = fi(randquant(q, ns, taps),T);
error = fi(randquant(q, ns, 1),T);
weights = fi(randquant(q, ns, taps),T);
step_size = fi(randquant(q, ns, 1),T);

next_weights = fi(zeros(ns, taps), T);
T2 = numerictype(1, 50, 21);

mults1 = fi(zeros(ns, taps), T);
mults2 = fi(zeros(ns, taps), T);
mults3 = fi(zeros(ns, taps), T);
sum1 = fi(zeros(ns, taps), T);

for i = 1:length(din(:,1))
    mults1(i,:) = error(i).*din(i,:);
    mults2(i,:) = step_size(i)*error(i)*din(i,:);
    mults3(i,:) = 2*step_size(i)*error(i)*din(i,:);
    sum1(i,:) = quantize(weights(i,:) + 2*step_size(i)*error(i)*din(i,:), T, 'Floor', 'Wrap');
    next_weights(i,:) = quantize(weights(i,:) + 2*step_size(i)*error(i)*din(i,:), T, 'Floor', 'Wrap');
end

writematrix(split(string(din.dec)), "data/din_vector.txt", 'Delimiter', ' ');
writematrix(split(string(weights.dec)), "data/weights_vector.txt", 'Delimiter', ' ');
writematrix(split(string(next_weights.dec)), "data/next_weights_vector.txt", 'Delimiter', ' ');
save_dec_txt(error, T, "data/error_vector.txt");
save_dec_txt(step_size, T, "data/step_size_vector.txt");
