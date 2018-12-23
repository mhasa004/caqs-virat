function M = mutual_information(nodeProbs, edgeProbs, numANodes, edgeEnds)

M = zeros(numANodes);

for i = 1:size(edgeEnds, 1)
    x = edgeEnds(i,1);
    y = edgeEnds(i,2);
    if x > numANodes || y > numANodes
        continue;
    end
    Px = nodeProbs(:, x);
    Py = nodeProbs(:, y);
    Pxy = edgeProbs(:,:,i);
    M(x,y) = entropy(Px) + entropy(Py) - joint_entropy(Pxy);
end