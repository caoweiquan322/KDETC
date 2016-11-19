%% Settings.
miu_range = [0, 500];
sigma_range = 0.8*[10, 30];
size_range = [200, 400];
components_range = 2+[3, 8];
styles = {'r*', 'gs', 'k+'};
d = 2;

rng(5);
finest_grid_size = 1000;

%% Generate synthetic data.
num_classes = length(styles);
data = cell(num_classes, 1);
num_instances = 0;
for k=1:num_classes
    num_components = components_range(1)-1+randi(diff(components_range)+1,...
        1, 1);
    data{k} = generate_gauss_data(num_components, d, miu_range, sigma_range, size_range);
    num_instances = num_instances + size(data{k}, 1);
end

%% Visualize data.
figure;
hold on;
for k=1:num_classes
    sub_data = data{k};
    plot(sub_data(:, 1), sub_data(:, 2), styles{k});
end

%% Re-organize data.
pure_data = zeros(num_instances, d);
labels = zeros(num_instances, 1);
count = 0;
for k=1:num_classes
    sub_data = data{k};
    rows = size(sub_data, 1);
    pure_data(count+1:count+rows, :) = sub_data;
    labels(count+1:count+rows) = k*ones(rows, 1);
    count = count+rows;
end

%% Calculate integration of minimum grid histogram.
x_range = [min(pure_data(:,1)), max(pure_data(:,1))];%[-50, 600];
y_range = [min(pure_data(:,2)), max(pure_data(:,2))];%[-50, 600];
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

%% Plot the clustering results.
figure;
hold on;
for k=1:num_classes
    sub_data = data{k};
    plot(sub_data(:, 1), sub_data(:, 2), styles{k});
end
for i=1:size(partition_x, 1)
    plot((partition_x(i, 1)*bw_x+x_range(1))*ones(1,2), y_range);
    plot((partition_x(i, 2)*bw_x+x_range(1))*ones(1,2), y_range);
end
for i=1:size(partition_y, 1)
    plot(x_range, (partition_y(i, 1)*bw_y+y_range(1))*ones(1,2));
    plot(x_range, (partition_y(i, 2)*bw_y+y_range(1))*ones(1,2));
end
