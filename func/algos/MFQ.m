function [Y,U] = MFQ(traindata, r, mf_iter, itq_iter)
%
% main function for ITQ which finds a rotation of the PCA embedded data
% Input:
%       V: n*c PCA embedded data, n is the number of images and c is the
%       code length
%       n_iter: max number of iterations, 50 is usually enough
% Output:
%       B: n*c binary matrix
%       R: the c*c rotation matrix found by ITQ
%

[n,d] = size(traindata);
mvec = mean(traindata,1);
% traindata = traindata-repmat(mvec,n,1);
traindata = bsxfun(@minus, traindata, mvec);
cov = traindata'*traindata;
[U,V] = eig(cov); clear cov;
eigenvalue = diag(V)'; clear V;
[eigenvalue,order] = sort(eigenvalue,'descend'); clear eigenvalue;
W = U(:,order(1:r)); clear U; clear order;

Y = traindata*W; % n by r
X = traindata'; % to d by n
clear traindata

% initialization
Y = mexsign(Y); % n by r
U = W;

obj = zeros(mf_iter, 1);
for i = 1:mf_iter,
    % Fix Y, compute U
    U = X*Y*pinv(Y'*Y); % d by c

    % Fix U, compute Y
    B = X'*U;  % n by c
    A = U'*U;  % c by c

    Y_new = zeros(size(Y)); % n by r
    for k = 1:r
        Y_new(:, k) = B(:, k) - Y*A(:, k) + A(k, k)*Y(:, k);
    end
    Y = mexsign(Y_new);
    obj(i) = norm(X-U*Y', 'fro');
end
% figure(100*itq_iter+mf_iter+1); plot(obj); title('objective value'); drawnow

% U = U*pinv(U'*U);
% Y = mexsign(X'*U);
Y = X'*U;
[Y, R] = ITQ(Y, itq_iter);
U = U*R;


