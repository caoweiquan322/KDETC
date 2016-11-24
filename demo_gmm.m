%% Settings.
miu_range = [0, 500];
sigma_range = 1.5*[10, 30];
size_range = [200, 400];
components_range = 2+[3, 4];
styles = {'r.', 'g.', 'k.'};
d = 2;

rng(3);
pred_protect_level = 10;

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

%% Train GMM model.
options = statset('Display', 'final');
gmm = cell(num_classes, 1);
for k=1:num_classes
    K = optimal_kmeans_k(data{k}, [3, 12]);
    fprintf('Optimal K of cluster #%d is %d\n', k, K);
    gmm{k} = fitgmdist(data{k}, K, 'Options', options);
end

%% Visualize train results.
figure;
for k=1:num_classes
    subplot(1, num_classes, k);
    sub_data = data{k};
    plot(sub_data(:, 1), sub_data(:, 2), styles{k});
    hold on;
    h = ezcontour(@(x, y)pdf(gmm{k}, [x, y]), miu_range, miu_range);
end

%% Do prediction.
pred = zeros(num_instances, num_classes);
for k=1:num_classes
    pred(:, k) = pdf(gmm{k}, pure_data);
end
[sorted_pred, sorted_idx] = sort(pred, 2, 'descend');
pred_labels = sorted_idx(:, 1);
uncertain_idx = sorted_pred(:,1)<pred_protect_level*sorted_pred(:,2);
pred_labels(uncertain_idx) = -1;
%[~, pred_labels] = max(pred, [], 2);
fprintf('Prediction accuracy: %.2f%%.\n',...
    sum(pred_labels==labels)/(num_instances-sum(uncertain_idx))*100);

%% Visualize prediction.
figure;
hold on;
for k=1:num_classes
    sub_data = pure_data(pred_labels==k, :);
    plot(sub_data(:, 1), sub_data(:, 2), styles{k});
end

