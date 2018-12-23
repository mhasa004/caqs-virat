% Make (non-negative) potential of each node taking each state
testNodePot = zeros(testnNodes,testMaxState);
for n = 1:testNumANode
    s = testnStates(n);
    testNodePot(n,1:s) = h_test(1:s,n);
end

if pc.withOP
    % Make (non-negative) potential of object nodes taking each state
    for k = 1:length(testONodes);
        n = testONodes(k);
        s = testnStates(n);
        testNodePot(n,1:s) = testObjectsList(2:s+1,k) + pc.ONodeTweak;
    end
    
    % Make (non-negative) potential of people nodes taking each state
    assert(length(PNodes)==size(testPDist,2));
    for k = 1:length(PNodes);
        n = PNodes(k);
        for s = 1:testnStates(n)
            testNodePot(n,s) = testPDist(s,k) + pc.PNodeTweak;
        end
    end
end

% Make (non-negative) potential of each edge taking each state combination
testEdgePot = zeros(testMaxState,testMaxState,testEdgeStruct.nEdges);
nEdges = testEdgeStruct.nEdges;
for e = 1:nEdges
    n1 = testEdgeStruct.edgeEnds(e,1);
    n2 = testEdgeStruct.edgeEnds(e,2);
    
    % A-A edges
    if ismember(n1,testANodes) && ismember(n2,testANodes)
        td = testTemporalDist(n1,n2);
        sd = testSpatialDist(n1,n2);
        testEdgePot(:,:,e) = pc.coFreqAA_m * coFreqAA + pc.coFreqAA_a; % + td + sd;
    end
    
    if pc.withOP
        % A-O or O-A edges
        if (ismember(n1,testANodes)&&ismember(n2,testONodes))||(ismember(n1,testONodes)&&ismember(n2,testANodes))
            if testnStates(n1) > testnStates(n2)
                s1 = testnStates(n1);
                s2 = testnStates(n2);
            else
                s2 = testnStates(n1);
                s1 = testnStates(n2);
            end
            testEdgePot(1:s1,1:s2,e) = pc.coFreqAO_m * coFreqAO(1:s1,2:s2+1) + pc.coFreqAO_a;
        end
        
        % A-P or P-A edges
        if (ismember(n1,testANodes)&&ismember(n2,PNodes))||(ismember(n1,PNodes)&&ismember(n2,testANodes))
            if testnStates(n1) > testnStates(n2)
                s1 = testnStates(n1);
                s2 = testnStates(n2);
            else
                s2 = testnStates(n1);
                s1 = testnStates(n2);
            end
            testEdgePot(1:s1,1:s2,e) = pc.contextAP_m * contextAP + pc.contextAP_a;
        end
    end
end