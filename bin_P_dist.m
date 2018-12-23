function bin = bin_P_dist(dist)
    if dist>=0 && dist<25, bin = [1;0;0;0;0];
    elseif dist>=25 && dist<50, bin = [0;1;0;0;0];
    elseif dist>=50 && dist<200, bin = [0;0;1;0;0];
    elseif dist>=200 && dist<500, bin = [0;0;0;1;0];
    else bin = [0;0;0;0;1]; 
    end
end