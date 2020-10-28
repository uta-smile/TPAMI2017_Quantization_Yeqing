function [ROC, mAP, Precision, tt0, HR2_Precision, success]=func_DH(traindata, testdata, traingnd, testgnd, tn, r, range)
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
dhmethod = 3;
sigmas = sqrt(eigenvalue/(n-1)); 
if dhmethod == 1
    unit = sum(sigmas(1:r))/r;
    feabits = ceil(sigmas/unit);
    cumbits = cumsum(feabits);
    k = find(cumbits >= r, 1, 'first');
    t = cumbits(k)-r;
    while true
        if feabits(k) > t
            feabits(k) = feabits(k) - t;
            break;
        else
            k = k - 1;
            t = t - feabits(k);
            continue;
        end
    end
elseif dhmethod == 2
    k = r/2;
    feabits = ones(k, 1)*4;
elseif dhmethod == 3
    subbit = 2;
    k = r;%/subbit;
    feabits = ones(k, 1)*subbit;
end
clear eigenvalue;

feabits = feabits(1:k);
% sigmas = sqrt(sigmas(1:k));
sigmas = sigmas(1:k);
W = U(:,order(1:k)); clear U; clear order;

V = traindata*W; 
[~, R] = ITQ(V, 50); 
Y = V*R;
sigmas = std(Y);
clear temp traindata V;

[Y] = DH(Y, feabits, sigmas);

W = W*R;

%% testing
testdata = testdata-repmat(mvec,tn,1);
tY = testdata*W; 
[tY] = DH(tY, feabits, sigmas);
clear tep testdata;

tt0=toc;

%%%% Hamming ranking evaluation
[ROC, Precision, mAP]=eval_HammingRanking(Y, tY, traingnd, testgnd, range);

%%%% Hamming Radius 2 Hash Lookup
Y(Y<=0)=0;  tY(tY<=0)=0;
[HR2_Precision, success]=eval_HammingRadius2HashLookup(Y, tY, traingnd, testgnd, range);

return
