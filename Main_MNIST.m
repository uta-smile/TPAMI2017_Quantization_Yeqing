function [results] = Main_MNIST(prefix, maxiter)
% clc; 
close all;  
dbstop if error

addpath mex

styles = {'b-d','r-d','y-d','k-d','m-d','g-d','c-d',...
    'b-x','r-x','y-x','k-x','m-x','g-x','c-x',...
    'b-o','r-o','y-o','k-o','m-o','g-o','c-o'};

dbname = 'MNIST';
% opt.step = 40; % for PCA
opt.step = 60; % for CCA
opt.rffD = 3000;
opt.rho = 1;% 0.0001;
range = 100; %r = 24*1;

if ~exist('maxiter', 'var'),
    maxiter = 20;
end

if ~exist('bitrange', 'var'), 
    bitrange = [16, 32, 64, 128, 256];
    %bitrange = [16, 32, 64];
end

if ~exist('prefix', 'var'),
    prefix = 'unsup_';
    %prefix = 'sup_';
end

switch(prefix)
    case 'unsup_'
        %***** Unsupervised methods
        prefix = 'unsup_';
        methods = {'ITQ', 'PCA', 'LSH', 'SH', 'ITQ-SS', 'PCA-SS'};
        %methods = {'ITQ-SS', 'PCA-SS'};
        isunsup = true;
    case 'unsupk_'
        %***** Unsupervised kernel methods
        prefix = 'unsupk_';
        methods = {'ITQ', 'KPCA-ITQ', 'KPCA-RR', 'KPCA-Direct', 'KPCA-ITQ-SS', 'KPCA-RR-SS', 'KPCA-Direct-SS', 'SKLSH'};
        isunsup = true;
    case 'sup_'
        %***** Supervised methods
        prefix = 'sup_';
        methods = {'CCA-ITQ', 'CCA-RR', 'CCA-Direct', 'CCA-ITQ-SS', 'CCA-RR-SS', 'CCA-Direct-SS', 'ITQ-SS'};
        %methods = {'CCA-ITQ-SS', 'CCA-RR-SS', 'CCA-Direct-SS', 'ITQ-SS'};
        %methods = {'CCA-Direct', 'CCA-Direct-SS', 'ITQ-SS'};
        isunsup = false;
    case 'supk_'
        %***** Supervised-kernel methods
        prefix = 'supk_';
        methods = {'KCCA-ITQ', 'KCCA-RR', 'KCCA-Direct', 'KCCA-ITQ-SS', 'KCCA-RR-SS', 'KCCA-Direct-SS', 'ITQ-SS'};
        %methods = {'KPCA-ITQ-SS', 'KCCA-RR-SS', 'ITQ-SS'};
        isunsup = false;
    otherwise
        error('Unknown prefix');
end

results = containers.Map;

load('mnist_split.mat');
% traindata = traindata(1:25:end, :);
traindata = traindata/255;
testdata = testdata/255;

opt.gamma = 0.005; %optSigma(traindata, 25);

for mi = 1:length(methods),
    result = []; k = 0;
    
    disp(methods{mi});
    for r = bitrange,
        for iter=1:maxiter,
            if isunsup, 
                [Y, tY, tt1(iter)] = func_Hash(methods{mi}, traindata, testdata, r, opt);
            else 
                [Y, tY, tt1(iter)] = func_SupervisedHash(methods{mi}, traindata, testdata, traingnd, r, opt);
            end
            
            %%%% Hamming ranking evaluation
            [PR(:,:,iter), Precision(iter), mAP(iter)]=eval_HammingRanking(Y, tY, traingnd, testgnd, range);

            %%%% Hamming Radius 2 Hash Lookup
            Y(Y<=0)=0;  tY(tY<=0)=0;
            [HR2_Precision(iter), success(iter)]=eval_HammingRadius2HashLookup(Y, tY, traingnd, testgnd, range);
        end
        
        PR=mean(PR, 3); mAP=mean(mAP); Precision=mean(Precision); tt1=mean(tt1); HR2_Precision = mean(HR2_Precision); success = mean(success);
        
        k = k + 1;
        result(k).r = r; 
        result(k).maxiter = maxiter;
        result(k).PR=PR; result(k).mAP=mAP; result(k).Precision=Precision; result(k).tt1=mean(tt1); result(k).HR2_Precision = HR2_Precision; result(k).success = success;
        result(k).opt = opt;
        
        fprintf('mAP=%f; Precision=%f; time=%f (%s %d bit) \n', mAP, Precision, tt1, methods{mi}, r);
        fprintf('HR2_Precision=%f; success=%f (%s %d bit) \n', HR2_Precision, success, methods{mi}, r);
        
        figure(k); hold on;
        plot(PR(1:end,1),PR(1:end,2), styles{mi}, 'linewidth', 3); 
        xlabel('Recall'); ylabel('Precision');
        legend(methods)
        grid;
        set(gca,'FontSize',12);
        set(findall(gcf,'type','text'),'FontSize',14,'fontWeight','bold')
		drawnow
    end
    results(methods{mi}) = result;
end

%***** Save result
outdir = fullfile('output', dbname);
if ~exist(outdir, 'dir')
    mkdir(outdir);
end
save(fullfile(outdir, [prefix 'result.mat']), 'results');
