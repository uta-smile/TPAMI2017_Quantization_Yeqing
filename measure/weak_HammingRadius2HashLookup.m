function [HR2_Precision, success]=weak_HammingRadius2HashLookup(Y, tY, gnd, range)
%%%%%%  gnd=knn_gnd (pesudo label from knn)

pn = 200;
tn=size(tY, 1);
ham_pre = zeros(1,tn);
list_len = zeros(1,tn);
success = 0;
for i = 1:tn/pn
%     [i]
    HamDis = sqdist(tY((i-1)*pn+1:i*pn,:)', Y');
    for j = 1:pn
        ii = (i-1)*pn+j;
        list = find(HamDis(j,:) <= 2);
        ln = length(list);
        list_len(ii) = ln;
        
        if ln == 0
            ham_pre(ii) = 0;
        else
            ham_pre(ii) = length( intersect(list,gnd(ii,:)) )/ln;
            success = success+1;
        end
        clear list;    
    end
end
success=success/tn;
HR2_Precision= mean(ham_pre,2);
return