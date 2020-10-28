function [ROC, Precision, mAP]=weak_HammingRanking(Y, tY, gnd, range)
%%%%%%  gnd=knn_gnd (pesudo label from knn)

n=size(Y,1); tn=size(tY,1);
sim = tY*Y'; clear Y tY;

pn = 1;%200; 
kk=1000;
pre = zeros(1,tn);
% prr = zeros(1,1001*2); %zeros(1,61);
sn=floor(n/kk)+1;
prr = zeros(sn,2);

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
%         prr = prr+PR_draw(h,1000); %prr+PR_new(h,1000); 
        prr = prr+PR_new_2D(h,kk); %prr+PR_new(h,1000); 
        clear tep hitset h;
    end
end

clear temp order get;
% prr=prr/tn;
% ROC(:,1)=prr(1+1001:end);
% ROC(:,2)=prr(1:1001);
ROC = prr/tn;
Precision= mean(pre,2);
% mAP=mean(ap,2);
mAP=0;
return