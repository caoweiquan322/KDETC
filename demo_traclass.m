%% Settings.
miu_range = [0, 500];
sigma_range = 0.5*[10, 30];
size_range = [200, 400];
components_range = 2+[3, 4];
styles = {'r.', 'g.', 'k.'};
d = 2;

rng(3);
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

%% Get the optimal partitions.
rects = mdl_rectangles(data, finest_grid_size, 20, 10);

%% Plot the clustering results.
figure;
hold on;
for k=1:num_classes
    sub_data = data{k};
    plot(sub_data(:, 1), sub_data(:, 2), styles{k});
end
for i=1:size(rects,1)
    plot([rects(i,1) rects(i,2) rects(i,2) rects(i,1) rects(i,1)],...
        [rects(i,3) rects(i,3) rects(i,4) rects(i,4) rects(i,3)],...
        [styles{rects(i,5)}(1), '-']);
end
