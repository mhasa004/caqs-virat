total_train_ins = 0;
for i = pc.trainSeq
    for j = 1:allEvents{i}.numEvents
        if abs(sum(allEvents{i}.features(:,j))) > 0
           total_train_ins = total_train_ins + 1;
        end
    end 
end
per_batches = zeros(1,pc.numBatch);
per_batches(1) = floor(total_train_ins * pc.initBatch);
for i = 2:pc.numBatch
    rem = total_train_ins - per_batches(i-1);
    per_batch_rem = floor(rem/(pc.numBatch-i+1));
    per_batches(i) = per_batches(i-1) + per_batch_rem;
end

batches = cell(1,pc.numBatch);

k = 1;
total_train_ins = 0;
for i = pc.trainSeq
    for j = 1:allEvents{i}.numEvents
        if abs(sum(allEvents{i}.features(:,j))) > 0
           total_train_ins = total_train_ins + 1;
        end
    end 
    if total_train_ins <= per_batches(k)
        batches{k} = [batches{k}, i];
    else
        batches{k} = [batches{k}, i];
        k = k + 1; 
    end
    if k > pc.numBatch
        batches{k-1} = [batches{k-1}, i];
        break
    end
end