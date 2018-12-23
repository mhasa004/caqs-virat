% Make (non-negative) potential of each node taking each state
newNodePot = zeros(newNNodes,newMaxState);
for n = 1:newNumANode
    for s = 1:newnStates(n)
        newNodePot(n,s) = h_train(s,n);
    end
end

% Make (non-negative) potential of object nodes taking each state
if pc.withOP
    for k = 1:length(newONodes);
        n = newONodes(k);
        s = newnStates(n);
        newNodePot(n,1:s) = new_object_list(2:s+1,k) + pc.ONodeTweak;
    end
end

% Make (non-negative) potential of each edge taking each state combination
newEdgePot = zeros(newMaxState,newMaxState,newEdgeStruct.nEdges);
nNewEdges = newEdgeStruct.nEdges;

for e = 1:nNewEdges
    n1 = newEdgeStruct.edgeEnds(e,1);
    n2 = newEdgeStruct.edgeEnds(e,2);
    % A-A edges
    if ismember(n1,newANodes) && ismember(n2,newANodes)
        td = newTemporalDist(n1,n2);
        sd = newSpatialDist(n1,n2);
        newEdgePot(:,:,e) = pc.coFreqAA_m * coFreqAA + pc.coFreqAA_a; %td + sd + ;
    end
    % A-O or O-A edges
    if pc.withOP
        if (ismember(n1,newANodes)&&ismember(n2,newONodes))||(ismember(n1,newONodes)&&ismember(n2,newANodes))
            if newnStates(n1) > newnStates(n2)
                s1 = newnStates(n1);
                s2 = newnStates(n2);
            else
                s2 = newnStates(n1);
                s1 = newnStates(n2);
            end
            newEdgePot(1:s1,1:s2,e) = pc.coFreqAO_m * coFreqAO(1:s1,2:s2+1) + pc.coFreqAO_a;
        end
    end
end
