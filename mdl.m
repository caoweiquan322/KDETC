function [description, entropies] = mdl(partition_x, partition_y, bw_x, bw_y, integrations)

nx = size(partition_x, 1);
ny = size(partition_y, 1);
description = log_star(nx) + log_star(ny);
description = description + sum(ceil(log2(diff(partition_x, 1, 2)*bw_x+bw_x)));
description = description + sum(ceil(log2(diff(partition_y, 1, 2)*bw_y+bw_y)));
encoding_weight = 1;
description = description * encoding_weight;
entropies = zeros(ny, nx);
for i=1:nx
    for j=1:ny
        [entropy, nsum] = C_xy(integrations,...
            partition_x(i, 1), partition_x(i, 2),...
            partition_y(j, 1), partition_y(j, 2));
        description = description + ceil(log2(nsum+1))*encoding_weight + entropy;
        entropies(j, i) = entropy;
    end
end

end