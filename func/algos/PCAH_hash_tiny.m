
load eightyMsubset_hash_final;
load eightyMsubset_gnd;
gist_trn = double(gist_trn);
[d,n] = size(gist_trn);
tn = 2000; 
gnd = knn_gnd(1:tn,:);
gist_tst = double(gist_tst(:,1:tn));
range = 50000; %1000; %
r = 48;


% %% PCAH
% tic;
% mvec = mean(gist_trn,2);
% gist_trn = gist_trn-repmat(mvec,1,n);
% cov = gist_trn*gist_trn';
% [U,V] = eig(cov);
% eigenvalue = diag(V)';
% [eigenvalue,order] = sort(eigenvalue,'descend');
% W = U(:,order(1:r));
% clear cov;
% clear V;
% clear eigenvalue;
% clear U;
% clear order;
% 
% Y = gist_trn'*W;
% Y = (Y>0);
% B = compactbit(Y);
% Y = single(Y);
% time = toc;
% [time]
% clear temp;
% save tiny_pcah_48 Y W mvec;


clear gist_trn; 
%% test
load tiny_pcah_48;
tep = find(Y<=0);
Y(tep) = -1;
clear tep;
gist_tst = gist_tst-repmat(mvec,1,tn);
tY = gist_tst'*W;
tY = single(tY>0);
ind = find(tY<=0);
tY(ind) = -1;
clear ind;

sim = tY*Y';
clear Y;
clear tY;
clear gist_tst;

pn = 200;
pre = zeros(1,tn);
prr = zeros(1,1001*2); %zeros(1,61);
for i = 1:tn/pn
    [i]
    [temp,order] = sort(sim((i-1)*pn+1:i*pn,:),2,'descend');
    get = order(:,1:n);
    for j = 1:pn
        ii = (i-1)*pn+j;
        pre(ii) = length( intersect(get(j,1:range),gnd(ii,:)) )/range;
        [tep,hitset] = intersect(get(j,:),gnd(ii,:));
        h = zeros(n,1);
        h(hitset') = 1;
        prr = prr+PR_draw(h,1000); %prr+PR_new(h,1000); 
        clear tep;
        clear hitset;
        clear h;
    end
end
clear temp;    
clear order;
clear get;
[r, mean(pre,2)]

pcah_prr = prr/tn;
% % figure
% % plot([50,100*[1:10]],pcah_prr(1:11)); 
% % figure
% % plot(1000*[1:50],pcah_prr(12:end));
% % save tiny_pcah48_pr pcah_prr; 
figure
plot(pcah_prr(1002:end),pcah_prr(1:1001));
save tiny_pcah48_prcurve pcah_prr;

