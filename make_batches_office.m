batches = cell(1,pc.numBatch);

k = 1;
for i = pc.trainSeq
    batches{k} = i;
    k = k + 1;
end