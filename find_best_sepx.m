function [sepx] = find_best_sepx(partition_x, partition_y, integrations, idx_to_sep)

range_x = partition_x(idx_to_sep, :);
ny = size(partition_y, 1);
entropy_sepx = zeros(diff(range_x), 1);
for i=range_x(1):(range_x(2)-1)
    for j=1:ny
        [entropy, ~] = C_xy(integrations, range_x(1), i, partition_y(j,1), partition_y(j,2));
        entropy_sepx(i-range_x(1)+1) = entropy_sepx(i-range_x(1)+1) + entropy;
        [entropy, ~] = C_xy(integrations, i+1, range_x(2), partition_y(j,1), partition_y(j,2));
        entropy_sepx(i-range_x(1)+1) = entropy_sepx(i-range_x(1)+1) + entropy;
    end
end
[~, idx_optimal] = min(entropy_sepx);
best_x = range_x(1) + idx_optimal - 1;
sepx = [range_x(1), best_x;
    best_x+1, range_x(2)];

end