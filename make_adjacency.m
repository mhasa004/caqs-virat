function [adj, temporal_dist, spatial_dist] = make_adjacency( ...
    allEvents, seqIndex, thr_AA_t, thr_AA_s)
% Given all the event sequences and descriptions and sequence ids this
% function compute the adjancecy matrix

adj = [];
temporal_dist = [];
spatial_dist = [];
numNodes = 0;
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
    
    % Get the spatial and temporal information
    startFrame = allEvents{i}.startFrame(idx);
    endFrame = startFrame + allEvents{i}.numFrames(idx);
    
    spatialLocation = allEvents{i}.location(1:2,idx)+allEvents{i}.location(3:4,idx)/2;
    
    % Adjancency matrix for the current sequence
    seqAdj = zeros(length(idx));
    seq_temporal_dist = zeros(length(idx));
    seq_spatial_dist = zeros(length(idx));
    for j = 1:length(idx)
        for k = j+1:length(idx)
            dist_t = max(0, startFrame(k) - endFrame(j));
            dist_s = norm(spatialLocation(k) - spatialLocation(j));
            
            if  dist_t < thr_AA_t && dist_s < thr_AA_s
                seqAdj(j,k) = 1;
                seq_temporal_dist(j,k) = dist_t;
                seq_spatial_dist(j,k) = dist_s;
            end
        end
    end
    
    numNodes_temp = numNodes + length(idx);
    
    adj_temp = zeros(numNodes_temp);
    adj_temp(1:numNodes, 1:numNodes) = adj;
    adj_temp(numNodes+1:numNodes_temp, numNodes+1:numNodes_temp) = seqAdj;
    adj = adj_temp;
    
    temp = zeros(numNodes_temp);
    temp(1:numNodes, 1:numNodes) = temporal_dist;
    temp(numNodes+1:numNodes_temp, numNodes+1:numNodes_temp) = seq_temporal_dist;
    temporal_dist = temp;
    
    temp = zeros(numNodes_temp);
    temp(1:numNodes, 1:numNodes) = spatial_dist;
    temp(numNodes+1:numNodes_temp, numNodes+1:numNodes_temp) = seq_spatial_dist;
    spatial_dist = temp;
   
    numNodes = numNodes_temp;
end
%adj = adj + adj';
temporal_dist = temporal_dist + temporal_dist';
spatial_dist = spatial_dist + spatial_dist';