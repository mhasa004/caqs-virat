function coFreqAA = co_frequency(allEvents, ...
    seqIndex, numClasses, thr_AA_t, thr_AA_s)

coFreqAA = ones(numClasses);
for i = seqIndex
    if allEvents{i}.numEvents == 0
        continue;
    end
    % Get the indices of non-zero feature activities
    idx = [];
    for j = 1:allEvents{i}.numEvents
        if abs(sum(allEvents{i}.features(:,j))) > 0
            idx = [idx, j];
        end
    end
    idx = 1:allEvents{i}.numEvents;
    
    % Get the spatial and temporal information
    startFrame = allEvents{i}.startFrame(idx);
    endFrame = startFrame + allEvents{i}.numFrames(idx);
    spatialLocation = allEvents{i}.location(1:2,idx)+allEvents{i}.location(3:4,idx)/2;
    types = allEvents{i}.eventTypes(idx);
    
    seqCoFreq = zeros(numClasses);
    for j = 1:length(idx)
        for k = j+1:length(idx)
            %temporal_dist = min(abs(endFrame(k) - startFrame(j)), ...
            %   abs(endFrame(j) - startFrame(k)));
            temporal_dist = startFrame(k) - endFrame(j);
            spatial_dist = norm(spatialLocation(k) - spatialLocation(j));
            
            if types(j) == 0 || types(k) == 0
                continue;
            end
            
            if  temporal_dist > 0 && temporal_dist < thr_AA_t ...
                    && spatial_dist < thr_AA_s
                seqCoFreq(types(j),types(k)) = seqCoFreq(types(j),types(k)) + 1;
            end
        end
    end
    coFreqAA = coFreqAA + seqCoFreq;
end