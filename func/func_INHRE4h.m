function [ROC, mAP, Precision, tt0]=func_INHRE4h(data, gnd, num_test, bit, range, P)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% INHRE: Incremental Hashing with Regression and Error
%%%% data_{n x d} = [traindata; testdata]; gnd=[traingnd; testgnd];
%%%% num_test: the number of test data
%%%% bit: the bit number of hamming code
%%%% range: how many neighbors to check?
%%%% P: how many data in each batch
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tic;
XX=data'; clear data;
[d, n]=size(XX);

% P=200; 
T=(n-num_test)/P; num=50;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%% initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RW=zeros(bit, d, T);
MU=zeros(d, T); 
Q=zeros(bit, bit, T);
B0=zeros(bit, n-num_test);
maxv=zeros(1, T);
E=zeros(bit, n-num_test);
 
tmpl.mean = zeros(d,1);tmpl.basis = [];
tmpl.eigval = []; tmpl.numsample = 0; tmpl.reseig = 0;

R = randn(bit,bit);[U11 S2 V2] = svd(R); R1 = U11(:,1:bit)';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Batch processing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for batch = 1:T
    start=(batch-1)*P+1; stop=P*batch; 
    X2=XX(:, start:stop);
    [tmpl.basis, tmpl.eigval, tmpl.mean, tmpl.numsample] = ...
        sklm(X2, tmpl.basis, tmpl.eigval, tmpl.mean, tmpl.numsample, 1, bit);            
    W2=tmpl.basis(:,1:bit)'; mu2=tmpl.mean;   
    
    RW2=R1*W2; 
    X2=X2-repmat(mu2, [1 size(X2,2)]);
    
    tmpZ=RW2*X2; maxv(batch)=max(abs(tmpZ(:)));
    tmpB = ones(size(tmpZ,1),size(tmpZ,2)).*-1;
    tmpB(tmpZ>=0) = 1;
    
    tQ=(tmpZ/maxv(batch))*tmpB'*inv(tmpB*tmpB'+0.000001*eye(bit));
    tE=tmpZ/maxv(batch)-tQ*tmpB;
    
    mu2e=mean(tE, 2);
    tE2=tE-repmat(mu2e, [1 size(tE,2)]);
    maxv2(batch)=max(abs(tE2(:)));
    tmpB2 = ones(size(tE2,1),size(tE2,2)).*-1;
    tmpB2(tE2>=0) = 1;
    
    tQ2=(tE2/maxv2(batch))*tmpB2'*inv(tmpB2*tmpB2'+0.000001*eye(bit));
    tE3=tE2/maxv2(batch)-tQ2*tmpB2;
    
    mu3e=mean(tE3, 2);
    tE3=tE3-repmat(mu3e, [1 size(tE3,2)]);
    maxv3(batch)=max(abs(tE3(:)));
    tmpB3 = ones(size(tE3,1),size(tE3,2)).*-1;
    tmpB3(tE3>=0) = 1;
    
    tQ3=(tE3/maxv3(batch))*tmpB3'*inv(tmpB3*tmpB3'+0.000001*eye(bit));
    tE4=tE3/maxv3(batch)-tQ3*tmpB3;
    
    
    mu4e=mean(tE4, 2);
    tE4=tE4-repmat(mu4e, [1 size(tE4,2)]);
    maxv4(batch)=max(abs(tE4(:)));
    tmpB4 = ones(size(tE4,1),size(tE4,2)).*-1;
    tmpB4(tE4>=0) = 1;
    
    tQ4=(tE4/maxv4(batch))*tmpB4'*inv(tmpB4*tmpB4'+0.000001*eye(bit));
    tE5=tE4/maxv4(batch)-tQ4*tmpB4;
    
    
    Q(:,:,batch)=tQ; Q2(:,:,batch)=tQ2; Q3(:,:,batch)=tQ3; Q4(:,:,batch)=tQ4;      
    E(:,start:stop)=tE;
    B0(:,start:stop)=tmpB; B02(:,start:stop)=tmpB2;  B03(:,start:stop)=tmpB3; B04(:,start:stop)=tmpB4;  
    RW(:,:,batch)=RW2;
    MU(:,batch)=mu2; MU2(:,batch)=mu2e; MU3(:,batch)=mu3e; MU4(:,batch)=mu4e;
    W1=W2; mu1=mu2;
end

% index=find(E==0);
% ratio=length(index)/prod(size(E))

V=zeros(bit, n-num_test); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FINAL  UPDATING V
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for batch = 1:T,
    start=(batch-1)*P+1; stop=P*batch; 
    temp=W2*(MU(:,batch)-mu2);
    RW1(:,:)=RW(:,:,batch);
    tQ(:,:)=Q(:,:,batch);
    tQ2(:,:)=Q2(:,:,batch);
    tQ3(:,:)=Q3(:,:,batch);
    tQ4(:,:)=Q4(:,:,batch);
    
    tE4=tQ4*B04(:,start:stop)*maxv4(batch);
    tE4=tE4+repmat(MU4(:,batch), [1, size(tE4, 2)]);
    
    tE3=(tQ3*B03(:,start:stop)+tE4)*maxv3(batch);
    tE3=tE3+repmat(MU3(:,batch), [1, size(tE3, 2)]);
    
    tE=(tQ2*B02(:,start:stop)+tE3)*maxv2(batch);
    tE=tE+repmat(MU2(:,batch), [1, size(tE, 2)]);
    
    tZ=(tQ*B0(:,start:stop)+tE)*maxv(batch);
    
    V(:,start:stop)=(W2*RW1')*tZ+repmat(temp, [1 stop-start+1]);
end
   
R=R1;     

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FINAL  UPDATING R and B
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for iter=1:num,
    Z = R* V;    
    B = ones(size(Z,1),size(Z,2)).*-1; 
    B(Z>=0) = 1;      
    C = B * V';
    [UB,sigma,UA] = svd(C);    
    R = UB * UA';            
end

Y=single(B');
clear V Z B C

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% testing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tV=W2*(XX(:,n-num_test+1:end)-repmat(mu2, [1 num_test]));
tZ = R * tV; 
tB = ones(size(tZ,1),size(tZ,2)).*-1; 
tB(tZ>0) = 1;      
tY=single(tB');

clear XX tV tZ tB;

tt0=toc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Evaluation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
traingnd=gnd(1:end-num_test,:); testgnd=gnd(end-num_test+1:end,:);
%%%% Hamming ranking evaluation
[ROC, Precision, mAP]=eval_HammingRanking(Y, tY, traingnd, testgnd, range);

%%%% Hamming Radius 2 Hash Lookup
Y(find(Y<=0))=0;  tY(find(tY<=0))=0;
[HR2_Precision, success]=eval_HammingRadius2HashLookup(Y, tY, traingnd, testgnd, range);

return
