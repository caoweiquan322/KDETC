function [x_range, y_range, bw_x, bw_y, partition_x, partition_y, integrations] =...
    mdl_partition(data, finest_grid_size)

% Re-organize the data.
[pure_data, ~] = reorganize_data(data);
num_classes = length(data);

%% Calculate integration of minimum grid histogram.
x_range = [min(pure_data(:,1)), max(pure_data(:,1))];
y_range = [min(pure_data(:,2)), max(pure_data(:,2))];
integrations = cell(num_classes, 1);
for k=1:num_classes
    integrations{k} = calculate_integration_hist(data{k}, x_range, y_range,...
        finest_grid_size);
end

%% Do clustering.
bw_x = diff(x_range)/finest_grid_size;
bw_y = diff(y_range)/finest_grid_size;
partition_x = [1, finest_grid_size];
partition_y = [1, finest_grid_size];
[min_cost, entropies] = mdl(partition_x, partition_y, bw_x, bw_y, integrations);
improved = true;
while improved
    improved = false;
    
    % Round X.
    entropies_x = sum(entropies, 1);
    [~, idx_max] = max(entropies_x);
    if diff(partition_x(idx_max,:)) >= 1
        best_sepx = find_best_sepx(partition_x, partition_y, integrations, idx_max);
        partition_nx = [partition_x; best_sepx(2,:)];
        partition_nx(idx_max, :) = best_sepx(1,:);
        [new_cost, new_entropies] = mdl(partition_nx, partition_y, bw_x, bw_y, integrations);
        if new_cost < min_cost
            partition_x = partition_nx;
            min_cost = new_cost;
            entropies = new_entropies;
            improved = true;
        end
    end
    
    % Round Y.
    entropies_y = sum(entropies, 2);
    [~, idx_max] = max(entropies_y);
    if diff(partition_y(idx_max,:)) >= 1
        best_sepy = find_best_sepy(partition_x, partition_y, integrations, idx_max);
        partition_ny = [partition_y; best_sepy(2,:)];
        partition_ny(idx_max, :) = best_sepy(1,:);
        [new_cost, new_entropies] = mdl(partition_x, partition_ny, bw_x, bw_y, integrations);
        if new_cost < min_cost
            partition_y = partition_ny;
            min_cost = new_cost;
            entropies = new_entropies;
            improved = true;
        end
    end
    
end

end