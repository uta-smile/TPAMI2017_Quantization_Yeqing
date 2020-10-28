function [ROC, mAP, Precision, tt0, HR2_Precision, success]=func_IntQ(traindata, testdata, traingnd, testgnd, tn, r, range, step)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ***** Idea *****
% Use different length of bits to approximate different PCA direction
% Bit length is proportional to eigenvalue
% Direction with larger eignevalue has longer bits (larger integer)
% 
% Fail!!
% Because the top 1 direction will become so large that other directions
% just become irrelevant.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% data_{n x d} = [traindata; testdata]; gnd=[traingnd; testgnd];
%%%% tn: the number of test data
%%%% r: the bit number
%%%% range: how many neighbors to check?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;

%%%%%%%%%%%%%% training
[n,d] = size(traindata);
mvec = mean(traindata,1);
% traindata = traindata-repmat(mvec,n,1);
traindata = bsxfun(@minus, traindata, mvec);

cov = traindata'*traindata;
% rnum=1:step:n;
% cov = traindata(rnum, :)'*traindata(rnum, :);

[U,V] = eig(cov); clear cov;
eigenvalue = diag(V)'; clear V;
[eigenvalue,order] = sort(eigenvalue,'descend'); %clear eigenvalue;
% W = U(:,order(1:r)); clear U; clear order;

%***** Compute the bit distribution
eigenvalue = sqrt(eigenvalue);
ratio = eigenvalue(1:r)./eigenvalue(2:r+1);
nbit = ratio(1);
nfea = 1;
for i=2:r, 
    if sum(nbit) >= r, break; end
    nbit = [nbit * ratio(i), ratio(i)];
    nfea = i;
end
nbit = floor(nbit);
diff = r - sum(nbit);
if diff > 0, 
    nbit(1:diff) = nbit(1:diff) + 1;
end
%***** Construct the projection matrix W = U(1:r)*scale
norm_scale = eigenvalue(1:nfea); clear eigenvalue;
W = U(:,order(1:nfea)); clear U; clear order;
quan_scale = 2.^(nbit-1);

Y = traindata*W;
% Y = bsxfun(@rdivide, Y, norm_scale);#
Y = floor(bsxfun(@times, Y, quan_scale));
% [Y, R] = ITQSS(Y, 50, step); 
clear temp traindata;

%% testing
testdata = testdata-repmat(mvec,tn,1);
tY = testdata*W; 
% tY = single(tY>0);
% tep = find(tY<=0); tY(tep) = -1;
% tY = mexsign(tY);
tY = floor(bsxfun(@times, tY, quan_scale));
clear tep testdata;

tt0=toc;

%%%% Hamming ranking evaluation
[ROC, Precision, mAP]=eval_HammingRanking(Y, tY, traingnd, testgnd, range);

%%%% Hamming Radius 2 Hash Lookup
% Y(Y<=0)=0;  tY(tY<=0)=0;
[HR2_Precision, success]=eval_HammingRadius2HashLookup(Y, tY, traingnd, testgnd, range);

return
