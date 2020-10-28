function prr = PR_new_2D(H, k)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% PR curve 
% Written by Wei Liu (wliu@ee.columbia.edu)
% H: ground truth vector in {0,1} 
% k: the regarded list length 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ln = sum(H);
n = size(H,1);
cn = floor(n/k);
pre = zeros(1,cn+1);
rec = pre;

index=find( H(1:4*k)>0 );
if isempty(index) 
    pre(1)=0; %%%%% ??? added on Oct.23rd; may 
else
    pre(1) = 1/min(index);
end
rec(1) = 0;
sumH = cumsum(H);
for i = 1:cn
    range = i*k;
    if range > n
        range = n;
    end
    gn = sumH(range);
    pre(i+1) = gn/range;
    rec(i+1) = gn/ln;
    
    if isnan(rec(i+1))
        disp('end')
    end
end

prr(:,1) = rec;
prr(:,2) = pre;
return