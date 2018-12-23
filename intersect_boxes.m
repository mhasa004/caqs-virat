function overlap = intersect_boxes(box1, box2)

area1 = box1(3)*box1(4);
area2 = box2(3)*box2(4);

if area1==0||area2==0
    overlap = 0;
    return;
end

if area1 <= area2
    overlap = rectint(box1,box2)/area1;
else
    overlap = rectint(box1,box2)/area2;
end