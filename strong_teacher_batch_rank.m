function ind = strong_teacher_batch_rank(Prob, K, sel)

% Prob is a N x c matrix containing the probability distributions of N samples over c classes
% K is the number of samples to be chosen
% ind are index chosen by batchRand
% BatchRank is an algorithm proposed in dx.doi.org/10.1109/TPAMI.2015.2389848

Prob = Prob';
Prob = Prob(~sel, :);
N = size(Prob,1);
M = zeros(N);
ind = zeros(N,1);

% Compute the M matrix of divergence
for i = 1:N-1
    for j = i+1:N
        C = log2(Prob(i,:)./Prob(j,:));
        C(Prob(j,:)==0) = 0;  C(Prob(i,:)==0) = 0;
        M(i,j) = sum((Prob(i,:) - Prob(j,:)).*C);
    end
end
M = M + M';
% M=zeros(size(M));
A = sum(abs(M),2);

% Compute the Diagonal of the matrix
C = log2(Prob);
C(Prob==0) = 0;
D = -sum(Prob.*C,2);
M = M + 5000*diag(D);

% Obtain Initial Solution
[~,pos] = sort(sum(M));
pos = pos(1:K);
ind(pos) = 1;

% Obtain better solution by Iterated Truncated Power Algorithm
for iter = 1:20
    
    delta = max(max(A-D),0) + 1;
    ind_new = (M+eye(N)*delta)*ind;
    [~,pos] = sort(ind_new);
    pos = pos(1:K);
    
    ind_new = zeros(N,1);
    ind_new(pos) = 1;
    
    if norm(ind-ind_new) < 1
        ind = ind_new;
        break
    end     
    
end
ind = find(ind);

idx = find(~sel);
ind = sort(idx(ind));