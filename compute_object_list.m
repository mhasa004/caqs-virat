function objectList = compute_object_list(allEvents, numObjectClasses, seqIdx)
    
objectList = [];
for i = seqIdx
    for j = 1:allEvents{i}.numEvents
        if abs(sum(allEvents{i}.features(:,j))) > 0
            % get associated objects
            ot = allEvents{i}.mapObjectsTypes{j};    
         
            ol = zeros(numObjectClasses, 1);
            for k = 1:length(ot)
                if ot(k)>=1 && ot(k)<=5
                    ol(ot(k)) = 1;
                end
            end
            objectList = [objectList, ol];

        end
    end
end