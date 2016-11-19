function [sepy] = find_best_sepy(partition_x, partition_y, integrations, idx_to_sep)

range_y = partition_y(idx_to_sep, :);
nx = size(partition_x, 1);
entropy_sepy = zeros(diff(range_y), 1);
for i=1:nx
    for j=range_y(1):(range_y(2)-1)
        [entropy, ~] = C_xy(integrations, partition_x(i,1), partition_x(i,2), range_y(1), j);
        entropy_sepy(j-range_y(1)+1) = entropy_sepy(j-range_y(1)+1) + entropy;
        [entropy, ~] = C_xy(integrations, partition_x(i,1), partition_x(i,2), j+1, range_y(2));
        entropy_sepy(j-range_y(1)+1) = entropy_sepy(j-range_y(1)+1) + entropy;
    end
end
[~, idx_optimal] = min(entropy_sepy);
best_y = range_y(1) + idx_optimal - 1;
sepy = [range_y(1), best_y;
    best_y+1, range_y(2)];

end