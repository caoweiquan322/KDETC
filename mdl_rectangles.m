function [rects] = mdl_rectangles(data, finest_grid_size, min_num)

%% Get initial partitions.
[x_range, y_range, bw_x, bw_y, partition_x, partition_y, integrations] =...
    mdl_partition(data, finest_grid_size);

%% Organize the data as rectangles.
nx = size(partition_x, 1);
ny = size(partition_y, 1);
rects = zeros(ny*nx, 5);
num_classes = length(data);
N = zeros(num_classes, 1);
count = 0;
for i=1:nx
    for j=1:ny
        for k=1:num_classes
            N(k) = Rk_xy(integrations, k,...
                partition_x(i,1), partition_x(i,2),...
                partition_y(j,1), partition_y(j,2));
        end
        [sorted_N, sorted_idx] = sort(N, 1, 'descend');
        if sorted_N(1) >= min_num && sorted_N(2)<min_num
            count = count+1;
            rects(count,:) = [partition_x(i,1), partition_x(i,2),...
                partition_y(j,1), partition_y(j,2), sorted_idx(1)];
        end
    end
end
rects = rects(1:count,:);

%% Try to merge connected rectangles.
while true
    nr = size(rects, 1);
    taken = zeros(nr, 1);
    n_rects = zeros(nr, 5);
    count = 0;
    for i=1:nr
        if ~taken(i)
            count = count+1;
            able_to_merge = false;
            for j=(i+1):nr
                if ~taken(j)
                    [able_to_merge, merged] = rect_could_merge(rects(i,:), rects(j,:));
                    if able_to_merge
                        n_rects(count,:) = merged;
                        taken(j) = true;
                        break;
                    end
                end
            end
            if ~able_to_merge, n_rects(count,:) = rects(i,:); end
        end
    end
    if count == nr, break; end % No more mergings.
    rects = n_rects(1:count, :);
end

%% Converts x/y units to original instead of grids.
rects(:,1) = (rects(:,1)-1)*bw_x+x_range(1);
rects(:,2) = (rects(:,2))*bw_x+x_range(1);
rects(:,3) = (rects(:,3)-1)*bw_y+y_range(1);
rects(:,4) = (rects(:,4))*bw_y+y_range(1);

end