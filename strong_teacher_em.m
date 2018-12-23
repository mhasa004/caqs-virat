function strongIndex = strong_teacher_em(nodeProbs, edgeProbs, numANodes, edgeStruct, K, sel)
% nodeProbs: numClasses x numInstances
% edgeProbs: numClasses x numClasses x numEdges
% Percent of manual labeling
% Indices of the instances to be labeled by a human

% Compute entropy of the individual nodes
H = entropy(nodeProbs);
H = H(~sel);

% Compute mutual information of the pariwise nodes
M = mutual_information(nodeProbs, edgeProbs, numANodes, edgeStruct.edgeEnds);
M = M(~sel,~sel);

% Compute degree of the ndoes
D = M > 0;
D = D + D';
D = sum(D);

% Combine degree with entropy
H = H.*D;

% Greedy solution
strongIndex = [];
while K > 0
   [~, idx1] = max(H); % get the max entropy node from H
   H(idx1) = -1; % remove this node
   K = K - 1;
   if K == 0
       break;
   end
   rowM = M(idx1,:); % get the corresponding row from M
   [~, idx2] = max(H(rowM==min(rowM))); % get the node with maximum entropy which has the minimum mutual information with idx1
   H(idx2) = -1;
   strongIndex = [strongIndex, idx1, idx2];
   K = K - 1;
end

idx = find(~sel);
strongIndex = idx(strongIndex);