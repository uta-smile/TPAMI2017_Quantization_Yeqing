function [results] = Main_TINY1M(prefix)
% clc; 
close all;  
dbstop if error

addpath mex

styles = {'b-d','r-d','y-d','k-d','m-d','g-d','c-d'};

dbname = 'TINY1M';
opt.step = 1000; 
maxiter = 1;
range = 50000; %r = 24*1;
if ~exist('bitrange', 'var'), 
    % bitrange = [16, 32, 64, 128, 256];
    bitrange = [16, 32, 64];
end

if ~exist('prefix', 'var'),
    prefix = 'unsup_';
end

switch(prefix)
    case 'unsup_'
        %***** Unsupervised methods
        prefix = 'unsup_';
        methods = {'ITQ', 'PCA', 'LSH', 'SH', 'ITQ-SS', 'PCA-SS'};
        %methods = {'ITQ-SS', 'PCA-SS'};
    case 'unsupk_'
        %***** Unsupervised kernel methods
        prefix = 'unsupk_';
        methods = {'ITQ', 'KPCA+ITQ', 'KPCA-RR', 'KPCA-Direct', 'KPCA+ITQ-SS', 'KPCA-RR-SS', 'KPCA-Direct-SS', 'SKLSH'};
    otherwise
        error('Unknown prefix');
end
results = containers.Map;

% load('gist_trn.mat');
% load('gist_tst.mat');
load('eightyMsubset_hash_final.mat');
load('eightyMsubset_gnd.mat');
% traindata = traindata(1:25:end, :);
% traindata=gist_trn; clear gist_trn;
% testdata=gist_tst; clear gist_tst;

tn=2000;  
gist_tst=gist_tst(:,1:tn);

for mi = 1:length(methods),
    result = []; k = 0;
    
    disp(methods{mi});
    for r = bitrange,
        for iter=1:maxiter,
            [Y, tY, tt1(iter)] = func_Hash(methods{mi}, gist_trn, gist_tst, r, opt);
            
            %%%% Hamming ranking evaluation
            [PR(:,:,iter), Precision(iter), mAP(iter)]=weak_HammingRankingFast(Y, tY, knn_gnd, range);
        end
        
        PR=mean(PR, 3); mAP=mean(mAP); Precision=mean(Precision); tt1=mean(tt1); 
        
        k = k + 1;
        result(k).r = r; 
        result(k).maxiter = maxiter;
        result(k).PR=PR; result(k).mAP=mAP; result(k).Precision=Precision; result(k).tt1=mean(tt1); 
        
        fprintf('mAP=%f; Precision=%f; time=%f (%s %d bit) \n', mAP, Precision, tt1, methods{mi}, r);
        
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

