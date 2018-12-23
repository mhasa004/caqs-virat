testFeatures = [];
testLabels = [];

for i = pc.testSeq
    for j = 1:allEvents{i}.numEvents
        if abs(sum(allEvents{i}.features(:,j))) > 0
            testFeatures = [testFeatures, allEvents{i}.features(:,j)];
            testLabels = [testLabels, allEvents{i}.eventTypes(j)];
        end
    end
end

if pc.withOP
    testPDist = [];
    testPOverlap = [];
    for i = pc.testSeq
        for j = 1:allEvents{i}.numEvents
            if abs(sum(allEvents{i}.features(:,j))) > 0
                % get distance travled by a person
                for k = 1:length(allEvents{i}.mapObjectsTypes{j})
                    if allEvents{i}.mapObjectsTypes{j}(k)==1
                        flag = 1;
                        fl = allEvents{i}.mapObjectsFirstLocation{j}(k,1:2);
                        ll = allEvents{i}.mapObjectsLastLocation{j}(k,1:2);
                        dist = norm(fl-ll,2);
                        bin = bin_P_dist(dist);
                        testPDist = [testPDist, bin];
                    end
                end 
            end
        end
    end
    % Get associated objects for each event
    testObjectsList = compute_object_list(allEvents, pc.numObjectClasses, pc.testSeq);
end

% Make Adjacency Matrix and EdgeStruct on test data
testNumANode = size(testFeatures, 2);
testnStates = pc.numClasses * ones(1, testNumANode); 

if pc.withOP
    testNumONode = size(testObjectsList, 2);
    testNumPNode = size(testObjectsList, 2);
    testnStates = [testnStates, (pc.numObjectClasses-1) * ones(1, testNumONode)];
    testnStates = [testnStates, pc.pBins * ones(1, testNumPNode)];
end

testMaxState = max(testnStates); % Maximum number of states that any node can take
testnNodes = length(testnStates); % Total number of nodes

%% Compute the adjancecy matrix
testAdj = zeros(testnNodes);

% Link between activity and activity
[testAAdj, testTemporalDist, testSpatialDist] = ...
    make_adjacency(allEvents, pc.testSeq, pc.aa_thr_t, pc.aa_thr_s);
assert(size(testAAdj,1)==testNumANode);

testAdj(1:testNumANode, 1:testNumANode) = testAAdj;

testANodes = 1:testNumANode;
nodeNo = testNumANode;

%% Link between activity,object,and people
if pc.withOP
    % activity-object
    for i = 1:testNumANode
        nodeNo = nodeNo + 1;
        testAdj(i, nodeNo) = 1;
    end
    testONodes = testNumANode+1:testNumANode+testNumONode;

    % activity-people
    PNodes = [];
    for i = 1:size(testObjectsList,2)
        if testObjectsList(1,i)==1
            nodeNo = nodeNo + 1;
            PNodes = [PNodes, nodeNo];
            testAdj(i, nodeNo) = 1;
        end
    end
end

testAdj = testAdj + testAdj';
testEdgeStruct = UGM_makeEdgeStruct(testAdj,testnStates);