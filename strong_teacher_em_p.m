function strongIndex = strong_teacher_em_p(nodeProbs, edgeProbs, numANodes, edgeStruct, K, sel)
% nodeProbs: numClasses x numInstances
% edgeProbs: numClasses x numClasses x numEdges
% Percent of manual labeling
% Indices of the instances to be labeled by a human

% Need to install IBM CPlex
use_cplex = 0;

% Compute entropy of the individual nodes
H = entropy(nodeProbs);
H = H(~sel);

% Compute mutual information of the pariwise nodes
M = mutual_information(nodeProbs, edgeProbs, numANodes, edgeStruct.edgeEnds);
M = M(~sel, ~sel);

N = length(H);

% Binary Quadratic Optimization Solution
M = M + M';
ch = 'B';
for i = 1:N-1
    ch = strcat(ch,'B');
end

if use_cplex
    r = max(sum(abs(M))) + 0.01;
    x = cplexmiqp(-M + r*eye(size(M)),-H+sum(M),[],[],ones(1,N),K,[],[],[],zeros(N,1),ones(N,1),ch);    
    strongIndex = find(x==1);
else    
    if any(M(:))
        Q = -M;
        f = (-H + sum(M))';
%         save Q Q
%         save f f
        l = zeros(N,1);
        u = ones(N,1);
        n = N;
        r = max(sum(abs(Q)));
        x = branchBound(Q,f,K);        
        strongIndex = find(x==1);
    else
        [~,pos] = sort(H,'descend');
        strongIndex = pos(1:K);
    end
    idx = find(~sel);
    strongIndex = idx(strongIndex);
end



