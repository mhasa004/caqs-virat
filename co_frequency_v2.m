function coFreqAA = co_frequency_v2(allEvents, coFreqAA, cur_idx, pc)

for n = cur_idx
    i = n(1); % seq number
    j = n(2); % activity id
    
    idx = 1:allEvents{i}.numEvents;
    start_frame = allEvents{i}.startFrame(idx);
    mid_frame = start_frame + allEvents{i}.numFrames(idx)/2;
    spatial_location = allEvents{i}.location(1:2,idx)+allEvents{i}.location(3:4,idx)/2;
    types = allEvents{i}.eventTypes(idx);
    
    for k = idx
        if k == j
            continue;
        end
        temporal_dist = abs(mid_frame(k) - mid_frame(j));
        spatial_dist = norm(spatial_location(k) - spatial_location(j));
        
        if  temporal_dist < pc.aa_thr_t && spatial_dist < pc.aa_thr_s
            coFreqAA(types(j),types(k)) = coFreqAA(types(j),types(k)) + 1;
        end
    end 
end