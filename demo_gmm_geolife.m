% Load geolife variable.
%geolife = load('geolife_slide.mat');
%trajs = geolife.trajs;

% Process and classify.

% Prepare the training data.
styles = {'r.', 'gx', 'bs', 'co', 'm+'};
num_classes = length(styles);
d = 9;
pred_protect_level = 10;
data = cell(num_classes, 1);
num_instances = 0;
known_labels = {1, 2, 3, 4, 5};
for k=1:num_classes
    lk = known_labels{k};
    sub_data = zeros(50000, 9);
    count = 0;
    for i=1:size(trajs, 1)
        if trajs{i,2} == lk
            rows = size(trajs{i,3}, 1);
            sub_data(count+1:count+rows, :) = trajs{i, 3};
            count = count+rows;
        end
    end
    data{k} = sub_data(1:count,:);
    num_instances = num_instances + size(data{k}, 1);
end

% Load pre-calculation results from files instead.
% geolife = load('geolife_stats.mat');
% trajs = geolife.trajs;
% data = geolife.data;
% num_instances = geolife.num_instances;
fprintf('Loading geolife statistics OK.\n');

% Train GMM model.
options = statset('Display', 'final');
gmm = cell(num_classes, 1);
for k=1:num_classes
    K = optimal_kmeans_k(data{k}, [5, 30]);
    fprintf('Optimal K of cluster #%d is %d\n', k, K);
    gmm{k} = fitgmdist(data{k}, K, 'Options', options, 'RegularizationValue', 1e-2);
end

% Convert trajectories to statistics features.
num_trajs = size(trajs, 1);
Y = zeros(num_trajs, 1);
pred_Y = zeros(num_trajs, 1);
for i=1:num_trajs
    traj_data = trajs{i, 3};
    Y(i) = trajs{i, 2};
    acc = zeros(num_classes, 1);
    for k=1:num_classes
        acc(k) = sum(log(pdf(gmm{k}, traj_data)));
    end
    [~, pred_Y(i)] = max(acc);
end
fprintf('The error rate of gmm model is %.3f\n', sum(Y~=pred_Y)/num_trajs);
