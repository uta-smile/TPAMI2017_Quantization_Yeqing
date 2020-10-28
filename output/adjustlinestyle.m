% 
% adjust line style
% 

plot1 = findobj(gcf, 'type', 'line');
% set(plot1(2),'Color',[1 0 0],'LineStyle', '--','DisplayName','KPCA+ITQ-SS');
set(plot1, 'LineWidth', 5);
set(plot1([12 14]),'LineStyle', '--');