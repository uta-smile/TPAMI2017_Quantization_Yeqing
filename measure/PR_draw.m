function prr = PR_draw(H, k)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% PR
% Written by Wei Liu (wliu@ee.columbia.edu)
% H: ground truth vector in {0,1} 
% k: the regarded list length 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ln = sum(H);
n = size(H,1);
cn = floor(n/k); %+1;
pre = zeros(1,cn+1);
rec = pre;

pre(1) = 1/min(find(H(1:4*k)>0));
rec(1) = 1/ln;
for i = 1:cn
    range = i*k;
    if range > n
        range = n;
    end
    gn = sum(H(1:range)); %length(find(H(order(1:range))>0));
    pre(i+1) = gn/range;
    rec(i+1) = gn/ln;
end

prr = [pre,rec];
