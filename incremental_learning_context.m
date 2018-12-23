fprintf('Strong Teacher - %d, Weak Teacher - %d\n', pc.strongTeacher, pc.weakTeacher);

acc_context = [];
acc_no_context = [];
res_context = [];
res_no_context = [];
acc_train = [];

%% Train initial model with batch-1 data
if pc.withOP
    coFreqAO = zeros(pc.numClasses, pc.numObjectClasses);
    contextAP = zeros(pc.numClasses, pc.pBins);
end

this_batch = batches{1};
initial_train_features = [];
initial_train_labels = [];
for k = this_batch
    for j = 1:allEvents{k}.numEvents
        if abs(sum(allEvents{k}.features(:,j))) > 0
            initial_train_features = [initial_train_features, allEvents{k}.features(:,j)];
            initial_train_labels = [initial_train_labels, allEvents{k}.eventTypes(j)];
        end
    end
end
total_train_ins = total_train_ins + length(initial_train_labels);
% Compute associated objects of the events
if pc.withOP
    new_object_list = compute_object_list(allEvents, pc.numObjectClasses, this_batch);
end

% Gather context features
% Co-occurance frequencies among the activities
coFreqAA = co_frequency(allEvents, this_batch, pc.numClasses, pc.aa_thr_t, pc.aa_thr_s);

if pc.withOP
    % Co-occurance frequencies of the activity and objects
    coFreqAO = compute_co_freq_AO(coFreqAO, initial_train_labels, new_object_list, pc.numClasses);
    % Activity people context
    for b = this_batch
        types = allEvents{b}.eventTypes;
        for j = 1:allEvents{b}.numEvents
            for k = 1:length(allEvents{b}.mapObjectsTypes{j})
                if allEvents{b}.mapObjectsTypes{j}(k)==1
                    fl = allEvents{b}.mapObjectsFirstLocation{j}(k,1:2);
                    ll = allEvents{b}.mapObjectsLastLocation{j}(k,1:2);
                    dist = norm(fl-ll,2);
                    bin = bin_P_dist(dist);
                    contextAP(types(j),:) = contextAP(types(j),:) + bin';
                end
            end
        end
    end
end

% Update the appearance model
options.maxIter = 400;
softmaxModel = softmaxTrainNew(pc.inputSize, pc.numClasses, pc.lambda, ...
    initial_train_features, initial_train_labels, options);

% Get the labels from the appearance model
[pred, h_test] = softmaxPredict(softmaxModel, testFeatures);
acc_no_context = [acc_no_context, mean(testLabels == pred)];
res_no_context = [res_no_context; pred];

run assign_test_potentials.m

