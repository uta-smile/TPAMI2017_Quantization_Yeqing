function [ROC, mAP, Precision, tt0, HR2_Precision, success]=func_DHbitmap(traindata, testdata, traingnd, testgnd, tn, r, range)
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
[U,V] = eig(cov); clear cov;
eigenvalue = diag(V)'; clear V;
[eigenvalue,order] = sort(eigenvalue,'descend'); %clear eigenvalue;

%***** Compute distribution of bits
k = r;%/2;
feabits = ones(k, 1)*4;

clear eigenvalue;

feabits = feabits(1:k);
W = U(:,order(1:k)); clear U; clear order;

V = traindata*W; 
[~, R] = ITQ(V, 50); 
Y = V*R;
sigmas = std(Y);
clear temp traindata V;

[Y] = DHbitmap(Y, feabits, sigmas);

W = W*R;

%% testing
testdata = testdata-repmat(mvec,tn,1);
tY = testdata*W; 
[tY] = DHbitmap(tY, feabits, sigmas);
clear tep testdata;

tt0=toc;

%%%% Hamming ranking evaluation
[ROC, Precision, mAP]=eval_HammingRanking(Y, tY, traingnd, testgnd, range);

%%%% Hamming Radius 2 Hash Lookup
Y(Y<=0)=0;  tY(tY<=0)=0;
[HR2_Precision, success]=eval_HammingRadius2HashLookup(Y, tY, traingnd, testgnd, range);

return
