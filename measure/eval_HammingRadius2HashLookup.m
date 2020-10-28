function [HR2_Precision, success]=eval_HammingRadius2HashLookup(Y, tY, traingnd, testgnd, range)
%
% Find nearest neighbours with in 2 bits difference
% If there are same label data within 2 bits range, consider this sample is
% success
% Precision is define as number of data with same labels within distance
% divided by number of data within 2 bits range
%

tn=length(testgnd);
ham_pre = zeros(1,tn);
list_len = zeros(1,tn);
success = 0;
if isnumeric(Y),
    HamDis = sqdist(Y',tY');
elseif iscell(Y),
    HamDis = zeros(length(traingnd), length(testgnd));
    start = 1; 
    for i = 1:length(Y),
        stop = start + size(Y{i}, 1) - 1;
        HamDis(start:stop, :) = sqdist(Y{i}',tY{i}');
        start = stop + 1;
    end
else
    error('eval_HammingRadius2HashLookup： Unknown data type');
end
for i = 1:tn
    ham = HamDis(:,i); 
    list = find(ham<=2);
    %list = find(ham<=1);
    ln = length(list);
    list_len(i) = ln;
    if ln == 0
        ham_pre(i) = 0;
    else
        ham_pre(i) = length( find(traingnd(list) == testgnd(i)) )/ln;
        success = success+1;
    end
    clear list;    
end
success=success/tn;
HR2_Precision= mean(ham_pre,2);
return