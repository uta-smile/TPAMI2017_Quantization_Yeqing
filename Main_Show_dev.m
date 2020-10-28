function Main_Show(dbname, prefix)
clc;close all

styles = {'b-d','r-d','k-d','m-d','g-d','c-d','y-d',...
    'b--x','r--x','k--x','m--x','g--x','c--x','y--x',...
    'b-.o','r-.o','k-.o','m-.o','g-.o','c-.o','y-.o'};

if ~exist('prefix', 'var'),
    prefix = 'unsup_';
    % prefix = 'unsupk_';
    % prefix = 'sup_';
    % prefix = 'supk_';
end

if ~exist('dbname', 'var'),
    % dbname = 'MNIST';
    dbname = 'CIFAR';
end

fn = fullfile('output', dbname, [prefix 'result_dev.mat']);
load(fn);

methods = results.keys();

%elim = {'ITQ', 'ITQ-SS', 'KPCA-RR', 'KPCA-RR-SS'};
elim = {'PCA', 'PCA-SS'};

methods = setdiff(methods, elim);

for mi = 1:length(methods),
    result = results(methods{mi});
    bits = [];
    mAPs = [];
    Pres = [];
    times = [];
    for k = 1:length(result),
        res = result(k);
        fields = fieldnames(res);
        for i = 1:length(fields),
            eval([fields{i} ' = res.' fields{i} ';'])
        end
        if exist('mAP1', 'var'), mAP = mAP1; end
        fprintf('mAP=%f; Precision=%f; time=%f (%s %d bit) \n', mAP, Precision, tt1, methods{mi}, r);
        fprintf('HR2_Precision=%f; success=%f (%s %d bit) \n', HR2_Precision, success, methods{mi}, r);
        
        if r == 20,
            continue;
        end
        bits = [bits, r];
        mAPs = [mAPs, mAP];
        Pres = [Pres, Precision];
        times = [times, tt1];
        
        % Precision-Recall plot
        %figure(k); hold on;
        %xlabel('Recall'); ylabel('Precision');
        %plotCurve(PR(1:end,1),PR(1:end,2), styles{mi});
        %legend(methods)
    end
    X = 1:numel(bits);
    if strcmp(methods{mi}, 'ITQ'),
        Pres(:) = max(Pres)
    end
    % mAP plot
    figure(10); hold on;
    xlabel('Sample Ratio'); ylabel('mAP');
    plotCurve(X, mAPs, styles{mi}, true, bits);
    legend(methods) 
    
    % Precision plot
    figure(11); hold on;
    xlabel('Sample Ratio'); ylabel('Precision');
    plotCurve(X, Pres, styles{mi}, true, bits);
    %legend(methods) 
    axis tight
    %ylim([0.26 0.31]) % CIFAR
    ylim([0.76 0.86]) % MNIST
    
    % Running time plot
    figure(12); hold on;
    xlabel('Sample Ratio'); ylabel('Training Time (seconds)');
    plotCurve(X, times, styles{mi}, true, bits);
    legend(methods) 
end

function plotCurve(X, Y, sty, setticks, bits)

if ~exist('setticks', 'var'),
    setticks = false;
end

plot(X, Y, sty, 'linewidth', 3); 
grid off;
box on;
set(gca,'FontSize',16);
set(findall(gcf,'type','text'),'FontSize',16,'fontWeight','bold')

if setticks,
    set(gca,'XTick', 1:numel(bits))
    set(gca,'XTickLabel', strread(num2str(bits),'%s'))
end
