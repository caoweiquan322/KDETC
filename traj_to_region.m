function row = traj_to_region(xyt, rects)

num_pts = size(xyt, 1);
num_rects = size(rects, 1);
row = zeros(1, num_rects);
for i=1:num_pts
    x = xyt(i, 1);
    y = xyt(i, 2);
    for j=1:num_rects
        if x>rects(j,1) && x<rects(j,2) && y>rects(j,3) && y<rects(j,4)
            row(j) = row(j) + 1;
            break;
        end
    end
end

end