[nodeProbs_test, edgeProbs_test, ~] = UGM_Infer_LBP(testNodePot,testEdgePot,testEdgeStruct);
[~,res_infer] = max(nodeProbs_test,[],2);
res_context = [res_context; res_infer'];
acc_context = [acc_context, mean(testLabels(:) == res_infer(1:testNumANode))];

fprintf('Iter\tTotal\tStrong\tWeak\tNo-Context\tContext\tTrain-Acc\n');
fprintf('-----------------------------------------------------------\n');
fprintf('0\t%d\t%d\t%d\t%0.2f\t\t%0.2f\n', ...
    length(initial_train_labels), length(initial_train_labels), 0, ...
    100*acc_no_context(end), 100*acc_context(end));

    
%% Process rest of the training data
% Merge rest of the batches
this_batch = [];
for batch = 2:pc.numBatch
    this_batch = [this_batch, batches{batch}];
end

% Construct the CRF with all training data
train_features = [];
train_labels = [];
train_seqs_ids = []; % contains the seq number and id of an activity
for k = this_batch
    for j = 1:allEvents{k}.numEvents
        if abs(sum(allEvents{k}.features(:,j))) > 0
            train_features = [train_features, allEvents{k}.features(:,j)];
            train_labels = [train_labels, allEvents{k}.eventTypes(j)];
            train_seqs_ids = [train_seqs_ids, [k;j]];
        end
    end
end
total_train_ins = total_train_ins + length(train_labels);
% Compute associated objects of the events
if pc.withOP
    new_object_list = compute_object_list(allEvents, pc.numObjectClasses, this_batch);
end

% Make UGM data structures for the new video sequence
newNumANode = size(train_features, 2);
newnStates = pc.numClasses * ones(1, newNumANode);

if pc.withOP
    newNumONode = size(new_object_list, 2);
    newnStates = [newnStates, (pc.numObjectClasses-1) * ones(1, newNumONode)];
end

newMaxState = max(newnStates);
newNNodes = length(newnStates);

% Make Adjacency Matrix and EdgeStruct for new data
newAdj = zeros(newNNodes);
[newAAdj, newTemporalDist, newSpatialDist] = ...
    make_adjacency(allEvents, this_batch, pc.aa_thr_t, pc.aa_thr_s);

newAdj(1:newNumANode, 1:newNumANode) = newAAdj;

newANodes = 1:newNumANode;
nodeNo = newNumANode;

if pc.withOP
    % Link between activity and object
    for k = 1:newNumONode
        nodeNo = nodeNo + 1;
        newAdj(k, nodeNo) = 1;
    end
    newONodes = newNumANode+1:newNumANode+newNumONode;
end
newAdj = newAdj + newAdj';
newEdgeStruct = UGM_makeEdgeStruct(newAdj,newnStates);

%% Iteratively perfrom active learning on the training data
strong_sel = false(1, newNumANode);
weak_sel = false(1, newNumANode);
total_sel = strong_sel | weak_sel;

iter = 0;
while sum(total_sel) + pc.K < length(train_labels)
    iter = iter + 1;    
    % Get predictions from the current appearance model
    [~, h_train] = softmaxPredict(softmaxModel, train_features);
    % Update the potentials of the CRF of training data
    run assign_train_potentials.m
    % Run inference on the CRF for new video sequence
    [nodeProbs_train, edgeProbs_train, ~] = UGM_Infer_LBP(newNodePot, newEdgePot, newEdgeStruct);
    [~, pred_infer] = max(nodeProbs_train, [], 2);
    pred_infer = pred_infer(1:newNumANode)';
    acc_train = [acc_train, mean(train_labels(total_sel) == pred_infer(total_sel))];

     % Active learning module
    if pc.weakTeacher >= 0
        strong_index = active_learning_UGM(nodeProbs_train, edgeProbs_train, ...
            newNumANode, newEdgeStruct, pc, strong_sel);
    else
        strong_index = [];
    end
    strong_sel(strong_index) = 1;
 
    % Run conditional inference
    if pc.weakTeacher == 1 && iter > 2;
        clamped = zeros(1,newNNodes);
        clamped(strong_sel) = train_labels(strong_sel);
        [condNodePot,condEdgePot,~] = ...
            UGM_Infer_Conditional(newNodePot, newEdgePot, ...
            newEdgeStruct, clamped, @UGM_Infer_LBP);
        
        condNodePot = condNodePot(1:newNumANode,:);
        [~, weak_labels] = max(condNodePot, [], 2);
        weak_labels = weak_labels';
        condNodePot(condNodePot==1) = -1;
        weak_index = find(max(h_train,[],1) > pc.delta);
        if length(weak_index) > pc.K
            weak_index = weak_index(randsample(length(weak_index), pc.K));
        end
    else
        weak_index = [];
    end
    weak_sel(weak_index) = 1;
    total_sel = strong_sel | weak_sel;
    
    buffer_train_features = [initial_train_features, train_features(:,strong_sel)];
    buffer_train_labels = [initial_train_labels, train_labels(strong_sel)];
    if pc.weakTeacher == 1 && iter > 2
        buffer_train_features = [buffer_train_features, train_features(:,weak_sel)];
        buffer_train_labels = [buffer_train_labels, weak_labels(weak_sel)];
    end
    
    % Update the appearance model
    options.maxIter = 1000;
    softmaxModel = softmaxTrainNew(pc.inputSize, pc.numClasses, pc.lambda, ...
        buffer_train_features, buffer_train_labels, options);
    
    % Update the context model
    % Co-occurance frequencies among the activities
    cur_idx = train_seqs_ids(:, total_sel);
    coFreqAA = co_frequency_v2(allEvents, coFreqAA, cur_idx, pc);
    
    if pc.withOP
        % Co-occurance frequencies of the activity and objects
        coFreqAO = compute_co_freq_AO(coFreqAO, train_labels(total_sel), ...
            new_object_list(:,total_sel), pc.numClasses);
        % Activity people context
        for n = cur_idx
            ii = n(1); % seq number
            jj = n(2); % activity id
            for k = 1:length(allEvents{ii}.mapObjectsTypes{jj})
                if allEvents{ii}.mapObjectsTypes{jj}(k)==1
                    fl = allEvents{ii}.mapObjectsFirstLocation{jj}(k,1:2);
                    ll = allEvents{ii}.mapObjectsLastLocation{jj}(k,1:2);
                    dist = norm(fl-ll,2);
                    bin = bin_P_dist(dist);
                    contextAP(allEvents{ii}.eventTypes(jj), :) = ...
                        contextAP(allEvents{ii}.eventTypes(jj),:) + bin';
                end
            end
        end
    end
    
    % Evaluate the model on the test data
    % Apply appearance model
    [pred, h_test] = softmaxPredict(softmaxModel, testFeatures);
    acc_no_context = [acc_no_context, mean(testLabels == pred)];
    res_no_context = [res_no_context; pred];
    
    % Apply context model
    run assign_test_potentials.m
    [nodeProbs, edgeProbs, ~] = UGM_Infer_LBP(testNodePot, testEdgePot, testEdgeStruct);
    [~,res_infer] = max(nodeProbs,[],2);
    res_context = [res_context; res_infer'];
    acc_context = [acc_context, mean(testLabels(:) == res_infer(1:testNumANode))];
    
    fprintf('%d\t%d\t%d\t%d\t%0.2f\t\t%0.2f\t%0.2f\n', iter, ...
        length(initial_train_labels) + sum(strong_sel) + sum(weak_sel), ...
        length(initial_train_labels) + sum(strong_sel), sum(weak_sel), ...
        100*acc_no_context(end), 100*acc_context(end), 100*acc_train(end));
end

if ~exist('./results', 'dir')
    mkdir('./results')
end
save(sprintf('./results/result_%s_%s_st_%d_wt_%d_k_%d_x2.mat', ...
    pc.dataset, pc.type, pc.strongTeacher, pc.weakTeacher, pc.K), ...
    'pc', 'nodeProbs_test', 'testLabels', 'res_no_context', 'res_context', ...
    'strong_sel', 'weak_sel', 'train_seqs_ids');