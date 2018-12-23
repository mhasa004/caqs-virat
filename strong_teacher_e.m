function strongIndex = strong_teacher_e(h, K, sel)
    h1 = entropy(h);
    h1 = h1(~sel);
    [~, strongIndex] = sort(h1, 'descend');
    strongIndex = strongIndex(1:K);
    
    idx = find(~sel);
    strongIndex = idx(strongIndex);
end