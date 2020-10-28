function [ROC, mAP, Precision, tt0]=func_SDH(traindata, testdata, traingnd, testgnd, tn, r, range)
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
col2norm = sum(traindata.^2, 2);
traindata = bsxfun(@rdivide, traindata, col2norm);

W = randn(d, r);

V = traindata*W; clear temp traindata;

sigmas = std(V);

feabits = ones(r, 1)*2;

[Y] = DH(V, feabits, sigmas);

% Y = ones(size(V)); 
% Y(V<0)=-1; 
clear V

%% testing
testdata = testdata-repmat(mvec,tn,1);
col2norm = sum(testdata.^2, 2);
testdata = bsxfun(@rdivide, testdata, col2norm);
V = testdata*W; 
[tY] = DH(V, feabits, sigmas);

% tY = ones(size(V)); 
% tY(V<0)=1; 
clear V
clear tep testdata;

tt0=toc;

%%%% Hamming ranking evaluation
[ROC, Precision, mAP]=eval_HammingRanking(Y, tY, traingnd, testgnd, range);

%%%% Hamming Radius 2 Hash Lookup
% Y(find(Y<=0))=0;  tY(find(tY<=0))=0;
% [HR2_Precision, success]=eval_HammingRadius2HashLookup(Y, tY, traingnd, testgnd, range);

return
