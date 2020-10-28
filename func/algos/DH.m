function [Y] = DH(V, feabits, sigmas)

[n, d] = size(V);
bits = sum(feabits);
cumbit = cumsum(feabits);

Y = zeros(n, bits);

startb = 1;
for i = 1:d
    b = feabits(i);
    maxq = 2^b-1;
    prob = (1:maxq)*2^(-b);
    perc = norminv(prob, 0, sigmas(i));
    %perc = [perc max(V(:, i))];
    %[n, xout] = hist(V(:, i), perc);
    endb = cumbit(i);
    t = Y(:, startb:endb);
    for j = 1:numel(perc)-1
        mask = (V(:, i) >= perc(j)) & (V(:, i) < perc(j+1));
        t(mask, :) = repmat(de2bi(j, b), sum(mask), 1);
    end
    mask = (V(:, i) >= perc(end));
    t(mask, :) = repmat(de2bi(maxq, b), sum(mask), 1);
    mask = (V(:, i) < perc(1));
    t(mask, :) = repmat(de2bi(0, b), sum(mask), 1);
    
    % Make it zero mean and even dist.
%     split = floor(maxq/2);
%     t(t<=split) = t(t<=split) - (split+1);
%     t(t>split) = t(t>split) - split;
    
    Y(:, startb:endb) = t;
    
    startb = endb+1;
end