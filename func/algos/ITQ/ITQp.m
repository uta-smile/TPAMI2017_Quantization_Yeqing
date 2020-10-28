function [B,R] = ITQp(V, bit, n_iter)
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
d = size(V,2);
R = randn(d,bit);
[U11 S2 V2] = svd(R);
R = U11(:,1:bit);


% ITQ to find optimal rotation
for iter=0:n_iter
    Z = V * R;      
    UX = mexsign(Z);
    C = UX' * V;
    [UB,sigma,UA] = svd(C);    
    R = UA(:, 1:bit) * UB';
end

% make B binary
B = UX;
% B(B<0) = 0;

% save(fullfile('output', 'CIFAR', 'allR_ITQ'), 'allR', 'V');







