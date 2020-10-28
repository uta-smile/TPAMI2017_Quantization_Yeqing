function [Y] = DHbitmap(V, feabits, sigmas)

[n, d] = size(V);
bits = sum(feabits);
cumbit = cumsum(feabits);

Y = zeros(n, bits);

startb = 1;
for i = 1:d
    b = feabits(i);
    maxq = b-1;
    prob = (1:maxq)/b;
    perc = norminv(prob, 0, sigmas(i));
    %perc = [perc max(V(:, i))];
    %[n, xout] = hist(V(:, i), perc);
    endb = cumbit(i);
    for j = 1:numel(perc)-1
        bmp = zeros(1, b); bmp(j+1) = 1;
        mask = (V(:, i) >= perc(j)) & (V(:, i) < perc(j+1));
        Y(mask, startb:endb) = repmat(bmp, sum(mask), 1);
    end
    bmp = zeros(1, b); bmp(end) = 1;
    mask = (V(:, i) >= perc(end));
    Y(mask, startb:endb) = repmat(bmp, sum(mask), 1);
    
    bmp = zeros(1, b); bmp(1) = 1;
    mask = (V(:, i) < perc(1));
    Y(mask, startb:endb) = repmat(bmp, sum(mask), 1);
    startb = endb+1;
end

% Y(Y==0) = -1;