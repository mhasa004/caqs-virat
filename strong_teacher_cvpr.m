function strongIndex = strong_teacher_cvpr(h, K, sel)
    h = sort(h, 2, 'descend');
    h = h(:, 1:2);
    cc = h(:,1) - h(:,2);
    cc = cc(~sel);
    [~,idx] = sort(cc);
    strongIndex = idx(1:K);
    
    idx = find(~sel);
    strongIndex = sort(idx(strongIndex));
end 