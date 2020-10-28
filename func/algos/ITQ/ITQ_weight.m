function [B,R,D] = ITQ_weight(V, n_iter, R)
%
% main function for ITQ which finds a rotation of the PCA embedded data
% Input:
%       V: n*c PCA embedded data, n is the number of images and c is the
%       code length
%       n_iter: max number of iterations, 50 is usually enough
% Output:
%       B: n*c binary matrix
%       R: the c*c rotation matrix found by ITQ
% Author:
%       Yunchao Gong (yunchao@cs.unc.edu)
% Publications:
%       Yunchao Gong and Svetlana Lazebnik. Iterative Quantization: A
%       Procrustes Approach to Learning Binary Codes. In CVPR 2011.
%

% initialize with a orthogonal random rotation
bit = size(V,2);
if ~exist('R', 'var'),
    R = randn(bit,bit);
    [U11 S2 V2] = svd(R);
    R = U11(:,1:bit);
end
R = eye(bit);
D = eye(bit);
% allR = zeros(bit, bit, n_iter+1);
% fn = sprintf('R%d.mat', bit);
% load(fn);

% ITQ to find optimal rotation
for iter=0:n_iter
%     allR(:, :, iter+1) = R;
    Z = V * R;      
    %UX = ones(size(Z,1),size(Z,2)).*-1;
    %UX(Z>=0) = 1;
    %UX = sign(Z);
    UX = mexsign(Z*D);
    C = D * (UX' * V);
    [UB,sigma,UA] = svd(C);    
%     R = UA * UB';
    Z = pinv(UX'*UX)*(UX'*Z);
    D = diag(Z);
    D(D<0) = 0;
%     D(D>1) = 1;
    D = diag(D);
end

% make B binary
B = UX;
% B(B<0) = 0;

% save(fullfile('output', 'CIFAR', 'allR_ITQ'), 'allR', 'V');







