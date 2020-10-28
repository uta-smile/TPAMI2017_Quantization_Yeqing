
load eightyMsubset_hash_final;
load eightyMsubset_gnd;
gist_trn = double(gist_trn);
[d,n] = size(gist_trn);
tn = 2000; 
gnd = knn_gnd(1:tn,:);
gist_tst = double(gist_tst(:,1:tn));
range = 50000; %1000; %
r = 48;
clear gist_trn;


load tiny_pcah_48;
tic;
gist_tst = gist_tst-repmat(mvec,1,tn);
tY =  gist_tst'*W;  
tY = (tY>0);
tB = compactbit(tY);
tY = single(tY);
time = toc;
[time/tn]
clear gist_tst;


pn = 200;
ham_pre = zeros(1,tn);
list_len = zeros(1,tn);
success = 0;
for i = 1:tn/pn
    [i]
    HamDis = sqdist(tY((i-1)*pn+1:i*pn,:)', Y');
    for j = 1:pn
        ii = (i-1)*pn+j;
        list = find(HamDis(j,:) <= 2);
        ln = length(list);
        list_len(ii) = ln;
        
        if ln == 0
            ham_pre(ii) = 0;
        else
            ham_pre(ii) = length( intersect(list,gnd(ii,:)) )/ln;
            success = success+1;
        end
        clear list;    
    end
end
clear HamDis;

[r, success/tn, mean(ham_pre,2)]   
[mean(list_len,2)]
