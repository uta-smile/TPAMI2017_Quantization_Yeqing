function [ROC, Precision, mAP]=eval_SimilarityRanking_weight(Y, tY, traingnd, testgnd, range, D)
%
% ROC - 
%
%

D = D.^2;
sim = Y*D*tY'; % Similarity of traning data and testing data, ntr by d, d by nte, ntr by nte
[temp,order] = sort(sim,1,'descend'); % compute order of nearest neighbour, 
H = traingnd(order);   % sort training labels according to nearest order, ntr by nte 
clear Y tY sim temp order;

tn=length(testgnd); % 

ap = zeros(1,tn);  % average precision of each testing data
pre = zeros(1,tn); % precision of each testing data

kk=500;  % select top 500 nearest neighbours
sn=floor(size(H, 1)/kk)+1; % ntr/kk
prr = zeros(sn,2);

for i = 1:tn
    h = double(H(:,i) == testgnd(i));
    ind = find(h > 0);
    pn = length(ind); % num of training data that have the same label as testing point
    pre(i) = sum(h(1:range))/range; % Rate of correct labels in top range(=100) NN 
    if pn == 0
        ap(i) = 0;
    else
        h2=cumsum(h);
        ap(i)=sum(h2(ind)./ind)/pn; % average precision in all ranges from 1 to last data with same label
    end
    clear ind;
   
    %% PR curve
    prr = prr+PR_new_2D(h,kk); %%% kk=500;
    clear h;
end
ROC = prr/tn;
Precision= mean(pre,2);
mAP=mean(ap,2);
return