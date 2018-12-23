function strongIndex = strong_teacher_random(sel, K)
    idx = find(~sel);
    if length(idx) > K
        strongIndex = idx(randperm(length(idx), K));
    else
        strongIndex = idx;
    end
end