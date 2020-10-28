function [Y, tY, tt0, W, mvec]=func_Hash(method, traindata, testdata, r, opt)
% [Y, tY, tt0, W, mvec]=func_Hash(method, traindata, testdata, r, opt)
% Transform contineous feature to binary codes.  
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% method: hash algorithm
%%%% data_{n x d} = [traindata; testdata]; gnd=[traingnd; testgnd];
%%%% tn: the number of test data
%%%% r: the bit number
%%%% opt.range: how many neighbors to check?
%%%% opt.step: sample ratio for sub-selective version of hash algorithm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tic;
[dim1, dim2] = size(traindata);
if dim1 < dim2
    testdata=testdata';
    traindata=traindata';
end
toc

tic;

if ~exist('opt', 'var'),
    opt = [];
end

%%%%%%%%%%%%%% training
[n,d] = size(traindata);
tn = size(testdata, 1);

if length(method)>4 && strcmp(method(1:4), 'KPCA'),
    %***** Use random kernel features
    RFparam.gamma = opt.gamma;%1;
    RFparam.D = d;
    RFparam.M = opt.rffD;
    RFparam = RF_train(RFparam);

    traindata = sqrt(2)*cos(bsxfun(@plus, traindata * RFparam.R, RFparam.B));
    testdata = sqrt(2)*cos(bsxfun(@plus, testdata * RFparam.R, RFparam.B));
    
    % Mapping method back to origin
    switch(method)
        case 'KPCA-ITQ'
            method = 'ITQ';
        case 'KPCA-RR'
            method = 'PCA-RR';
        case 'KPCA-Direct'
            method = 'PCA';
        case 'KPCA-ITQ-SS'
            method = 'ITQ-SS';
        case 'KPCA-RR-SS'
            method = 'PCA-RR-SS';
        case 'KPCA-Direct-SS'
            method = 'PCA-SS';
        otherwise
            error('Unknown approach.');
    end
end

mvec = mean(traindata,1);
% traindata = traindata-repmat(mvec,n,1);
traindata = bsxfun(@minus, traindata, mvec);

switch(method) 
    case 'ITQ'
        % PCA
        cov = traindata'*traindata;
        [U,V] = eig(cov); clear cov;
        eigenvalue = diag(V)'; clear V;
        [eigenvalue,order] = sort(eigenvalue,'descend'); clear eigenvalue;
        W = U(:,order(1:r)); clear U; clear order;

        Y = traindata*W;
        [Y, R] = ITQ(Y, 50); clear temp traindata;

        W = W*R;
    case 'PCA'
        cov = traindata'*traindata;

        [U,V] = eig(cov); clear cov;
        eigenvalue = diag(V)'; clear V;
        [eigenvalue,order] = sort(eigenvalue,'descend'); clear eigenvalue;
        W = U(:,order(1:r)); clear U; clear order;

        Y = traindata*W;
        Y = mexsign(Y);
    case 'PCA-RR'
        cov = traindata'*traindata;

        % Eigenvectors
        [U,V] = eig(cov); clear cov;
        eigenvalue = diag(V)'; clear V;
        [eigenvalue,order] = sort(eigenvalue,'descend'); clear eigenvalue;
        W = U(:,order(1:r)); clear U; clear order;
        
        % Random rotation matrix
        R = randn(r,r);
        [U11 S2 V2] = svd(R);
        R = U11(:,1:r);
        W = W*R;

        Y = traindata*W;
        Y = mexsign(Y);
    % Locality sensitive hashing (LSH)
    case 'LSH'
        W = randn(d, r);

        V = traindata*W; clear temp traindata;
        Y = mexsign(V); 
    case 'SH'
        SHparam.nbits = r; % number of bits to code each sample

        % training
        SHparam = trainSH(traindata, SHparam);
        
        % compress training and test set
        [~, Y] = compressSH(traindata, SHparam);
        Y = mexsign(Y);
        W = SHparam;
    case 'ITQ-SS'
        step = opt.step;
        rnum=1:step:n;
        sub = traindata(rnum, :);
        cov = sub'*sub; clear sub

        [U,V] = eig(cov); clear cov;
        eigenvalue = diag(V)'; clear V;
        [eigenvalue,order] = sort(eigenvalue,'descend'); clear eigenvalue;
        W = U(:,order(1:r)); clear U; clear order;

        Y = traindata*W;
        [Y, R] = ITQSS(Y, 50, step); clear temp traindata;

        W = W*R;
    case 'PCA-SS'
        step = opt.step;
        rnum=1:step:n;
        sub = traindata(rnum, :);
        cov = sub'*sub; clear sub

        [U,V] = eig(cov); clear cov;
        eigenvalue = diag(V)'; clear V;
        [eigenvalue,order] = sort(eigenvalue,'descend'); clear eigenvalue;
        W = U(:,order(1:r)); clear U; clear order;

        Y = traindata*W;
        Y = mexsign(Y);
    case 'PCA-RR-SS'
        step = opt.step;
        rnum=1:step:n;
        sub = traindata(rnum, :);
        cov = sub'*sub; clear sub

        % Eigenvectors
        [U,V] = eig(cov); clear cov;
        eigenvalue = diag(V)'; clear V;
        [eigenvalue,order] = sort(eigenvalue,'descend'); clear eigenvalue;
        W = U(:,order(1:r)); clear U; clear order;
        
        % Random rotation matrix
        R = randn(r,r);
        [U11 S2 V2] = svd(R);
        R = U11(:,1:r);
        W = W*R;

        Y = traindata*W;
        Y = mexsign(Y);
    % SKLSH
    % M. Raginsky, S. Lazebnik. Locality Sensitive Binary Codes from
    % Shift-Invariant Kernels. NIPS 2009.
    case 'SKLSH'
        %RFparam.gamma = 1;
        RFparam.gamma = opt.gamma;
        RFparam.D = d;
        RFparam.M = r;
        RFparam = RF_train(RFparam);
        [~, Y] = RF_compress(traindata, RFparam);
        W = RFparam;
    otherwise
        error('Unknown method');
end

%% testing
if strcmpi(method, 'SH'),
    [~,tY] = compressSH(testdata, SHparam);
elseif strcmp(method, 'SKLSH'),
    testdata = testdata-repmat(mvec,tn,1);
    [~, tY] = RF_compress(testdata, RFparam);
else
    testdata = testdata-repmat(mvec,tn,1);
    tY = testdata*W; 
end
tY = mexsign(tY);
clear tep testdata;

tt0=toc;

%savetomat(Y, tY, traindata, testdata, traingnd, testgnd)

return


function savetomat(trainHash, testHash, traindata, testdata, traingnd, testgnd)

disp('Save mnist hash code');

save mnist_hash trainHash testHash traindata testdata traingnd testgnd
