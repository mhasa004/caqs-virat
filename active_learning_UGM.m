function strongIndex = active_learning_UGM(nodeProbs, edgeProbs, ...
    numANodes, edgeStruct, pc, sel)

K = pc.K;
strongTeacher = pc.strongTeacher;

h = nodeProbs(1:numANodes, :)';

strongIndex = [];
% All manual labeling
if strongTeacher == 0
    idx = find(~sel);
    strongIndex = idx(1:K);
end

% Strong teacher
if strongTeacher == 1
    strongIndex = strong_teacher_em_p(h, edgeProbs, numANodes, edgeStruct, K, sel);
end

% ICCV greedy solution
if strongTeacher == 2
    strongIndex = strong_teacher_em(h, edgeProbs, numANodes, edgeStruct, K, sel);
end

% CVPR Method
if strongTeacher == 3
    h = h';
    strongIndex = strong_teacher_cvpr(h, K, sel);
end

% Only entropy
if strongTeacher == 4
    strongIndex = strong_teacher_e(h, K, sel);
end

% Batch rank
if strongTeacher == 5
    strongIndex = strong_teacher_batch_rank(h, K, sel);
end

% Random
if strongTeacher == 6
    strongIndex = strong_teacher_random(sel, K);
end
