%% Settings.
miu_range = [0, 500];
sigma_range = 1.5*[10, 30];
size_range = [200, 400];
components_range = 2+[3, 4];
styles = {'r.', 'g.', 'k.'};
d = 2;

% rng(3);
pred_protect_level = 2;

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

% Estimate the boundary.
N = 256;
MAX=max(pure_data,[],1); MIN=min(pure_data,[],1); Range=MAX-MIN;
MAX_XY=MAX+Range/8; MIN_XY=MIN-Range/8;

%% Train GMM model.
densities = cell(num_classes, 1);
for k=1:num_classes
    [bw, densities{k}, X, Y] = kde2d(data{k}, N, MIN_XY, MAX_XY);
end

%% Visualize train results.
figure;
for k=1:num_classes
    subplot(1, num_classes, k);
    sub_data = data{k};
    plot(sub_data(:, 1), sub_data(:, 2), styles{k});
    hold on;
    contour3(X, Y, densities{k}, 10);
end

%% Do prediction.
pred = zeros(num_instances, num_classes);
STP = (MAX_XY-MIN_XY)/(N-1);
for k=1:num_classes
    for i=1:num_instances
        IDX_XY = round((pure_data(i, :) - MIN_XY)./STP)+1;
        pred(i, k) = densities{k}(IDX_XY(2), IDX_XY(1));
    end
end
[sorted_pred, sorted_idx] = sort(pred, 2, 'descend');
pred_labels = sorted_idx(:, 1);
uncertain_idx = sorted_pred(:,1)<pred_protect_level*sorted_pred(:,2);
pred_labels(uncertain_idx) = -1;
%[~, pred_labels] = max(pred, [], 2);
fprintf('Prediction accuracy: %.2f%%.\n',...
    sum(pred_labels==labels)/(num_instances-sum(uncertain_idx))*100);
fprintf('Deny rate: %.2f%%.\n', sum(uncertain_idx)/num_instances*100);

%% Visualize prediction.
% figure;
% hold on;
% for k=1:num_classes
%     sub_data = pure_data(pred_labels==k, :);
%     plot(sub_data(:, 1), sub_data(:, 2), styles{k});
% end

