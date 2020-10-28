function [W] = RF_features(X, RFparam)

N = size(X,1);

B = repmat(RFparam.B, N, 1);

%%
%% compute random features
%%
W = sqrt(2) * cos(X * RFparam.R + B);
