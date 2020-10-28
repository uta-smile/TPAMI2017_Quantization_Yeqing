function [PR, mAP, Precision, tt1, HR2_Precision, success]=func_KPCA_ITQ(traindata, testdata, traingnd, testgnd, tn, bit, range)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% data_{n x d} = [traindata; testdata]; gnd=[traingnd; testgnd];
%%%% tn: the number of test data
%%%% r: the bit number
%%%% range: how many neighbors to check?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%% Initialization
tic;
[n,d] = size(traindata);
mvec = mean(traindata,1);
% traindata = traindata-repmat(mvec,n,1);
traindata = bsxfun(@minus, traindata, mvec);
testdata = testdata-repmat(mvec,tn,1);
%%%%%%%%%%%%%% Compute Kernel
RFparam.gamma = 1;
RFparam.D = d;
RFparam.M = 3000;
RFparam = RF_train(RFparam);
[traindata] = RF_features(traindata, RFparam);
[testdata] = RF_features(testdata, RFparam);

tt0=toc;

%%%%%%%%%%%%%% ITQ

[PR, mAP, Precision, tt1, HR2_Precision, success]=func_ITQ(traindata, testdata, traingnd, testgnd, tn, bit, range);

tt1 = tt1 + tt0;

return
