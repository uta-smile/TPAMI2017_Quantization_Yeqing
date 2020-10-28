function [ROC, mAP, Precision, tt0, HR2_Precision, success]=func_ITQ_DS(traindata, testdata, traingnd, testgnd, tn, r, range, step)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ***** Idea *****
% Distributed ITQ
% Compute PCA and ITQ independently for each trunk of data.
% Assume that the distances of different projections are comparable.
% 
% Fail!!!
% Why?
% The distances in different projections are not comparable?
% The relation are consistent but the scales are not.
% 
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
[eigenvalue,order] = sort(eigenvalue,'descend'); clear eigenvalue;
Wori = U(:,order(1:r)); clear U; clear order;

testdata = testdata-repmat(mvec,tn,1);

% cov = traindata'*traindata;
allW = cell(1, step);
allY = cell(1, step);
alltY= cell(1, step);
for i = 1:step,
    W = Wori;
    rnum=i:step:n;

    Y = traindata(rnum, :)*W;
    [Y, R] = ITQ(Y, 50); 

    W = W*R;
    allW{i} = W;
    allY{i} = Y;
    
    %% testing
    tY = testdata*W; 
    tY = mexsign(tY);
    
    alltY{i} = tY;
end
clear traindata;
clear tep testdata;

tt0=toc;

%%%% Hamming ranking evaluation
[ROC, Precision, mAP]=eval_HammingRanking(allY, alltY, traingnd, testgnd, range);

%%%% Hamming Radius 2 Hash Lookup
for i = 1:step,
    Y = allY{i}; tY = alltY{i};
    Y(Y<=0)=0;  tY(tY<=0)=0;
    allY{i} = Y; alltY{i} = tY;
end
[HR2_Precision, success]=eval_HammingRadius2HashLookup(allY, alltY, traingnd, testgnd, range);

return
