function [Y, tY, tt0, W, mvec]=func_SupervisedHash(method, traindata, testdata, trainlabels, r, opt)
%FUNC_SUPERVISEDHASH   Transform contineous feature to binary codes.  
% [Y, tY, tt0, W, mvec]=func_SupervisedHash(method, traindata, testdata, trainlabels, r, opt)
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

if any(size(trainlabels)) == 1,
    trainlabels = sparse(1:length(trainlabels), trainlabels, 1);
end

tic;

if ~exist('opt', 'var'),
    opt = [];
end

%%%%%%%%%%%%%% training
[n,d] = size(traindata);
tn = size(testdata, 1);

if strcmp(method(1:4), 'KCCA') || strcmp(method(1:4), 'KPCA'),
    %***** Use random kernel features
    RFparam.gamma = opt.gamma;
    RFparam.D = d;
    RFparam.M = opt.rffD;
    RFparam = RF_train(RFparam);

    traindata = sqrt(2) * cos(bsxfun(@plus, traindata * RFparam.R, RFparam.B));
    testdata = sqrt(2) * cos(bsxfun(@plus, testdata * RFparam.R, RFparam.B));
    
    % Mapping method back to origin
    switch(method)
        case 'KPCA-ITQ'
            method = 'ITQ';
        case 'KCCA-ITQ'
            method = 'CCA-ITQ';
        case 'KCCA-RR'
            method = 'CCA-RR';
        case 'KCCA-Direct'
            method = 'CCA-Direct';
        case 'KCCA-ITQ-SS'
            method = 'CCA-ITQ-SS';
        case 'KCCA-RR-SS'
            method = 'CCA-RR-SS';
        case 'KCCA-Direct-SS'
            method = 'CCA-Direct-SS';
        case 'KPCA-ITQ-SS'
            method = 'ITQ-SS';
        otherwise
            error('Unknown approach.');
    end
end

mvec = mean(traindata,1);
% traindata = traindata-repmat(mvec,n,1);
traindata = bsxfun(@minus, traindata, mvec);

rho = opt.rho; % Regularization term for CCA

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
    case 'CCA-ITQ'
        % CCA
        [W, eigenvalue] = cca(traindata, trainlabels, rho);
        W = W(:,1:r)*diag(eigenvalue(1:r));
        clear eigenvalue

        Y = traindata*W;
        [Y, R] = ITQ(Y, 50); clear temp traindata;

        W = W*R;
    case 'CCA-Direct'
        % CCA
       [W, eigenvalue] = cca(traindata, trainlabels, rho); 
       W = W(:,1:r)*diag(eigenvalue(1:r));
       clear eigenvalue

        Y = traindata*W;
        Y = mexsign(Y);
    case 'CCA-RR'
        % CCA
        [W, eigenvalue] = cca(traindata, trainlabels, rho);
        W = W(:,1:r)*diag(eigenvalue(1:r));
        clear eigenvalue
        
        % Random rotation matrix
        R = randn(r,r);
        [U11 S2 V2] = svd(R);
        R = U11(:,1:r);
        W = W*R;

        Y = traindata*W;
        Y = mexsign(Y);
    case 'ITQ-SS'
        step = opt.step;
        rnum=1:step:n;
        sub = traindata(rnum, :);
        cov = sub'*sub; clear sub

        [U,V] = eig(cov); clear cov;
        eigenvalue = diag(V)'; clear V;
        [eigenvalue,order] = sort(eigenvalue,'descend'); 
        W = U(:,order(1:r)); clear U; clear order eigenvalue;

        Y = traindata*W;
        [Y, R] = ITQSS(Y, 50, step); clear temp traindata;

        W = W*R;
    case 'CCA-ITQ-SS'
        step = opt.step;
        rnum=1:step:n;
        sub = traindata(rnum, :);

        % CCA
        [W, eigenvalue] = cca(sub, trainlabels(rnum, :), rho/step);
        W = W(:,1:r)*diag(eigenvalue(1:r));
        clear eigenvalue sub

        Y = traindata*W;
        [Y, R] = ITQSS(Y, 50, step); clear temp traindata;

        W = W*R;
    case 'CCA-Direct-SS'
        step = opt.step;
        rnum=1:step:n;
        sub = traindata(rnum, :);
        % CCA
        [W, eigenvalue] = cca(sub, trainlabels(rnum, :), rho/step);
        W = W(:,1:r)*diag(eigenvalue(1:r));
        clear eigenvalue sub

        Y = traindata*W;
        Y = mexsign(Y);
    case 'CCA-RR-SS'
        step = opt.step;
        rnum=1:step:n;
        sub = traindata(rnum, :);
        % CCA
        [W, eigenvalue] = cca(sub, trainlabels(rnum, :), rho/step);
        W = W(:,1:r)*diag(eigenvalue(1:r));
        clear eigenvalue sub
        
        % Random rotation matrix
        R = randn(r,r);
        [U11 S2 V2] = svd(R);
        R = U11(:,1:r);
        W = W*R;

        Y = traindata*W;
        Y = mexsign(Y);
    % SSH
    % J. Wang, S. Kumar and S.-F. Chang. Semi-Supervised Hashing for 
    % Scalable Image Retrieval. CVPR 2010.
    case 'SSH'
        eta = 0.0001;
        XS = traindata'*trainlabels;
        cov = eta*(traindata'*traindata) + XS*XS';

        [U,V] = eig(cov); clear cov;
        eigenvalue = diag(V)'; clear V;
        [eigenvalue,order] = sort(eigenvalue,'descend'); clear eigenvalue;
        W = U(:,order(1:r)); clear U; clear order;

        Y = traindata*W;
        Y = mexsign(Y);
    case 'SSH-ITQ'
        % PCA
        eta = 0.0001;
        XS = traindata'*trainlabels;
        cov = eta*(traindata'*traindata) + XS*XS';
        [U,V] = eig(cov); clear cov;
        eigenvalue = diag(V)'; clear V;
        [eigenvalue,order] = sort(eigenvalue,'descend'); clear eigenvalue;
        W = U(:,order(1:r)); clear U; clear order;

        Y = traindata*W;
        [Y, R] = ITQ(Y, 50); clear temp traindata;

        W = W*R;
    otherwise
        error('Unknown method');
end

%% testing
if strcmpi(method, 'SH'),
    [~,tY] = compressSH(testdata, SHparam);
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
