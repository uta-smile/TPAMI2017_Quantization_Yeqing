function [ROC, mAP, Precision, tt0, HR2_Precision, success]=func_MFQ(traindata, testdata, traingnd, testgnd, tn, r, range, options)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% data_{n x d} = [traindata; testdata]; gnd=[traingnd; testgnd];
%%%% tn: the number of test data
%%%% r: the bit number
%%%% range: how many neighbors to check?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('options', 'var'),
    options.mf_iter  = 10;
    options.itq_iter = 20;
end

tic;

mvec = mean(traindata,1);

%%%%%%%%%%%%%% training
[Y, W] = MFQ(traindata, r, options.mf_iter, options.itq_iter);

% Y = Y*R; Y = (Y>0);
% B = compactbit(Y);
% Y = single(Y); tep = find(Y<=0); Y(tep) = -1; clear tep;

%% testing
testdata = testdata-repmat(mvec,tn,1);
tY = testdata*W; 
% tY = single(tY>0);
% tep = find(tY<=0); tY(tep) = -1;
tY = mexsign(tY);
clear tep testdata;

tt0=toc;

%%%% Hamming ranking evaluation
[ROC, Precision, mAP]=eval_HammingRanking(Y, tY, traingnd, testgnd, range);

%%%% Hamming Radius 2 Hash Lookup
Y(Y<=0)=0;  tY(tY<=0)=0;
[HR2_Precision, success]=eval_HammingRadius2HashLookup(Y, tY, traingnd, testgnd, range);

return
