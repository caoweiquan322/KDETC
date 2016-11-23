% Load stk variable.
% stk = load('starkey.mat');

% Plot specified year and month.
month_fix = 7;
days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
for year=1996%1993:1996
    for month = month_fix:month_fix%4:8
        day = days(month);
        [id, t, label, x, y] = filter_starkey_by_month(stk.id, stk.t,...
            stk.label, stk.x, stk.y, year, month, day);
        
        % Prepare the training data.
        num_classes = 3;
        styles = {'r.', 'g.', 'k.'};
        d = 2;
        pred_protect_level = 10;
        data = cell(num_classes, 1);
        num_instances = 0;
        known_labels = {'"C"', '"D"', '"E"'};
        for k=1:num_classes
            sub_idx = strcmp(known_labels{k}, label);
            data{k} = [x(sub_idx), y(sub_idx)];
            num_instances = num_instances + size(data{k}, 1);
        end
        
        % Train GMM model.
        options = statset('Display', 'final');
        gmm = cell(num_classes, 1);
        for k=1:num_classes
            K = optimal_kmeans_k(data{k}, [3, 12]);
            fprintf('Optimal K of cluster #%d is %d\n', k, K);
            gmm{k} = fitgmdist(data{k}, K, 'Options', options);
        end
        
        % Convert trajectories to statistics features.
        trajs = organize_starkey(id, t, label, x, y);
        num_trajs = size(trajs, 1);
        Y = zeros(num_trajs, 1);
        pred_Y = zeros(num_trajs, 1);
        for i=1:num_trajs
            data = trajs{i, 3};
            if strcmp('"C"', trajs{i, 2})
                Y(i) = 1;
            elseif strcmp('"D"', trajs{i, 2})
                Y(i) = 2;
            elseif strcmp('"E"', trajs{i, 2})
                Y(i) = 3;
            else
                fprintf('Unrecognized label type: %s\n', trajs{i, 2});
            end
            acc = zeros(num_classes, 1);
            for k=1:num_classes
                acc(k) = sum(log(pdf(gmm{k}, data(:,1:2))));
            end
            [~, pred_Y(i)] = max(acc);
        end
        fprintf('The error rate of gmm model is %.3f\n', sum(Y~=pred_Y)/num_trajs);
    end
end
