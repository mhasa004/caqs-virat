function coFreqAO = compute_co_freq_AO(coFreqAO, labels, objectList, numClasses)

if isempty(objectList)
    return
end

numObjectClasses = size(objectList,1);
F = zeros(numClasses, numObjectClasses);
for i = 1:numClasses
    for j = 1:numObjectClasses
        F(i,j) = sum(objectList(j, labels == i));
    end
end

coFreqAO = coFreqAO + F;