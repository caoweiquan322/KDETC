% Load stk variable.
% stk = load('starkey.mat');

% Plot specified year and month.
month_fix = 7;
days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
N = 256; % The number of grids in x/y for density estimation.
MIN_XY = zeros(1, 2); % The x/y boundary.
MAX_XY = zeros(1, 2);
for year=1995%1993:1996
    for month = month_fix:month_fix%4:8
        day = days(month);
        [id, t, label, x, y] = filter_starkey_by_month(stk.id, stk.t,...
            stk.label, stk.x, stk.y, year, month, day);
        tmp = x;
        x = y;
        y = -tmp;
        
        % Estimate the boundary.
        MAX=max([x y],[],1); MIN=min([x y],[],1); Range=MAX-MIN;
        MAX_XY=MAX+Range/8; MIN_XY=MIN-Range/8;
        
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
        
        % Visualize the raw data.
        figure;
        for k=1:num_classes
            plot(data{k}(:, 1), data{k}(:, 2), styles{k});
            hold on;
        end
        legend('Cattle', 'Deer', 'Elk');
        
        % Estimate density distribution.
        densities = cell(num_classes, 1);
        for k=1:num_classes
            sub_n = size(data{k}, 1);
            sub_t = round(sub_n * 0.4);
            to_train = data{k} (randperm(sub_n, sub_t)', :);
            [bw, densities{k}, X, Y] = kde2d(to_train, N, MIN_XY, MAX_XY);
%             surf(X, Y, densities{k});
%             pause;
        end
        
        % Visualize the densities.
        styles = {'+r', '+g', '+k'};
        figure;
        for k=1:num_classes
            contour3(X, Y, densities{k}, 10, styles{k});
            hold on;
        end
        legend('Cattle', 'Deer', 'Elk');
        
        % Convert trajectories to statistics features.
        STP = (MAX_XY-MIN_XY)/(N-1);
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
                for m=1:size(data, 1)
                    IDX_XY = round((data(m, 1:2) - MIN_XY)./STP)+1;
                    IDX_XY = min(max(IDX_XY, 1), N);
                    acc(k) = acc(k) + log(densities{k}(IDX_XY(2), IDX_XY(1)));
                end
%                 acc(k) = sum(log(pdf(gmm{k}, data(:,1:2))));
            end
            [~, pred_Y(i)] = max(acc);
        end
        fprintf('The error rate of kde model is %.3f\n', sum(Y~=pred_Y)/num_trajs);
    end
end
